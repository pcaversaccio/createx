import { DefaultSeoProps } from "next-seo";
import { SITE_DESCRIPTION, SITE_IMAGE, SITE_NAME } from "@/lib/constants";

const config: DefaultSeoProps = {
  title: SITE_NAME,
  description: SITE_DESCRIPTION,
  openGraph: {
    url: "https://createx.rocks",
    title: "CreateX",
    description: SITE_DESCRIPTION,
    images: [
      {
        url: SITE_IMAGE,
        secureUrl: SITE_IMAGE,
        type: "image/png",
        width: 1200,
        height: 514,
        alt: `${SITE_NAME} – ${SITE_DESCRIPTION}`,
      },
    ],
  },
  twitter: {
    handle: "@pcaversaccio",
    cardType: "summary_large_image",
  },
};

export default config;
