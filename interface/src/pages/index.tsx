import Link from "next/link";
import { Head } from "@/components/layout/Head";
import { SITE_DESCRIPTION } from "@/lib/constants";

const Home = () => {
  console.log(`
░██████╗██████╗░███████╗░█████╗░████████╗███████╗██╗░░██╗
██╔════╝██╔══██╗██╔════╝██╔══██╗╚══██╔══╝██╔════╝╚██╗██╔╝
██║░░░░░██████╔╝█████╗░░███████║░░░██║░░░█████╗░░░╚███╔╝░
██║░░░░░██╔══██╗██╔══╝░░██╔══██║░░░██║░░░██╔══╝░░░██╔██╗░
╚██████╗██║░░██║███████╗██║░░██║░░░██║░░░███████╗██╔╝░██╗
░╚═════╝╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝
`);
  const cards = [
    {
      id: 1,
      href: "/deployments",
      title: "Deployments",
      subtitle: "Deployed on 190+ chains",
    },
    { id: 2, href: "/abi", title: "ABI", subtitle: "In any format" },
    {
      id: 3,
      href: "https://github.com/pcaversaccio/createx",
      title: "Docs",
      subtitle: "Learn more",
    },
  ];

  return (
    <>
      <Head />
      <div className="mx-auto mt-6 w-full max-w-(--breakpoint-lg) sm:mt-20">
        <h1 className="text-accent mb-12 text-center text-3xl font-bold sm:text-4xl">
          {SITE_DESCRIPTION}
        </h1>
        <div className="mx-auto mt-12 w-full max-w-7xl">
          <dl className="mx-auto grid w-full grid-cols-1 gap-8 sm:grid-cols-3">
            {cards.map((card) => (
              <Link
                key={card.id}
                href={card.href}
                rel={
                  card.href.startsWith("http")
                    ? "noopener noreferrer"
                    : undefined
                }
                target={card.href.startsWith("http") ? "_blank" : undefined}
                className="bg-secondary flex w-full cursor-pointer flex-col items-center justify-center rounded-xl border border-blue-800/0 p-6 shadow-md hover:border-blue-800/40 dark:border-blue-300/0 dark:shadow-lg dark:hover:border-blue-300/40"
              >
                <dd className="text-primary text-center text-2xl font-semibold tracking-tight sm:text-3xl">
                  {card.title}
                </dd>
                <dt className="text-secondary text-center text-base leading-7">
                  {card.subtitle}
                </dt>
              </Link>
            ))}
          </dl>
        </div>
      </div>
    </>
  );
};

export default Home;
