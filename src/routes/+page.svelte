<script type="ts">
  import Sidebar from "$lib/components/Sidebar.svelte";
  import Map from "$lib/components/Map.svelte";

  let sidebarOpen = true;
  let sidebarWidth = 300;
  let transitionDuration = 500;
</script>

<Sidebar
  {sidebarWidth}
  {transitionDuration}
  on:sidebarVisibilityChange={(e) => (sidebarOpen = e.detail.open)}
/>
<Map {transitionDuration} leftPadding={sidebarOpen ? sidebarWidth + 60 : 0} />
