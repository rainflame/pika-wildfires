import geopandas as gpd
import pandas as pd
import json
import fiona
from shapely.geometry import shape
from shapely.ops import unary_union


def load_shapefile(file_path):
    with fiona.open(file_path, 'r') as shp:
        # Read the features and handle broken geometries
        features = []
        for feature in shp:
            try:
                # Create a valid feature by fixing the geometry
                valid_feature = {'geometry': shape(feature['geometry']).buffer(
                    0), 'properties': feature['properties']}
                features.append(valid_feature)
            except Exception as e:
                print(f"Error fixing geometry, skipping feature")

    gdf = gpd.GeoDataFrame.from_features(features)
    gdf.crs = shp.crs
    # only keep polygons
    gdf = gdf[gdf.geometry.type == 'Polygon']

    return gdf


print("Loading USFS fire perimeters...")

usfs_perimeters = load_shapefile(
    'data/USFSPerimeters/S_USA.FirePerimeter.shp')


def prefer_non_undetermined(x):
    filtered_values = x[~x.isin({'Undetermined', 'Unknown', 'NA'})]
    return filtered_values.iloc[0] if not filtered_values.empty else 'Undetermined'


print("Combining duplicate fires by fire name and year...")

# # Combine duplicate fires by fire name and year
# usfs_perimeters = usfs_perimeters.groupby(['FIRENAME', 'FIREYEAR']).agg({
#     'GISACRES': 'mean',
#     'STATCAUSE': prefer_non_undetermined,
#     'DISCOVERYD': 'first',
#     'geometry': unary_union
# }).reset_index()

max_distance_threshold = 500  # in meters

usfs_perimeters['CENTROID'] = usfs_perimeters.geometry.centroid.apply(Point)
# usfs_perimeters['CENTROID'] = usfs_perimeters.geometry.centroid.apply(lambda p: (p.y, p.x))


def check_centroid_proximity(row, threshold):
    centroid = row['CENTROID']
    centroids_within_threshold = usfs_perimeters.centroid.apply(
        lambda c: centroid.distance(c) <= threshold)
    return centroids_within_threshold.sum() > 1


# Find duplicate rows based on the specified columns and centroid proximity
columns_to_check = ['FIRENAME', 'FIREYEAR']
duplicate_rows = usfs_perimeters[usfs_perimeters.duplicated(subset=columns_to_check, keep=False) &
                                 usfs_perimeters.apply(check_centroid_proximity, args=(max_distance_threshold,), axis=1)]


duplicate_rows.head(20)

# todo: filter out the duplicate rows from the original dataframe


# convert firename to lowercase
usfs_perimeters['FIRENAME'] = usfs_perimeters['FIRENAME'].str.lower()


# replace STATCAUSE values with more descriptive values
# see STATCAUSE mappings here: https://data.fs.usda.gov/geodata/edw/edw_resources/meta/S_USA.FinalFirePerimeter.xml
replacement_values = {
    '1': 'Lightning',
    '2': 'Equipment',
    '3': 'Smoking',
    '4': 'Campfire',
    '5': 'Debris burning',
    '6': 'Railroad',
    '7': 'Arson',
    '8': 'Children',
    '9': 'Miscellaneous',
}

usfs_perimeters.loc[usfs_perimeters['STATCAUSE'].isin(replacement_values.keys(
)), 'STATCAUSE'] = usfs_perimeters['STATCAUSE'].map(replacement_values)

print("Renaming columns...")
usfs_perimeters = usfs_perimeters.rename(columns={
    'FIRENAME': 'NAME',
    'FIREYEAR': 'YEAR',
    'GISACRES': 'ACRES',
    'STATCAUSE': 'CAUSE',
    'DISCOVERYD': "STARTTIME",
})
# no endtime in this dataset, but add the column anyway
usfs_perimeters['ENDTIME'] = None

# convert year to datetime
usfs_perimeters['YEAR'] = pd.to_datetime(
    usfs_perimeters['YEAR'].astype('int'), format="%Y", errors='coerce')

print("Adding a source column...")
usfs_perimeters['SOURCE'] = 'USFS'


# usfs_perimeters.to_file('data/USFSPerimeters/clean.shp',
#                         driver='ESRI Shapefile', overwrite=True)
