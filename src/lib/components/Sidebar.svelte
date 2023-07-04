<script lang="ts">
  import { fly } from "svelte/transition";
  import { quintOut } from "svelte/easing";
  import { createEventDispatcher } from "svelte";
  import { onMount } from "svelte";

  import { map } from "$lib/stores/map";

  import type { FilterSpecification } from "maplibre-gl";

  import DoubleSlider from "./DoubleSlider.svelte";
  import Button from "./Button.svelte";
  import Label from "./Label.svelte";
  import Divider from "./Divider.svelte";

  import OpenSidebar from "./Icons/OpenSidebar.svelte";
  import CloseSidebar from "./Icons/CloseSidebar.svelte";

  import { formatLargeNumber } from "$lib/utils/formatLargeNumber";
  import { normalize } from "$lib/utils/normalize";
  import Tag from "./Tag.svelte";
  import Drop from "./Icons/Drop.svelte";
  import type { FireProperties } from "$lib/types/fire";

  export let sidebarWidth = 300;
  export let transitionDuration = 250;

  let open = true;

  let coloredBy: keyof FireProperties | null = null;

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

  onMount(() => {
    adjustYearMax(DEFAULT_YEAR_MAX);
    adjustYearMin(DEFAULT_YEAR_MIN);
    adjustSizeMax(DEFAULT_SIZE_MAX);
    adjustSizeMin(DEFAULT_SIZE_MIN);
  });

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

  const toggleFill = (property: keyof FireProperties) => {
    if (coloredBy === property) {
      coloredBy = null;
    } else {
      coloredBy = property;
    }
  };

  $: {
    if ($map?.loaded()) {
      if (coloredBy === "YEAR") {
        $map?.setPaintProperty("fire", "fill-color", [
          "interpolate",
          ["linear"],
          ["get", "YEAR"],
          filter[0][2],
          "rgba(255, 0, 0, 0.1)",
          filter[1][2],
          "rgba(255, 0, 0, 1)",
        ]);
      } else if (coloredBy === "ACRES") {
        $map?.setPaintProperty("fire", "fill-color", [
          "interpolate",
          ["linear"],
          ["get", "ACRES"],
          filter[2][2],
          "rgba(255, 0, 0, 0.1)",
          filter[3][2],
          "rgba(255, 0, 0, 1)",
        ]);
      } else if (coloredBy === null) {
        $map?.setPaintProperty("fire", "fill-color", "rgba(0, 0, 0, 0.5)");
      }
    }
  }
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

    <Divider />

    <div>
      <div class="control-label">
        <Label>Fire year</Label>
        <Tag
          text={coloredBy === "YEAR" ? "Colored by year" : null}
          selected={coloredBy === "YEAR"}
          on:click={() => toggleFill("YEAR")}
        >
          <Drop size={16} slot="icon" filled={coloredBy === "YEAR"} />
        </Tag>
      </div>
      <DoubleSlider
        min={1900}
        max={2023}
        defaultMin={DEFAULT_YEAR_MIN}
        defaultMax={DEFAULT_YEAR_MAX}
        onMaxChange={adjustYearMax}
        onMinChange={adjustYearMin}
        formatDisplayNumber={(n) => n.toString()}
        colorInterpolate={coloredBy === "YEAR"
          ? {
              start: "#C3C1C1",
              end: "rgba(255, 0, 0, 1)",
            }
          : null}
      />
    </div>

    <div>
      <div class="control-label">
        <Label>Fire size in acres</Label>
        <Tag
          text={coloredBy === "ACRES" ? "Colored by size" : null}
          selected={coloredBy === "ACRES"}
          on:click={() => toggleFill("ACRES")}
        >
          <Drop size={16} slot="icon" filled={coloredBy === "ACRES"} />
        </Tag>
      </div>
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
        colorInterpolate={coloredBy === "ACRES"
          ? {
              start: "#C3C1C1",
              end: "rgba(255, 0, 0, 1)",
            }
          : null}
      />
    </div>

    <Divider />

    <div class="description">
      Data sourced from the <a
        href="https://catalog.data.gov/dataset/national-usfs-fire-perimeter-feature-layer-bb7cd"
        target="_blank">USFS</a
      >,
      <a
        href="https://gbp-blm-egis.hub.arcgis.com/datasets/BLM-EGIS::blm-natl-fire-perimeters-polygon/about"
        target="_blank">BLM</a
      >, and
      <a
        href="https://data-nifc.opendata.arcgis.com/datasets/nifc::wfigs-interagency-fire-perimeters/about"
        target="_blank">NIFC</a
      >. The combined dataset is a work in progress and imperfect; some fires
      may be repeated, missing, or incorrectly sized.
    </div>

    <div class="description">Last updated July 3, 2023.</div>

    <div class="close-sidebar">
      <Button on:click={() => (open = false)}
        ><CloseSidebar slot="icon" /></Button
      >
    </div>
  </div>
{:else}
  <div class="open-sidebar">
    <Button on:click={() => (open = true)}><OpenSidebar slot="icon" /></Button>
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
    display: flex;
    flex-direction: column;
    gap: 16px;
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

  .description {
    color: var(--greyscale-20);
  }

  .control-label {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
</style>
