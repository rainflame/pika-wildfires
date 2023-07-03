export function formatLargeNumber(number: number): string {
  if (number < 1000) {
    return number.toString();
  } else {
    const thousands = Math.floor(number / 1000);
    return `${thousands}k`;
  }
}
