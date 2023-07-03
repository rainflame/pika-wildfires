<script lang="ts">
  import { normalize } from "$lib/utils/normalize";
  import debounce from "lodash/debounce";
  import { onMount } from "svelte";

  export let min = 0;
  export let max = 10;

  export let defaultMin = 0;
  export let defaultMax = 10;

  export let onMinChange: (newMin: number) => any = (min) => {};
  export let onMaxChange: (newMax: number) => any = (max) => {};
  export let transformPercentToScale: (value: number) => number = (n) => n;
  export let transformScaleToPercent: (scale: number) => number = (n) => n;

  export let formatDisplayNumber: (n: number) => string;

  let start = { percent: 0, value: "0" };
  let end = { percent: 1, value: "1" };

  onMount(() => {
    start = {
      percent: transformScaleToPercent(
        normalize(defaultMin, min, max, 0, 1, false)
      ),
      value: formatDisplayNumber(defaultMin),
    };
    end = {
      percent: transformScaleToPercent(
        normalize(defaultMax, min, max, 0, 1, false)
      ),
      value: formatDisplayNumber(defaultMax),
    };

    onMinChange = debounce(onMinChange, 100);
    onMaxChange = debounce(onMaxChange, 100);
  });

  let slider: HTMLDivElement;

  function draggable(node: HTMLDivElement) {
    let x: number;
    let y: number;

    function handleMousedown(event: MouseEvent) {
      x = event.clientX;
      y = event.clientY;
      node.dispatchEvent(
        new CustomEvent("dragstart", {
          detail: { x, y },
        })
      );
      window.addEventListener("mousemove", handleMousemove);
      window.addEventListener("mouseup", handleMouseup);
      window.addEventListener("touchmove", handleTouchmove);
      window.addEventListener("touchend", handleTouchup);
    }

    function handleTouchdown(event: TouchEvent) {
      const e = event.touches[0];
      x = e.clientX;
      y = e.clientY;
      node.dispatchEvent(
        new CustomEvent("dragstart", {
          detail: { x, y },
        })
      );
      window.addEventListener("mousemove", handleMousemove);
      window.addEventListener("mouseup", handleMouseup);
      window.addEventListener("touchmove", handleTouchmove);
      window.addEventListener("touchend", handleTouchup);
    }

    function handleMousemove(event: MouseEvent) {
      const dx = event.clientX - x;
      const dy = event.clientY - y;
      x = event.clientX;
      y = event.clientY;
      node.dispatchEvent(
        new CustomEvent("dragmove", {
          detail: { x, y, dx, dy },
        })
      );
    }

    function handleTouchmove(event: TouchEvent) {
      const e = event.changedTouches[0];
      const dx = e.clientX - x;
      const dy = e.clientY - y;
      x = e.clientX;
      y = e.clientY;
      node.dispatchEvent(
        new CustomEvent("dragmove", {
          detail: { x, y, dx, dy },
        })
      );
    }

    function handleTouchup(event: TouchEvent) {
      const e = event.changedTouches[0];
      x = e.clientX;
      y = e.clientY;
      node.dispatchEvent(
        new CustomEvent("dragend", {
          detail: { x, y },
        })
      );
      window.removeEventListener("mousemove", handleMousemove);
      window.removeEventListener("mouseup", handleMouseup);
      window.removeEventListener("touchmove", handleTouchmove);
      window.removeEventListener("touchend", handleTouchup);
    }

    function handleMouseup(event: MouseEvent) {
      x = event.clientX;
      y = event.clientY;
      node.dispatchEvent(
        new CustomEvent("dragend", {
          detail: { x, y },
        })
      );
      window.removeEventListener("mousemove", handleMousemove);
      window.removeEventListener("mouseup", handleMouseup);
      window.removeEventListener("touchmove", handleTouchmove);
      window.removeEventListener("touchend", handleTouchup);
    }

    node.addEventListener("mousedown", handleMousedown);
    node.addEventListener("touchstart", handleTouchdown);

    return {
      destroy() {
        node.removeEventListener("mousedown", handleMousedown);
        node.removeEventListener("touchstart", handleTouchdown);
      },
    };
  }

  function setHandlePosition(which: "start" | "end") {
    return function (evt: { detail: { x: number } }) {
      const { left, right } = slider.getBoundingClientRect();
      const parentWidth = right - left;
      let p = Math.min(Math.max((evt.detail.x - left) / parentWidth, 0), 1);

      if (which === "start") {
        start = {
          percent: p,
          value: formatDisplayNumber(
            normalize(transformPercentToScale(p), 0, 1, min, max, true)
          ),
        };
        const endP = Math.max(end.percent, p);
        end = {
          percent: endP,
          value: formatDisplayNumber(
            normalize(transformPercentToScale(endP), 0, 1, min, max, true)
          ),
        };

        onMinChange(
          normalize(transformPercentToScale(p), 0, 1, min, max, true)
        );
      } else {
        end = {
          percent: p,
          value: formatDisplayNumber(
            normalize(transformPercentToScale(p), 0, 1, min, max, true)
          ),
        };

        const startP = Math.min(start.percent, p);
        start = {
          percent: startP,
          value: formatDisplayNumber(
            normalize(transformPercentToScale(startP), 0, 1, min, max, true)
          ),
        };
        onMaxChange(
          normalize(transformPercentToScale(p), 0, 1, min, max, true)
        );
      }
    };
  }
</script>

<div class="double-range-container">
  <div class="slider" bind:this={slider}>
    <div
      class="body"
      style="
				left: {100 * start.percent}%;
				right: {100 * (1 - end.percent)}%;
			"
    />
    <div
      class="handle"
      data-which="start"
      use:draggable
      on:dragmove|preventDefault|stopPropagation={setHandlePosition("start")}
      style="
				left: {100 * start.percent}%
			"
    >
      <div class="handle-label">
        {start.value}
      </div>
    </div>
    <div
      class="handle"
      data-which="end"
      use:draggable
      on:dragmove|preventDefault|stopPropagation={setHandlePosition("end")}
      style="
				left: {100 * end.percent}%
			"
    >
      <div class="handle-label">
        {end.value}
      </div>
    </div>
  </div>
</div>

<style>
  .double-range-container {
    width: 100%;
    height: 50px;
    user-select: none;
    white-space: nowrap;
  }
  .slider {
    border: 1px solid var(--greyscale-70);
    position: relative;
    width: 100%;
    height: 6px;
    top: 50%;
    transform: translate(0, -50%);
    background-color: var(--greyscale-80);
    border-radius: var(--radius-sm);
  }

  .handle {
    position: absolute;
    top: 50%;
    width: 0;
    height: 0;
  }

  .handle:after {
    content: " ";
    box-sizing: border-box;
    position: absolute;
    border-radius: 50%;
    width: 16px;
    height: 16px;
    background-color: var(--primary);
    border: 1px solid var(--greyscale-40);
    transform: translate(-50%, -50%);
    box-shadow: var(--light-height);
    cursor: ew-resize;
  }

  .handle:active:after {
    background-color: var(--primary-hover);
    z-index: 9;
  }

  .handle-label {
    position: absolute;
    top: 15px;
    transform: translate(-50%, -50%);
  }
  .body {
    top: 0;
    position: absolute;
    background-color: var(--primary);
    bottom: 0;
  }
</style>
