import { Fragment } from "react";
import { Transition } from "@headlessui/react";
import {
  CheckCircleIcon,
  ExclamationCircleIcon,
  InformationCircleIcon,
  XCircleIcon,
} from "@heroicons/react/24/outline";
import { XMarkIcon } from "@heroicons/react/24/solid";

function getKindInfo(kind: "success" | "warning" | "error" | "info") {
  if (kind === "success")
    return {
      icon: CheckCircleIcon,
      iconColor: "text-green-500 dark:text-green-400",
    };
  if (kind === "warning")
    return {
      icon: ExclamationCircleIcon,
      iconColor: "text-yellow-500 dark:text-yellow-400",
    };
  if (kind === "error")
    return { icon: XCircleIcon, iconColor: "text-red-600 dark:text-red-500" };
  return {
    icon: InformationCircleIcon,
    iconColor: "text-blue-500 dark:text-blue-400",
  };
}

interface Props {
  show: boolean;
  setShow: (show: boolean) => void;
  kind: "success" | "warning" | "error" | "info";
  title: string;
  description?: string;
}

export const Notification = ({
  show,
  setShow,
  kind = "info",
  title,
  description,
}: Props) => {
  const { icon: Icon, iconColor } = getKindInfo(kind);

  const bgColor = "bg-gray-50 dark:bg-gray-800";
  const titleTextColor = "text-primary";
  const descriptionTextColor = "text-secondary";

  return (
    <>
      {/* Global notification live region, render this permanently at the end of the document */}
      <div
        aria-live="assertive"
        className="pointer-events-none fixed inset-0 flex items-end px-4 py-6 sm:items-start sm:p-6"
      >
        <div className="flex w-full flex-col items-center space-y-4 sm:items-end">
          {/* Notification panel, dynamically insert this into the live region when it needs to be displayed */}
          <Transition
            show={show}
            as={Fragment}
            enter="transform ease-out duration-300 transition"
            enterFrom="translate-y-2 opacity-0 sm:translate-y-0 sm:translate-x-2"
            enterTo="translate-y-0 opacity-100 sm:translate-x-0"
            leave="transition ease-in duration-200"
            leaveFrom="opacity-100"
            leaveTo="opacity-0"
          >
            <div
              className={`pointer-events-auto w-full max-w-sm overflow-hidden rounded-lg shadow-lg ring-1 ring-black ring-opacity-5 ${bgColor}`}
            >
              <div className="p-4">
                <div className="flex items-start">
                  <div className="flex-shrink-0">
                    <Icon
                      className={`h-6 w-6 ${iconColor}`}
                      aria-hidden="true"
                    />
                  </div>
                  <div className="ml-3 w-0 flex-1 pt-0.5">
                    <p className={`text-sm font-medium ${titleTextColor}`}>
                      {title}
                    </p>
                    <p className={`mt-1 text-sm ${descriptionTextColor}`}>
                      {description}
                    </p>
                  </div>
                  <div className="ml-4 flex flex-shrink-0">
                    <button
                      type="button"
                      className={`inline-flex rounded-md ${bgColor} ${titleTextColor} text-hover focus:outline-none`}
                      onClick={() => {
                        setShow(false);
                      }}
                    >
                      <span className="sr-only">Close</span>
                      <XMarkIcon className="h-5 w-5" aria-hidden="true" />
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </Transition>
        </div>
      </div>
    </>
  );
};
