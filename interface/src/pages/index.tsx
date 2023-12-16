import Link from "next/link";
import { Head } from "@/components/layout/Head";
import { SITE_DESCRIPTION } from "@/lib/constants";

const Home = () => {
  // eslint-disable-next-line no-console
  console.log(`
:'######::'########::'########::::'###::::'########:'########:'##::::'##:
'##... ##: ##.... ##: ##.....::::'## ##:::... ##..:: ##.....::. ##::'##::
 ##:::..:: ##:::: ##: ##::::::::'##:. ##::::: ##:::: ##::::::::. ##'##:::
 ##::::::: ########:: ######:::'##:::. ##:::: ##:::: ######:::::. ###::::
 ##::::::: ##.. ##::: ##...:::: #########:::: ##:::: ##...:::::: ## ##:::
 ##::: ##: ##::. ##:: ##::::::: ##.... ##:::: ##:::: ##:::::::: ##:. ##::
. ######:: ##:::. ##: ########: ##:::: ##:::: ##:::: ########: ##:::. ##:
:......:::..:::::..::........::..:::::..:::::..:::::........::..:::::..::
`);
  const cards = [
    {
      id: 1,
      href: "/deployments",
      title: "Deployments",
      subtitle: "Deployed on 60+ chains",
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
      <div className="mx-auto mt-6 w-full max-w-screen-lg sm:mt-20">
        <h1 className="text-accent mb-10 text-center text-3xl font-bold sm:text-4xl">
          {SITE_DESCRIPTION}
        </h1>
        <dl className="flex flex-wrap justify-center text-center sm:flex-nowrap">
          {cards.map((card) => (
            <Link
              key={card.id}
              href={card.href}
              rel={
                card.href.startsWith("http") ? "noopener noreferrer" : undefined
              }
              target={card.href.startsWith("http") ? "_blank" : undefined}
              className="bg-secondary m-4 w-3/4 cursor-pointer gap-y-4 rounded-xl
              border border-blue-800/0 p-6 shadow-md
              hover:border-blue-800/40 dark:border-blue-300/0
              dark:shadow-lg dark:hover:border-blue-300/40 sm:w-full "
            >
              <dd className="text-primary text-2xl font-semibold tracking-tight sm:text-3xl">
                {card.title}
              </dd>
              <dt className="text-secondary text-base leading-7">
                {card.subtitle}
              </dt>
            </Link>
          ))}
        </dl>
      </div>
    </>
  );
};

export default Home;
