import { writable } from "svelte/store";
import type { Map } from "maplibre-gl";

const map = writable<Map | null>(null);

export { map };
