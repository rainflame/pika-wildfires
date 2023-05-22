<script lang="ts">
  import type { FireProperties } from "$lib/types/fire";
  import { toTitleCase } from "$lib/utils/titlecase";

  export let properties: Array<FireProperties>;
</script>

<div class="popup-content">
  {#each properties as fire}
    <div class="fire-info">
      <strong>{toTitleCase(fire?.NAME)}</strong>
      <div>Year: {fire?.YEAR}</div>
      <div>Size: {Math.round(fire?.ACRES || 0).toLocaleString("en")} Acres</div>
      <div>Cause: {fire?.CAUSE}</div>
      <div>Source: {fire?.SOURCE}</div>
    </div>
  {/each}
</div>

<style>
  .popup-content {
    width: 100%;
    display: flex;
    flex-direction: row;
  }

  .popup-content > * {
    flex-shrink: 0;
  }

  .fire-info {
    width: 150px;
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }
</style>
