<script lang="ts">
  import { map } from "$lib/stores/map";
  import type { FilterSpecification } from "maplibre-gl";

  const addFilter = (layerName: string, newFilterConditions: any[]) => {
    const existingFilter = $map?.getFilter(layerName);

    const combinedFilter: FilterSpecification = existingFilter
      ? ["all", existingFilter, ...newFilterConditions]
      : ["all", ...newFilterConditions];

    $map?.setFilter("fire", combinedFilter);
  };

  const setFilter = () => {
    addFilter("fire", [[">=", ["get", "FIREYEAR"], 1950]]);
  };

  const setSizeFilter = () => {
    addFilter("fire", [[">=", ["get", "GISACRES"], 2000]]);
  };

  const setColors = () => {
    $map?.setPaintProperty("fire", "fill-color", [
      "interpolate",
      ["linear"],
      ["get", "FIREYEAR"],
      1950,
      "rgba(255, 0, 0, 0.1)",
      2023,
      "rgba(255, 0, 0, 1)",
    ]);
  };
</script>

<div>
  <button on:click={setFilter}>Filter out &lt; 1950</button>
  <button on:click={setSizeFilter}>Filter out &lt; 2k acres</button>
  <button on:click={setColors}>Color by year</button>
</div>
