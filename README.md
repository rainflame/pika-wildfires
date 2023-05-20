# Pika Wildfires

A map of historical wildfires

## Data

The `data/` directory contains the basemap files.

To create a `.pmtiles` file from an ESRI database, convert it to a `.geoJSON` file using GDAL:

```
ogr2ogr -f GeoJSON <file>.geojson <file>.gdb
```

Then, create a tiled version using [tippecanoe](https://github.com/mapbox/tippecanoe):

```
tippecanoe -zg -o <file>.mbtiles --drop-densest-as-needed <file>.geojson
```

Finally, convert that to `.pmtiles` using the [`pmtiles` utility](https://github.com/protomaps/go-pmtiles):

```
pmtiles convert <file>.mbtiles <file>.pmtiles
```
