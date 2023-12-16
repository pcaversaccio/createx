import { useEffect, useRef, useState } from "react";
import {
  ArrowTopRightOnSquareIcon,
  ChevronDownIcon,
} from "@heroicons/react/20/solid";
import { ExternalLink } from "@/components/layout/ExternalLink";
import { Head } from "@/components/layout/Head";
import { LoadingSpinner } from "@/components/ui/LoadingSpinner";

interface Deployment {
  name: string;
  chainId: number;
  url: string;
  address?: `0x${string}`;
}

const Deployments = () => {
  // -------- Fetch deployments --------
  const [deployments, setDeployments] = useState([] as Deployment[]);
  const [isLoading, setIsLoading] = useState(true);
  const deploymentsUrl =
    "https://github.com/pcaversaccio/createx/blob/main/deployments/deployments.json";
  const deploymentsUrlRaw =
    "https://raw.githubusercontent.com/pcaversaccio/createx/main/deployments/deployments.json";

  useEffect(() => {
    setIsLoading(true);
    fetch(deploymentsUrlRaw)
      .then((response) => response.json())
      .then((data) => setDeployments(data))
      .catch((error) => console.error("Error:", error))
      .finally(() => setIsLoading(false));
  }, []);

  // -------- Focus search input when user presses Cmd/Ctrl + K --------
  const searchInputRef = useRef<HTMLInputElement>(null);
  const modifierKey = navigator.userAgent.includes("Mac") ? "⌘ " : "Ctrl + ";

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === "k") {
        e.preventDefault();
        searchInputRef.current?.focus();
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, []);

  // -------- Sorting and filtering --------
  const [sortField, setSortField] = useState(null as "name" | "chainId" | null);
  const [sortDirection, setSortDirection] = useState("ascending");
  const [search, setSearch] = useState("");

  const onHeaderClick = (field: "name" | "chainId") => {
    if (sortField === field) {
      setSortDirection(
        sortDirection === "ascending" ? "descending" : "ascending",
      );
    } else {
      setSortField(field);
      setSortDirection("ascending");
    }
  };

  const sortedDeployments = deployments.sort((a, b) => {
    // Don't change default sort order if sort field is null.
    if (sortField === null) return 0;

    const aValue = a[sortField];
    const bValue = b[sortField];
    if (sortDirection === "ascending") {
      return aValue > bValue ? 1 : aValue < bValue ? -1 : 0;
    } else {
      return aValue < bValue ? 1 : aValue > bValue ? -1 : 0;
    }
  });

  const filteredDeployments = sortedDeployments.filter(
    (deployment) =>
      deployment.name.toLowerCase().includes(search.toLowerCase()) ||
      deployment.chainId.toString().includes(search),
  );

  const loadingDiv = () => (
    <div className="mt-8">
      <LoadingSpinner />
      <p className="text-secondary mt-4 italic">Fetching deployments...</p>
    </div>
  );

  const errorDiv = () => (
    <main className="grid min-h-full place-items-center px-6 py-24 sm:py-32 lg:px-8">
      <div className="text-center">
        <h1 className="text-primary mt-4 text-3xl font-bold tracking-tight sm:text-5xl">
          🥴Oops!
        </h1>
        <p className="text-secondary mt-6 text-base leading-7">
          Something went wrong fetching the list of deployments.
        </p>
        <div className="mt-10 flex items-center justify-center gap-x-6">
          <button
            onClick={() => window.location.reload()}
            className="rounded-md bg-blue-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-blue-500"
          >
            Please try again!
          </button>
          <ExternalLink
            href={deploymentsUrl}
            className="text-primary flex items-center text-sm font-semibold"
          >
            <>
              View as JSON{" "}
              <ArrowTopRightOnSquareIcon
                className="ml-2 h-4 w-4"
                aria-hidden="true"
              />
            </>
          </ExternalLink>
        </div>
      </div>
    </main>
  );

  const noDeploymentsDiv = () => (
    <div className="mt-10 grid min-h-full place-items-center">
      <div className="text-center">
        <p className="text-primary font-bold tracking-tight">
          No deployments found.
        </p>
        <p className="text-secondary mt-2 text-base leading-7">
          If you need CreateX deployed on a new chain,
          <br />
          please{" "}
          <ExternalLink
            href="https://github.com/pcaversaccio/createx/issues/new?assignees=pcaversaccio&labels=new+deployment+%E2%9E%95&projects=&template=deployment_request.yml&title=%5BNew-Deployment-Request%5D%3A+"
            text="open an issue"
          />{" "}
          on GitHub.
        </p>
      </div>
    </div>
  );

  const showDeploymentsDiv = () => (
    <div className="overflow-hidden rounded-lg shadow ring-1 ring-black ring-opacity-5">
      <table className="min-w-full divide-y divide-gray-300">
        <thead className="bg-gray-50 dark:bg-gray-700">
          <tr>
            <th
              scope="col"
              className="text-primary py-3.5 pl-4 pr-3 text-left text-sm font-semibold sm:pl-6"
            >
              <div
                className="group inline-flex cursor-pointer rounded-md p-1 hover:bg-gray-200 hover:dark:bg-gray-700"
                onClick={() => onHeaderClick("name")}
              >
                Name
                <span className="text-primary ml-2 flex-none rounded">
                  <ChevronDownIcon className="h-5 w-5" aria-hidden="true" />
                </span>
              </div>
            </th>
            <th
              scope="col"
              className="text-primary px-3 py-3.5 text-left text-sm font-semibold"
            >
              <div
                className="group inline-flex cursor-pointer rounded-md p-1 hover:bg-gray-200 hover:dark:bg-gray-700"
                onClick={() => onHeaderClick("chainId")}
              >
                Chain ID
                <span className="text-primary ml-2 flex-none rounded">
                  <ChevronDownIcon className="h-5 w-5" aria-hidden="true" />
                </span>
              </div>
            </th>
            <th scope="col" className="relative pr-4">
              <span className="sr-only">Edit</span>
            </th>
          </tr>
        </thead>
        <tbody className="cursor-pointer divide-y divide-gray-200 bg-white">
          {filteredDeployments.map((deployment) => (
            <tr
              key={`${deployment.chainId}-${deployment.name}`}
              className="group dark:bg-gray-800"
              onClick={() =>
                window.open(deployment.url, "_blank", "noopener,noreferrer")
              }
            >
              <td className="text-primary flex flex-col whitespace-nowrap py-4 pl-4 pr-3 text-sm font-medium sm:pl-6">
                {deployment.name}
                {deployment.address && (
                  <p className="text-secondary text-xs font-normal">
                    {`${deployment.address?.slice(
                      0,
                      6,
                    )}...${deployment.address?.slice(-4)}`}
                  </p>
                )}
              </td>
              <td className="text-secondary whitespace-nowrap px-3 py-4 text-sm">
                {deployment.chainId}
              </td>
              <td className="relative pr-4">
                <div className="hyperlink opacity-0 transition-opacity duration-200 group-hover:opacity-100">
                  <ArrowTopRightOnSquareIcon
                    className="h-4 w-4"
                    aria-hidden="true"
                  />
                  <span className="sr-only">
                    Open contract in block explorer
                  </span>
                </div>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      <div className="max-w-sm">
        <p className="text-secondary p-2 text-xs font-normal">
          Showing {filteredDeployments.length} of {deployments.length}{" "}
          deployments.
        </p>
      </div>
    </div>
  );

  const deploymentsTableDiv = () => (
    <>
      <div className="relative mb-4">
        <span className="text-secondary pointer-events-none absolute right-4 top-1/2 -translate-y-1/2 transform text-xs opacity-60 dark:opacity-70">
          {modifierKey}K
        </span>
        <input
          type="text"
          className="block w-full rounded-md border-gray-300 px-4 py-2 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          placeholder="Network name or chain ID..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          ref={searchInputRef}
        />
      </div>
      {filteredDeployments.length === 0 && noDeploymentsDiv()}
      {filteredDeployments.length > 0 && showDeploymentsDiv()}
    </>
  );

  // -------- Render --------
  return (
    <>
      <Head title="Deployments" description="CreateX deployments" />
      <div className="flex justify-center">
        <div className="-mx-4 -my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
          <div className="inline-block py-2 align-middle sm:px-6 lg:px-8">
            {isLoading && loadingDiv()}
            {!isLoading && deployments.length === 0 && errorDiv()}
            {!isLoading && deployments.length > 0 && deploymentsTableDiv()}
          </div>
        </div>
      </div>
    </>
  );
};

export default Deployments;
