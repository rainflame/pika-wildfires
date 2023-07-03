export function normalize(
  value: number,
  oldMin: number,
  oldMax: number,
  newMin: number,
  newMax: number,
  round?: boolean
): number {
  const oldRange = oldMax - oldMin;
  const newRange = newMax - newMin;
  const normalizedValue = ((value - oldMin) * newRange) / oldRange + newMin;
  return round ? Math.round(normalizedValue) : normalizedValue;
}
