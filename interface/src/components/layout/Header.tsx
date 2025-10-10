import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/router";
import { ClipboardDocumentIcon } from "@heroicons/react/24/solid";
import { Notification } from "@/components/ui/Notification";
import { COMPANY_NAME, CREATEX_ADDRESS, SITE_NAME } from "@/lib/constants";
import { copyToClipboard } from "@/lib/utils";

const NavLink = ({
  path,
  label,
  currentPath,
  className,
}: {
  path: string;
  label: string;
  currentPath: string;
  className?: string;
}) => {
  const activeClass = path === currentPath ? "font-bold" : "";
  return (
    <Link
      href={path}
      className={`text-secondary text-base ${activeClass} ${className}`}
      target={path.startsWith("http") ? "_blank" : undefined}
    >
      {label}
    </Link>
  );
};

export const Header = () => {
  const currentPath = useRouter().pathname;

  // -------- Copy Address to Clipboard --------
  const [showNotification, setShowNotification] = useState(false);

  const onCopy = (text: string) => {
    copyToClipboard(text);
    setShowNotification(true);
    setTimeout(() => setShowNotification(false), 3000);
  };

  // -------- Render --------
  return (
    <header>
      <Notification
        show={showNotification}
        setShow={setShowNotification}
        kind="success"
        title="Address copied to clipboard!"
      />

      <div>
        <div className="flex items-center justify-between px-4 py-6 sm:px-6 md:space-x-10">
          <div>
            <Link href="/" className="flex">
              <span className="sr-only">{COMPANY_NAME}</span>
              <span className="text-accent font-mono font-bold">
                {SITE_NAME}
              </span>
            </Link>
          </div>
          <div>
            <NavLink
              path="/deployments"
              label="Deployments"
              className="text-hover mr-4"
              currentPath={currentPath}
            />
            <NavLink
              path="/abi"
              label="ABI"
              className="text-hover mr-4"
              currentPath={currentPath}
            />
            <NavLink
              path="https://github.com/pcaversaccio/createx"
              label="Documentation"
              className="text-hover"
              currentPath={currentPath}
            />
          </div>
        </div>
      </div>
      <div className="flex items-center justify-center">
        <div className="mx-auto h-auto w-auto rounded-full text-center">
          <p className="text-accent text-xs whitespace-nowrap opacity-80">
            Deployment Address
          </p>
          <div className="flex items-center">
            <pre className="text-sm">
              <code className="font-semibold">{CREATEX_ADDRESS}</code>
            </pre>
            <ClipboardDocumentIcon
              className="ml-3 h-4 w-4 cursor-pointer"
              onClick={() => onCopy(CREATEX_ADDRESS)}
            />
          </div>
        </div>
      </div>
    </header>
  );
};
