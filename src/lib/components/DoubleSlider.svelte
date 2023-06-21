<script lang="ts">
  import { clamp } from "$lib/utils/clamp";

  export let start = 0;
  export let end = 1;

  let leftHandle: HTMLDivElement;
  let body: HTMLDivElement;
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
      const p = Math.min(Math.max((evt.detail.x - left) / parentWidth, 0), 1);
      if (which === "start") {
        start = p;
        end = Math.max(end, p);
      } else {
        start = Math.min(p, start);
        end = p;
      }
    };
  }

  function setHandlesFromBody(evt: CustomEvent) {
    const { width } = body.getBoundingClientRect();
    const { left, right } = slider.getBoundingClientRect();
    const parentWidth = right - left;
    const leftHandleLeft = leftHandle.getBoundingClientRect().left;
    const pxStart = clamp(
      leftHandleLeft + evt.detail.dx - left,
      0,
      parentWidth - width
    );
    const pxEnd = clamp(pxStart + width, width, parentWidth);
    const pStart = pxStart / parentWidth;
    const pEnd = pxEnd / parentWidth;
    start = pStart;
    end = pEnd;
  }
</script>

<div class="double-range-container">
  <div class="slider" bind:this={slider}>
    <div
      class="body"
      bind:this={body}
      use:draggable
      on:dragmove|preventDefault|stopPropagation={setHandlesFromBody}
      style="
				left: {100 * start}%;
				right: {100 * (1 - end)}%;
			"
    />
    <div
      class="handle"
      bind:this={leftHandle}
      data-which="start"
      use:draggable
      on:dragmove|preventDefault|stopPropagation={setHandlePosition("start")}
      style="
				left: {100 * start}%
			"
    />
    <div
      class="handle"
      data-which="end"
      use:draggable
      on:dragmove|preventDefault|stopPropagation={setHandlePosition("end")}
      style="
				left: {100 * end}%
			"
    />
  </div>
</div>

<style>
  .double-range-container {
    width: 100%;
    height: 20px;
    user-select: none;
    box-sizing: border-box;
    white-space: nowrap;
  }
  .slider {
    position: relative;
    width: 100%;
    height: 6px;
    top: 50%;
    transform: translate(0, -50%);
    background-color: #e2e2e2;
    box-shadow: inset 0 7px 10px -5px #4a4a4a, inset 0 -1px 0px 0px #9c9c9c;
    border-radius: 1px;
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
    background-color: #fdfdfd;
    border: 1px solid #7b7b7b;
    transform: translate(-50%, -50%);
  }
  /* .handle[data-which="end"]:after{
		transform: translate(-100%, -50%);
	} */
  .handle:active:after {
    background-color: #ddd;
    z-index: 9;
  }
  .body {
    top: 0;
    position: absolute;
    background-color: #34a1ff;
    bottom: 0;
  }
</style>