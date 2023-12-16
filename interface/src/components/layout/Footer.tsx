import { ExternalLink } from "@/components/layout/ExternalLink";
import { ThemeSwitcher } from "@/components/layout/ThemeSwitcher";
import { COMPANY_NAME, COMPANY_URL, GITHUB_URL, X_URL } from "@/lib/constants";

const navigation = [
  {
    name: "X",
    href: X_URL,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    icon: (props: any) => (
      <svg
        fill="currentColor"
        viewBox="0 0 48 48"
        width="24px"
        height="24px"
        clipRule="evenodd"
        baseProfile="basic"
        {...props}
      >
        <polygon fill="#616161" points="41,6 9.929,42 6.215,42 37.287,6" />
        <polygon
          fill="#fff"
          fillRule="evenodd"
          points="31.143,41 7.82,7 16.777,7 40.1,41"
          clipRule="evenodd"
        />
        <path
          fill="#616161"
          d="M15.724,9l20.578,30h-4.106L11.618,9H15.724 M17.304,6H5.922l24.694,36h11.382L17.304,6L17.304,6z"
        />
      </svg>
    ),
  },
  {
    name: "GitHub",
    href: GITHUB_URL,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    icon: (props: any) => (
      <svg fill="currentColor" viewBox="0 0 24 24" {...props}>
        <path
          fillRule="evenodd"
          d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"
          clipRule="evenodd"
        />
      </svg>
    ),
  },
];

export const Footer = () => {
  const currentYear = new Date().getFullYear();
  return (
    <footer className="bg-primary">
      <div className="flex flex-wrap items-center justify-between px-4 py-6 sm:px-6 md:justify-between lg:px-8">
        <div className="col-span-full md:order-2">
          <p className="text-secondary text-center text-sm">
            &copy; {currentYear}{" "}
            <ExternalLink href={COMPANY_URL} text={COMPANY_NAME} />. All rights
            reserved.
          </p>
        </div>

        <div className="mt-8 flex justify-center space-x-6 md:order-3 md:mt-0">
          {navigation.map((item) => (
            <ExternalLink
              key={item.name}
              href={item.href}
              className="text-secondary text-hover"
            >
              <>
                <span className="sr-only">{item.name}</span>
                <item.icon className="h-6 w-6" aria-hidden="true" />
              </>
            </ExternalLink>
          ))}
        </div>

        {<ThemeSwitcher className="text-hover mt-8 md:order-1 md:mt-0" />}
      </div>
    </footer>
  );
};
