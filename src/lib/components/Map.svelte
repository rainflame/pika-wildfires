<script lang="ts">
  import { map } from "$lib/stores/map";
  import { createEventDispatcher, onMount } from "svelte";
  import maplibregl from "maplibre-gl";
  import * as pmtiles from "pmtiles";
  import type { FireProperties } from "$lib/types/fire";
  import style from "$lib/assets/style.json";

  import "maplibre-gl/dist/maplibre-gl.css";
  import PopupContent from "./PopupContent.svelte";

  export let leftPadding = 0;
  export let transitionDuration = 250;

  const dispatch = createEventDispatcher();
  let popup: maplibregl.Popup | null = null;
  let popupContainer: HTMLElement | null = null;
  let currentProperties: Array<FireProperties> = [];

  onMount(() => {
    let protocol = new pmtiles.Protocol();
    maplibregl.addProtocol("pmtiles", protocol.tile);

    const glmap = new maplibregl.Map({
      container: "map",
      maxBounds: [
        [-127.850165, 29.983312],
        [-100.336147, 50.059513],
      ],
      center: [-116.418257, 45.630287],
      zoom: 5.35,
      style: {
        version: 8,
        zoom: 5,
        center: [-122.3917, 40.5865],
        // glyphs: "http://fonts.openmaptiles.org/{fontstack}/{range}.pbf",
        glyphs: "http://localhost:8080/{fontstack}/{range}.pbf",
        sources: {
          protomaps: {
            type: "vector",
            url: "pmtiles://http://localhost:8080/us-west.pmtiles",
            attribution:
              '<a href="https://protomaps.com">Protomaps</a> © <a href="https://openstreetmap.org">OpenStreetMap</a>',
          },
          fire: {
            type: "vector",
            url: "pmtiles://http://localhost:8080/fires.pmtiles",
            attribution: "USFS NIFC",
          },
        },
        layers: [
          ...(style.layers as maplibregl.LayerSpecification[]),
          //   ...layers("protomaps", "grayscale"),
          {
            id: "fire",
            source: "fire",
            "source-layer": "fire",
            type: "fill",
            paint: {
              "fill-color": "rgba(0,0,0,0.5)",
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

    glmap.on("zoom", () => {
      console.log(glmap.getZoom());
    });

    glmap.on("mouseenter", "fire", (e) => {
      const features = e.features;
      if (!features || features.length === 0) return;

      currentProperties = features.map((f) => f.properties as FireProperties);
      const coordinates = e.lngLat;

      popup = new maplibregl.Popup({
        closeButton: false,
        closeOnClick: false,
        anchor: "top",
      })
        .setLngLat(coordinates)
        .setDOMContent(popupContainer!)
        .addTo(glmap);

      dispatch("popupOpen", currentProperties);
    });

    glmap.on("mousemove", "fire", (e) => {
      const features = e.features;
      if (!features || features.length === 0) return;

      currentProperties = features.map((f) => f.properties as FireProperties);

      const coordinates = e.lngLat;
      if (popup)
        // Move the popup to the new coordinates
        popup.setLngLat(coordinates);
    });

    glmap.on("mouseleave", "fire", () => {
      if (popup) {
        popup.remove();
        popup = null;
        currentProperties = [];
      }
    });
  });

  const handlePopupOpen = (properties: any) => {
    currentProperties = properties;
  };

  $: {
    if ($map !== null)
      $map.easeTo({
        padding: { left: leftPadding },
        duration: transitionDuration,
      });
  }
</script>

<div id="map" />

<div bind:this={popupContainer} class="popup-container">
  {#if currentProperties}
    <PopupContent
      properties={currentProperties}
      on:popupOpen={handlePopupOpen}
    />
  {/if}
</div>

<style>
  #map {
    height: 100vh;
    width: 100vw;
  }

  :global(.maplibregl-popup) {
    max-width: none !important;
  }
</style>
