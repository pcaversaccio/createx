export const classNames = (...classes: string[]) =>
  classes.filter(Boolean).join(" ");

export const copyToClipboard = (text: string) => {
  navigator.clipboard.writeText(text).then(
    () => console.log("Copying to clipboard was successful!"),
    (err) => console.error("Could not copy text to clipboard: ", err),
  );
};
