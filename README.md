# Pika Wildfires

A map of historical wildfires

## Data

### Fire data

Create a `/data` directory containing the basemap and fire perimeters. The fire perimeters are constructed from combining a historical USFS dataset and more recent NIFC dataset. Install [GDAL](https://gdal.org/), [tippecanoe](https://github.com/mapbox/tippecanoe), and [pmtiles](https://github.com/protomaps/PMTiles), then run the script to download the datasets and build it:

```
./create-fire-perimeters.sh
```

### Fonts

Maplibre-gl requires a series of `.pbf` files to render text. Use [font maker](https://maplibre.org/font-maker/) to convert `Barlow Regular`, and download. Unzip and move the `Barlow Regular` directory of `.pbf` files to `/data`.
