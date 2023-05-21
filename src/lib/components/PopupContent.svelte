<script lang="ts">
  export let properties: {
    FIRENAME: string;
    FIREYEAR: number;
    GISACRES: number;
    STATCAUSE: string;
  } | null;
</script>

<div>
  <h3>{properties?.FIRENAME}</h3>
  <p>Year: {properties?.FIREYEAR}</p>
  <p>Size: {properties?.GISACRES}</p>
  <p>Cause: {properties?.STATCAUSE}</p>
</div>
