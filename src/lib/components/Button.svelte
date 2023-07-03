<script lang="ts">
  type ButtonVariant = "primary" | "secondary";

  export let variant: ButtonVariant = "secondary";
</script>

<button class={variant} on:click>
  <slot />
</button>

<style>
  button {
    display: inline-flex;
    padding: 6px 10px;
    justify-content: center;
    align-items: center;
    gap: 10px;
    cursor: pointer;

    border-radius: var(--radius-sm);
    border: 1px solid var(--greyscale-20, #333);
    box-shadow: 0px 2px 4px 0px rgba(0, 0, 0, 0.15),
      0px 1px 0px 0px rgba(255, 255, 255, 0.3) inset;

    transition: 0.3s ease-in-out all;
  }

  .primary {
    background: var(--primary);
  }

  .primary:hover {
    background: var(--primary-hover);
    box-shadow: 0px 2px 6px 0px rgba(0, 0, 0, 0.4),
      0px 1px 0px 0px rgba(255, 255, 255, 0.3) inset;
  }

  .secondary {
    background: var(--secondary);
  }

  .secondary:hover {
    background: var(--secondary-hover);
    box-shadow: 0px 2px 6px 0px rgba(0, 0, 0, 0.4),
      0px 1px 0px 0px rgba(255, 255, 255, 0.3) inset;
  }
</style>
