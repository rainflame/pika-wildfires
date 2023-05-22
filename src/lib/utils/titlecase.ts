const toTitleCase = (input: string | undefined): string => {
  if (!input) return "";
  return input.toLowerCase().replace(/(^|\s|-|\(|\()\w/g, (match) => {
    return match.toUpperCase();
  });
};

export { toTitleCase };
