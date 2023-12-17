import { useEffect, useState } from "react";
import Image from "next/image";
import { Tab } from "@headlessui/react";
import {
  ArrowDownTrayIcon,
  ClipboardDocumentIcon,
} from "@heroicons/react/24/solid";
import { useTheme } from "next-themes";
import Prism from "prismjs";
import "prismjs/components/prism-json";
import "prismjs/components/prism-solidity";
import "prismjs/components/prism-typescript";
import { Head } from "@/components/layout/Head";
import { Notification } from "@/components/ui/Notification";
import {
  CREATEX_ABI,
  CREATEX_ABI_ETHERS,
  CREATEX_ABI_VIEM,
  CREATEX_SOLIDITY_INTERFACE,
} from "@/lib/constants";
import { classNames } from "@/lib/utils";
import { copyToClipboard } from "@/lib/utils";

const tabs = [
  {
    name: "Solidity",
    href: "#solidity",
    imgUri: "/solidity.png",
    imgSize: "sm",
    language: "solidity",
    abi: CREATEX_SOLIDITY_INTERFACE,
    filename: "ICreateX.sol",
    mimeType: "text/plain",
  },
  {
    name: "ethers.js",
    href: "#ethers-js",
    imgUri: "/ethersjs.png",
    language: "json",
    abi: CREATEX_ABI_ETHERS,
    filename: "ICreateX.json",
    mimeType: "text/plain",
  },
  {
    name: "viem",
    href: "#viem",
    imgUri: "/viem.png",
    language: "typescript",
    abi: CREATEX_ABI_VIEM,
    filename: "ICreateX.ts",
    mimeType: "text/plain",
  },
  {
    name: "JSON",
    href: "#json",
    imgUri: "/json.svg",
    imgSize: "sm",
    language: "json",
    abi: JSON.stringify(CREATEX_ABI, null, 2),
    filename: "ICreateX.json",
    mimeType: "application/json",
  },
];

const hashToIndex = () => {
  const anchor = window.location.hash || "#solidity";
  const index = tabs.findIndex((tab) => tab.href === anchor);
  return index === -1 ? 0 : index;
};

const indexToHash = (index: number) => {
  return tabs[index].href || "#solidity";
};

const Abi = () => {
  // -------- Syntax Highlighting --------
  const { resolvedTheme: theme } = useTheme();
  const [selectedTab, setSelectedTab] = useState(hashToIndex());
  const [showNotification, setShowNotification] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  const onTabChange = (index: number) => {
    // We set `isLoading` to true to fade out the content while the tab is changing, to avoid
    // briefly showing un-highlighted code. This is set to false again in the `useEffect` hook.
    setIsLoading(true);
    setSelectedTab(index);
    window.location.hash = indexToHash(index);
  };

  // This is required to re-highlight the code when the tab changes, and we use `setTimeout` with
  // a delay of 0 to ensure that the code is highlighted after the tab has changed. Otherwise the
  // `highlightAll` function runs before the code has been updated, so the code is not highlighted.
  useEffect(() => {
    setTimeout(() => {
      Prism.highlightAll();
      setIsLoading(false);
    }, 0);
  }, [selectedTab]);

  // We conditionally import the Prism theme based on the current theme, to adjust the syntax
  // highlighting to the theme. The logic in the `importTheme` function combined with the presence
  // of the `prism-light.css` and `prism-dark.css` files in the `public` folder is what allows us
  // to ensure all styles from the light theme are removed when the user toggles to the dark theme,
  // and vice versa.
  useEffect(() => {
    const importTheme = async () => {
      // Define the new stylesheet href based on the theme and get it's element.
      const newStylesheetHref =
        theme === "dark" ? "/prism-dark.css" : "/prism-light.css";
      const existingStylesheet = document.getElementById("dynamic-stylesheet");

      // If there's an existing stylesheet, remove it.
      existingStylesheet?.parentNode?.removeChild(existingStylesheet);

      // Create a new element for the new stylesheet, and append the stylesheet to the head.
      const newStylesheet = document.createElement("link");
      newStylesheet.rel = "stylesheet";
      newStylesheet.type = "text/css";
      newStylesheet.href = newStylesheetHref;
      newStylesheet.id = "dynamic-stylesheet";
      document.head.appendChild(newStylesheet);
    };
    importTheme();
  }, [theme]);

  // -------- Download and Copy ABI --------
  const onDownload = (content: string, filename: string, mimeType: string) => {
    const blob = new Blob([content], { type: mimeType });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");

    link.href = url;
    link.download = filename;
    link.style.display = "none";

    document.body.appendChild(link);
    link.click();

    setTimeout(() => {
      document.body.removeChild(link);
      URL.revokeObjectURL(url);
    }, 100);
  };

  const onCopy = (text: string) => {
    copyToClipboard(text);
    setShowNotification(true);
    setTimeout(() => setShowNotification(false), 3000);
  };

  // -------- Render --------
  return (
    <>
      <Head title="ABI" description="CreateX ABI in various formats" />

      <Notification
        show={showNotification}
        setShow={setShowNotification}
        kind="success"
        title={`${tabs[selectedTab].name} ABI copied to clipboard!`}
      />

      <Tab.Group selectedIndex={selectedTab} onChange={onTabChange}>
        <Tab.List className="space-x-4 overflow-x-auto whitespace-nowrap border-b border-gray-200 dark:border-gray-700 md:flex md:justify-center md:space-x-8">
          {tabs.map((tab) => {
            return (
              <Tab key={tab.name} className="focus:outline-0">
                {({ selected }) => (
                  <div
                    className={classNames(
                      "group inline-flex items-center px-1 py-3 text-sm font-medium",
                      selected
                        ? "text-accent border-b-2 border-b-blue-800 outline-none dark:border-b-blue-300"
                        : "text-secondary text-hover",
                    )}
                  >
                    <Image
                      src={tab.imgUri}
                      height={tab.imgSize === "sm" ? 16 : 20}
                      width={tab.imgSize === "sm" ? 16 : 20}
                      alt="JSON logo"
                      className="mr-2"
                      style={{
                        filter:
                          theme === "dark"
                            ? "invert(1) brightness(1) saturate(0)"
                            : undefined,
                      }}
                    />
                    {tab.name}
                  </div>
                )}
              </Tab>
            );
          })}
        </Tab.List>
        <Tab.Panels
          className="text-center"
          style={{ opacity: isLoading ? 0 : 1 }}
        >
          {tabs.map((tab) => {
            return (
              <Tab.Panel
                key={tab.name}
                className="relative mt-4 inline-block max-h-screen max-w-full overflow-x-auto overflow-y-auto text-sm shadow-md"
              >
                <button
                  className="absolute right-3 top-4 z-10 mr-10 rounded-md border border-gray-500 p-1 hover:border-black focus:outline-0 dark:border-gray-400 hover:dark:border-gray-200"
                  style={{
                    // Blur the background behind the copy button.
                    background: "rgba(0, 0, 0, 0.0)",
                    backdropFilter: "blur(4px)",
                  }}
                  onClick={() =>
                    onDownload(tab.abi, tab.filename, tab.mimeType)
                  }
                >
                  <ArrowDownTrayIcon className="h-4 w-4" />
                </button>
                <button
                  className="absolute right-3 top-4 z-10 rounded-md border border-gray-500 p-1 hover:border-black focus:outline-0 dark:border-gray-400 hover:dark:border-gray-200"
                  style={{
                    // Blur the background behind the copy button.
                    background: "rgba(0, 0, 0, 0.0)",
                    backdropFilter: "blur(4px)",
                  }}
                  onClick={() => onCopy(tab.abi)}
                >
                  <ClipboardDocumentIcon className="h-4 w-4" />
                </button>
                <pre className="rounded-lg">
                  <code className={`language-${tab.language}`}>{tab.abi}</code>
                </pre>
              </Tab.Panel>
            );
          })}
        </Tab.Panels>
      </Tab.Group>
    </>
  );
};

export default Abi;
