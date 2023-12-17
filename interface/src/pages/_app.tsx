import * as React from "react";
import type { AppProps } from "next/app";
import Head from "next/head";
import { ThemeProvider } from "next-themes";
import { Layout } from "@/components/layout/Layout";
import { SITE_DESCRIPTION, SITE_IMAGE, SITE_NAME } from "@/lib/constants";
import "@/styles/globals.css";

function App({ Component, pageProps }: AppProps) {
  const [mounted, setMounted] = React.useState(false);
  React.useEffect(() => setMounted(true), []);
  return (
    <ThemeProvider attribute="class">
      {mounted && (
        <Layout>
          <>
            <Head>
              <meta property="og:url" content="https://createx.rocks" />
              <meta property="og:title" content="CreateX" />
              <meta property="og:description" content={SITE_DESCRIPTION} />
              <meta property="og:image:type" content="image/png" />
              <meta property="og:image" content={SITE_IMAGE} />
              <meta property="og:image:secure_url" content={SITE_IMAGE} />
              <meta property="og:image:width" content="1200" />
              <meta property="og:image:height" content="514" />
              <meta
                property="og:image:alt"
                content={SITE_NAME + " – " + SITE_DESCRIPTION}
              />

              <meta name="twitter:card" content="summary_large_image" />
              <meta name="twitter:creator" content="@pcaversaccio" />
              <meta name="twitter:title" content="CreateX" />
              <meta
                name="twitter:description"
                content={SITE_NAME + " – " + SITE_DESCRIPTION}
              />
              <meta property="twitter:image" content={SITE_IMAGE} />
              <meta
                property="twitter:image:alt"
                content={SITE_NAME + " – " + SITE_DESCRIPTION}
              />
            </Head>
            <Component {...pageProps} />
          </>
        </Layout>
      )}
    </ThemeProvider>
  );
}

export default App;
