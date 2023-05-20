<script>
  import { onMount } from "svelte";
  import * as maplibregl from "maplibre-gl";
  import * as pmtiles from "pmtiles";
  //   import layers from "protomaps-themes-base";

  import "maplibre-gl/dist/maplibre-gl.css";

  onMount(() => {
    let protocol = new pmtiles.Protocol();
    maplibregl.addProtocol("pmtiles", protocol.tile);

    const map = new maplibregl.Map({
      container: "map",
      style: {
        version: 8,
        glyphs: "https://cdn.protomaps.com/fonts/pbf/{fontstack}/{range}.pbf",
        sources: {
          protomaps: {
            type: "vector",
            url: "pmtiles://http://localhost:8080/fire.pmtiles",
            attribution:
              '<a href="https://protomaps.com">Protomaps</a> © <a href="https://openstreetmap.org">OpenStreetMap</a>',
          },
        },
        layers: [
          {
            id: "fire",
            source: "protomaps",
            "source-layer": "fire",
            type: "fill",
            paint: {
              "fill-color": "#000000",
            },
          },
        ],
      },
    });

    map.on("click", function (e) {
      var features = map.queryRenderedFeatures(e.point, { layers: ["fire"] });

      console.log(features);
      // Perform actions based on the clicked features
    });
  });
</script>

<div id="map" />

<style>
  #map {
    height: 80vh;
  }
</style>
