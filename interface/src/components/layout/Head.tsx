import NextHead from "next/head";
import { generateNextSeo } from "next-seo/pages";
import { SITE_DESCRIPTION, SITE_NAME } from "@/lib/constants";

interface Props {
  title?: string;
  description?: string;
}

export const Head = ({ title, description }: Props) => {
  const seoProps = {
    title: title ? `${title} | ${SITE_NAME}` : SITE_NAME,
    description: description ?? SITE_DESCRIPTION,
  };

  return (
    <NextHead>
      {generateNextSeo(seoProps)}
      <meta name="viewport" content="width=device-width, initial-scale=1" />
    </NextHead>
  );
};
