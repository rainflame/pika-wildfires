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

  export let colorInterpolate: { start: string; end: string } | null = null;

  let startLabel: HTMLDivElement;
  let endLabel: HTMLDivElement;

  let pxFromStart = 0;
  let pxFromEnd = 0;

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

    pxFromStart = startLabel.getBoundingClientRect().x;
    // TODO: should do the same for pxFromEnd

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
        pxFromStart = Math.max(evt.detail.x - left, 0);
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
        pxFromEnd = Math.max(right - evt.detail.x, 0);
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

<div
  class="double-range-container"
  style={colorInterpolate
    ? `--start-handle-color: ${colorInterpolate.start}; --end-handle-color: ${colorInterpolate.end};`
    : null}
>
  <div class="slider" bind:this={slider}>
    <div
      class="body"
      style="
				left: {100 * start.percent}%;
				right: {100 * (1 - end.percent)}%;
                {colorInterpolate
        ? `background-image: linear-gradient(to right, ${colorInterpolate.start}, ${colorInterpolate.end});`
        : null}
			"
    />
    <div
      class="handle start"
      data-which="start"
      use:draggable
      on:dragmove|preventDefault|stopPropagation={setHandlePosition("start")}
      style="
				left: {100 * start.percent}%
			"
    >
      <div
        class="handle-label"
        bind:this={startLabel}
        style={pxFromStart < startLabel?.getBoundingClientRect().width / 2
          ? `transform: translate(calc(-50% + ${
              startLabel?.getBoundingClientRect().width / 2 - pxFromStart
            }px), -50%);`
          : null}
      >
        {start.value}
      </div>
    </div>
    <div
      class="handle end"
      data-which="end"
      use:draggable
      on:dragmove|preventDefault|stopPropagation={setHandlePosition("end")}
      style="
				left: {100 * end.percent}%
			"
    >
      <div
        class="handle-label"
        bind:this={endLabel}
        style={pxFromEnd < endLabel?.getBoundingClientRect().width / 2
          ? `transform: translate(calc(-50% - ${
              endLabel?.getBoundingClientRect().width / 2 - pxFromEnd
            }px), -50%);`
          : null}
      >
        {end.value}
      </div>
    </div>
  </div>
</div>

<style>
  .double-range-container {
    width: 100%;
    padding-top: 1rem;
    padding-bottom: 1.5rem;
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

  .handle.start {
    z-index: 1000;
  }

  .handle.end {
    z-index: 999;
  }

  .handle.start::after {
    background-color: var(--start-handle-color, var(--primary));
  }

  .handle.start:active:after {
    background-color: color-mix(
      in srgb,
      var(--start-handle-color, var(--primary)) 85%,
      rgb(0, 0, 0)
    );
  }

  .handle.end::after {
    background-color: var(--end-handle-color, var(--primary));
  }

  .handle.end:active:after {
    background-color: color-mix(
      in srgb,
      var(--end-handle-color, var(--primary)) 85%,
      rgb(0, 0, 0)
    );
  }

  .handle:active:after {
    background-color: var(--primary-hover);
    z-index: 9;
  }

  .handle-label {
    position: absolute;
    top: 15px;
    background-color: var(--white);
    padding: 0px 2px;
    border-radius: var(--radius-sm);
    transform: translate(-50%, -50%);
  }

  .body {
    top: 0;
    position: absolute;
    background-color: var(--primary);
    bottom: 0;
  }
</style>
