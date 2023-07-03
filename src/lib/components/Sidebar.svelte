<script lang="ts">
  import { fly } from "svelte/transition";
  import { quintOut } from "svelte/easing";
  import { map } from "$lib/stores/map";
  import type { FilterSpecification } from "maplibre-gl";
  import DoubleSlider from "./DoubleSlider.svelte";
  import { createEventDispatcher } from "svelte";
  import Close from "./Icons/Close.svelte";
  import Button from "./Button.svelte";
  import Sidebar from "./Icons/Sidebar.svelte";
  import { formatLargeNumber } from "$lib/utils/formatLargeNumber";
  import Label from "./Label.svelte";
  import { normalize } from "$lib/utils/normalize";

  export let sidebarWidth = 300;
  export let transitionDuration = 250;

  let open = true;

  const DEFAULT_YEAR_MAX = 2023;
  const DEFAULT_YEAR_MIN = 1970;

  const DEFAULT_SIZE_MAX = 380000;
  const DEFAULT_SIZE_MIN = 5000;

  let filter = [
    [">=", ["get", "YEAR"], DEFAULT_YEAR_MIN],
    ["<=", ["get", "YEAR"], DEFAULT_YEAR_MAX],
    [">=", ["get", "ACRES"], DEFAULT_SIZE_MIN],
    ["<=", ["get", "ACRES"], DEFAULT_SIZE_MAX],
  ];

  const dispatch = createEventDispatcher();

  $: {
    dispatch("sidebarVisibilityChange", { open });
  }

  const applyFilter = () => {
    $map?.setFilter("fire", ["all", ...filter] as FilterSpecification);
  };

  const adjustYearMax = (newMax: number) => {
    filter[1][2] = newMax;
    applyFilter();
  };

  const adjustYearMin = (newMin: number) => {
    filter[0][2] = newMin;
    applyFilter();
  };

  const adjustSizeMin = (newMin: number) => {
    filter[2][2] = newMin;
    applyFilter();
  };

  const adjustSizeMax = (newMax: number) => {
    filter[3][2] = newMax;
    applyFilter();
  };

  //   const setColors = () => {
  //     $map?.setPaintProperty("fire", "fill-color", [
  //       "interpolate",
  //       ["linear"],
  //       ["get", "YEAR"],
  //       1950,
  //       "rgba(255, 0, 0, 0.1)",
  //       2010,
  //       "rgba(255, 0, 0, 0.5)",
  //       2023,
  //       "rgba(255, 0, 0, 1)",
  //     ]);
  //   };
</script>

{#if open}
  <div
    class="sidebar"
    style={`width: ${sidebarWidth}px`}
    transition:fly={{
      duration: transitionDuration,
      easing: quintOut,
      x: -sidebarWidth,
      opacity: 0,
    }}
  >
    <h1 class="header">Historic wildfires of the western United States</h1>

    <Label>Year</Label>
    <DoubleSlider
      min={1900}
      max={2023}
      defaultMin={DEFAULT_YEAR_MIN}
      defaultMax={DEFAULT_YEAR_MAX}
      onMaxChange={adjustYearMax}
      onMinChange={adjustYearMin}
      formatDisplayNumber={(n) => n.toString()}
    />

    <Label>Size in acres</Label>
    <DoubleSlider
      min={0}
      max={380000}
      defaultMin={DEFAULT_SIZE_MIN}
      defaultMax={DEFAULT_SIZE_MAX}
      onMaxChange={adjustSizeMax}
      onMinChange={adjustSizeMin}
      formatDisplayNumber={formatLargeNumber}
      transformPercentToScale={(p) => {
        const logValue = Math.pow(
          10,
          p * Math.log10(1 / 0.001) + Math.log10(0.001)
        );
        return normalize(logValue, 0.001, 1, 0, 1);
      }}
      transformScaleToPercent={(s) => {
        const logValue = normalize(s, 0, 1, 0.001, 1);
        return (
          (Math.log10(logValue) - Math.log10(0.001)) / Math.log10(1 / 0.001)
        );
      }}
    />

    <div class="close-sidebar">
      <Button on:click={() => (open = false)}><Close /></Button>
    </div>
  </div>
{:else}
  <div class="open-sidebar">
    <Button on:click={() => (open = true)}><Sidebar /></Button>
  </div>
{/if}

<style>
  .header {
    margin-top: 4rem;
  }
  .sidebar {
    height: 100vh;
    position: absolute;
    background-color: white;
    z-index: 1000;
    padding: 20px;
  }

  .close-sidebar {
    position: absolute;
    padding: 10px;
    right: 0;
    top: 0;
  }

  .open-sidebar {
    position: absolute;
    left: 0;
    top: 0;
    padding: 10px;
    z-index: 999;
  }
</style>
