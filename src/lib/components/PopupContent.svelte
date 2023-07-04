<script lang="ts">
  import type { FireProperties } from "$lib/types/fire";
  import { toTitleCase } from "$lib/utils/titlecase";
  import Divider from "./Divider.svelte";
  import Label from "./Label.svelte";

  export let properties: Array<FireProperties>;
</script>

<div class="popup-content">
  {#each properties as fire}
    <div class="fire-info">
      <div class="fire-title">
        {fire.NAME ? toTitleCase(fire?.NAME) : "Unnamed Fire"}
      </div>
      <Divider />
      <div class="fire-stat">
        <Label>Year</Label>
        {fire?.YEAR}
      </div>
      <div class="fire-stat">
        <Label>Size</Label>{Math.round(fire?.ACRES || 0).toLocaleString("en")} Acres
      </div>
      <div class="fire-stat"><Label>Cause</Label>{fire?.CAUSE}</div>
      <div class="fire-stat"><Label>Source</Label>{fire?.SOURCE}</div>
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
    font-family: var(--sans);
    width: 150px;
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }
  .fire-title {
    font-size: 1rem;
    font-weight: 600;
  }

  .fire-stat {
    display: flex;
    gap: 0.5rem;
    flex-direction: row;
  }
</style>
