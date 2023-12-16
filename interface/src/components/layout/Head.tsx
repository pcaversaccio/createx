import NextHead from "next/head";
import { SITE_DESCRIPTION, SITE_NAME } from "@/lib/constants";

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
      <meta name="twitter:card" content="summary" />
      <meta name="twitter:creator" content="@pcaversaccio" />
      <meta property="og:url" content="https://www.createx.rocks" />
      <meta property="og:title" content="CreateX" />
      <meta
        property="og:description"
        content="A Trustless, Universal Contract Deployer"
      />
      <meta
        property="og:image"
        content="https://github-production-user-asset-6210df.s3.amazonaws.com/25297591/272914952-38a5989c-0113-427d-9158-47646971b7d8.png"
      />
    </NextHead>
  );
};
