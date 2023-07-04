import { writable } from "svelte/store";
import type { FilterArray } from "$lib/types/filter";

const filter = writable<FilterArray | null>(null);

export { filter };
