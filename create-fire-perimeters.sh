#!/bin/bash

cd data


usfs_file="USFSPerimeters/S_USA.FirePerimeter.shp"

if [ ! -f "$usfs_file" ]; then
echo -e "\n******* Downloading USFS fire data *******\n"
    curl -o USFSPerimeters.zip -# https://data.fs.usda.gov/geodata/edw/edw_resources/shp/S_USA.FirePerimeter.zip
    unzip USFSPerimeters.zip -d USFSPerimeters
fi

# curl --location --request GET  -# 'https://services3.arcgis.com/T4QMspbfLg3qTGWY/arcgis/rest/services/WFIGS_Interagency_Perimeters/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson' -o NIFCPerimeters/Perimeters.geojson
# ogr2ogr -f "ESRI Shapefile" NIFCPerimeters/Perimeters.shp NIFCPerimeters/Perimeters.geojson

nifc_file="NIFCPerimeters/Perimeters.shp"

if [ ! -f "$nifc_file" ]; then
    mkdir NIFCPerimeters
    echo -e "\n Unable to download NIFC fire data. Visit https://data-nifc.opendata.arcgis.com/datasets/nifc::wfigs-interagency-fire-perimeters/about and download the data as a shapefile, extract it, then put Perimeters.shp and associated files in data/NIFCPerimeters\n"
    exit 0
fi

echo -e "\n******* Cleaning USFS dataset *******\n"

ogr2ogr -f "ESRI Shapefile" USFSPerimeters/edit-1.shp USFSPerimeters/S_USA.FirePerimeter.shp -dialect SQLite -sql "SELECT LOWER(FIRENAME) AS FIRENAME, FIREYEAR, GISACRES, CASE WHEN STATCAUSE = 'Undetermined' THEN MIN(STATCAUSE) ELSE STATCAUSE END AS STATCAUSE, ST_Union(geometry) AS geometry FROM \"S_USA.FirePerimeter\" GROUP BY LOWER(FIRENAME), FIREYEAR"

ogr2ogr -f "ESRI Shapefile" USFSPerimeters/edit-2.shp USFSPerimeters/edit-1.shp -dialect SQLite -sql "SELECT FIRENAME, FIREYEAR, GISACRES, STATCAUSE, geometry FROM \"edit-1\" WHERE FIREYEAR >= 1900 AND FIREYEAR < 2021" 

ogr2ogr -f "ESRI Shapefile" USFSPerimeters/edit-3.shp USFSPerimeters/edit-2.shp -dialect SQLite -sql "SELECT FIRENAME AS NAME, CAST(FIREYEAR AS date) AS YEAR, GISACRES AS ACRES, STATCAUSE AS CAUSE, geometry FROM \"edit-2\"" 

ogrinfo USFSPerimeters/edit-3.shp -sql "ALTER TABLE edit-3 ADD COLUMN SOURCE VARCHAR(255)"

ogrinfo USFSPerimeters/edit-3.shp -dialect SQLite -sql "UPDATE \"edit-3\" SET SOURCE = 'USFS'"

echo -e "\n******* Cleaning NIFC dataset *******\n"

ogr2ogr -f "ESRI Shapefile" NIFCPerimeters/edit-1.shp NIFCPerimeters/Perimeters.shp -dialect SQLite -sql "SELECT poly_Incid AS NAME, poly_Acres AS ACRES, attr_Fir_7 AS YEAR, attr_FireC AS CAUSE, geometry FROM Perimeters" 

ogr2ogr -f "ESRI Shapefile" NIFCPerimeters/edit-2.shp NIFCPerimeters/edit-1.shp -dialect SQLite -sql "SELECT CAST(YEAR AS date) AS YEAR, ACRES, CAUSE, NAME, * FROM \"edit-1\"" 

ogrinfo NIFCPerimeters/edit-2.shp -sql "ALTER TABLE edit-2 ADD COLUMN SOURCE VARCHAR(255)"

ogrinfo NIFCPerimeters/edit-2.shp -dialect SQLite -sql "UPDATE \"edit-2\" SET SOURCE = 'NIFC'"

echo -e "\n******* Merging USFS and NIFC datasets *******\n"

ogr2ogr -f "ESRI Shapefile" merged.shp NIFCPerimeters/edit-2.shp -dialect SQLite -sql "SELECT p.NAME, p.YEAR, p.ACRES, p.CAUSE, 'NIFC' AS SOURCE, p.geometry FROM \"edit-2\" p UNION SELECT f.NAME, f.YEAR, f.ACRES, f.CAUSE, 'USFS' AS SOURCE, f.geometry FROM 'USFSPerimeters/edit-3.shp'.edit-3 f" -nln merged

ogr2ogr -f GeoJSON merged.geojson merged.shp -progress

echo -e "\n******* Tiling dataset *******\n"

tippecanoe -zg -o merged.mbtiles -l fire --drop-densest-as-needed merged.geojson --force

echo -e "\n******* Converting to pmtiles format *******\n"

pmtiles convert merged.mbtiles fires.pmtiles

echo -e "\n******* Cleaning up *******\n"

rm USFSPerimeters.zip 
rm merged*
rm USFSPerimeters/edit-* NIFCPerimeters/edit-*

echo -e "\n******* Done, created fires.pmtiles *******\n"