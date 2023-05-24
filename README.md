# Pika Wildfires

A map of historical wildfires

## Data

Create a `/data` directory containing the basemap and fire perimeters. The fire perimeters are constructed from combining a historical USFS dataset and more recent NIFC dataset. Install [GDAL](https://gdal.org/), [tippecanoe](https://github.com/mapbox/tippecanoe), and [pmtiles](https://github.com/protomaps/PMTiles), then run the script to download the datasets and build it:

```
./create-fire-perimeters.sh
```
