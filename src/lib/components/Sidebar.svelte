<script lang="ts">
  import { fly } from "svelte/transition";
  import { quintOut } from "svelte/easing";
  import { map } from "$lib/stores/map";
  import type { FilterSpecification } from "maplibre-gl";
  import DoubleSlider from "./DoubleSlider.svelte";
  import { createEventDispatcher } from "svelte";

  export let sidebarWidth = 300;
  export let transitionDuration = 250;
  let open = true;

  const dispatch = createEventDispatcher();

  $: {
    dispatch("sidebarVisibilityChange", { open });
  }

  const addFilter = (layerName: string, newFilterConditions: any[]) => {
    const existingFilter = $map?.getFilter(layerName);

    const combinedFilter: FilterSpecification = existingFilter
      ? ["all", existingFilter, ...newFilterConditions]
      : ["all", ...newFilterConditions];

    $map?.setFilter("fire", combinedFilter);
  };

  const setFilter = () => {
    addFilter("fire", [[">=", ["get", "YEAR"], 1950]]);
  };

  const setSizeFilter = () => {
    addFilter("fire", [[">=", ["get", "ACRES"], 2000]]);
  };

  const setColors = () => {
    $map?.setPaintProperty("fire", "fill-color", [
      "interpolate",
      ["linear"],
      ["get", "YEAR"],
      1950,
      "rgba(255, 0, 0, 0.1)",
      2010,
      "rgba(255, 0, 0, 0.5)",
      2023,
      "rgba(255, 0, 0, 1)",
    ]);
  };
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
    <h1>Fires</h1>
    <DoubleSlider start={0} end={1} />
    <button class="close-sidebar" on:click={() => (open = false)}>X</button>
    <button on:click={setFilter}>Filter out &lt; 1950</button>
    <button on:click={setSizeFilter}>Filter out &lt; 2k acres</button>
    <button on:click={setColors}>Color by year</button>
  </div>
{:else}
  <button class="open-sidebar" on:click={() => (open = !open)}>Open</button>
{/if}

<style>
  .sidebar {
    height: 100vh;
    position: absolute;
    background-color: white;
    z-index: 1000;
    padding: 20px;
  }

  .close-sidebar {
    position: absolute;
    right: 0;
    top: 0;
  }

  .open-sidebar {
    position: absolute;
    left: 0;
    top: 0;
    z-index: 999;
  }
</style>
