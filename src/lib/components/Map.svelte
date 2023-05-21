<script lang="ts">
  import { map } from "$lib/stores/map";
  import { createEventDispatcher, onMount } from "svelte";
  import * as maplibregl from "maplibre-gl";
  import * as pmtiles from "pmtiles";
  import type { FireProperties } from "$lib/types/fire";
  import layers from "protomaps-themes-base";

  import "maplibre-gl/dist/maplibre-gl.css";
  import PopupContent from "./PopupContent.svelte";

  const dispatch = createEventDispatcher();
  let popup: maplibregl.Popup | null = null;
  let popupContainer: HTMLElement | null = null;
  let currentProperties: FireProperties = null;

  onMount(() => {
    let protocol = new pmtiles.Protocol();
    maplibregl.addProtocol("pmtiles", protocol.tile);

    const glmap = new maplibregl.Map({
      container: "map",
      style: {
        version: 8,
        glyphs: "https://cdn.protomaps.com/fonts/pbf/{fontstack}/{range}.pbf",
        sources: {
          protomaps: {
            type: "vector",
            url: "pmtiles://http://localhost:8080/us-west.pmtiles",
            attribution:
              '<a href="https://protomaps.com">Protomaps</a> © <a href="https://openstreetmap.org">OpenStreetMap</a>',
          },
          fire: {
            type: "vector",
            url: "pmtiles://http://localhost:8080/fire.pmtiles",
            attribution: "USFS",
          },
        },
        layers: [
          ...layers("protomaps", "light"),
          {
            id: "fire",
            source: "fire",
            "source-layer": "fire",
            type: "fill",
            paint: {
              "fill-color": "#000000",
            },
          },
        ],
      },
    });

    map.set(glmap);

    glmap.on("click", function (e) {
      var features = glmap.queryRenderedFeatures(e.point, { layers: ["fire"] });

      console.log(features);
      // Perform actions based on the clicked features
    });

    glmap.on("mouseenter", "fire", (e) => {
      const features = e.features;
      if (!features || features.length === 0) return;

      const properties = features[0].properties;
      const coordinates = e.lngLat;

      currentProperties = properties as FireProperties;

      popup = new maplibregl.Popup({
        closeButton: false,
        closeOnClick: false,
      })
        .setLngLat(coordinates)
        .setDOMContent(popupContainer!)
        .addTo(glmap);

      dispatch("popupOpen", currentProperties);
    });

    glmap.on("mousemove", "fire", (e) => {
      const features = e.features;
      if (!features || features.length === 0) return;

      const properties = features[0].properties;

      currentProperties = properties as FireProperties;

      const coordinates = e.lngLat;
      if (popup)
        // Move the popup to the new coordinates
        popup.setLngLat(coordinates);
    });

    glmap.on("mouseleave", "fire", () => {
      if (popup) {
        popup.remove();
        popup = null;
        currentProperties = null;
      }
    });
  });

  const handlePopupOpen = (properties: any) => {
    currentProperties = properties as FireProperties;
    console.log(properties);
  };
</script>

<div id="map" />

<div bind:this={popupContainer}>
  {#if currentProperties}
    <PopupContent
      properties={currentProperties}
      on:popupOpen={handlePopupOpen}
    />
  {/if}
</div>

<style>
  #map {
    height: 80vh;
  }
</style>
