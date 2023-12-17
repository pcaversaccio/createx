import NextHead from "next/head";
import { SITE_DESCRIPTION, SITE_NAME, SITE_IMAGE } from "@/lib/constants";

interface Props {
  title?: string;
  description?: string;
}

export const Head = (props: Props) => {
  return (
    <NextHead>
      <title>{props.title ? `${props.title} | ${SITE_NAME}` : SITE_NAME}</title>
      <meta
        name="description"
        content={props.description ?? SITE_DESCRIPTION}
      />
      <meta name="viewport" content="width=device-width, initial-scale=1" />

      <meta property="og:url" content="https://createx.rocks" />
      <meta property="og:title" content="CreateX" />
      <meta
        property="og:description"
        content={SITE_DESCRIPTION}
      />
      <meta property="og:image:type" content="image/png" />
      <meta
        property="og:image"
        content={SITE_IMAGE}
      />
      <meta
        property="og:image:secure_url"
        content={SITE_IMAGE}
      />
      <meta property="og:image:width" content="1200" />
      <meta property="og:image:height" content="514" />
      <meta
        property="og:image:alt"
        content={SITE_NAME + " – " + SITE_DESCRIPTION}
      />

      <meta name="twitter:card" content="summary_large_image" />
      <meta name="twitter:creator" content="@pcaversaccio" />
      <meta name="twitter:title" content="CreateX" />
      <meta name="twitter:description" content={SITE_NAME + " – " + SITE_DESCRIPTION} />
      <meta
        property="twitter:image"
        content={SITE_IMAGE}
      />
      <meta
        property="twitter:image:alt"
        content={SITE_NAME + " – " + SITE_DESCRIPTION}
      />
    </NextHead>
  );
};
