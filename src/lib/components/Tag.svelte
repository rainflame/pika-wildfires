<script lang="ts">
  import { slide } from "svelte/transition";
  import Label from "./Label.svelte";

  export let selected: boolean = false;
  export let text: string | null = null;
</script>

<button class="tag {selected ? 'selected' : null}" on:click>
  <slot name="icon" />
  {#if text}
    <span
      class="tag-text"
      transition:slide={{
        duration: 200,
        axis: "x",
      }}
    >
      <Label>{text}</Label>
    </span>
  {/if}
</button>

<style>
  .tag {
    display: flex;
    height: 20px;
    padding: 2px 6px;
    justify-content: center;
    align-items: center;
    gap: 4px;

    border-radius: 50px;

    cursor: pointer;

    border: none;
    transition: 0.3s ease-in-out all;
    background-color: var(--secondary);
    color: var(--greyscale-20);

    border: 1px solid var(--greyscale-50, #333);
    box-shadow: 0px 2px 4px 0px rgba(0, 0, 0, 0.15),
      0px 1px 0px 0px rgba(255, 255, 255, 0.3) inset;

    transition: 0.3s ease-in-out all;
  }

  .tag:hover {
    background-color: var(--secondary-hover);
  }

  .selected {
    background-color: var(--primary);
  }

  .selected:hover {
    background-color: var(--primary-hover);
  }

  .tag-text {
    overflow: hidden;
    white-space: nowrap;
    width: 100px;
  }
</style>
