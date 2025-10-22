import * as React from "react";
import type { AppProps } from "next/app";
import Head from "next/head";
import { generateDefaultSeo } from "next-seo/pages";
import { ThemeProvider } from "next-themes";
import { Layout } from "@/components/layout/Layout";
import "@/styles/globals.css";
import DefaultSeoProps from "../../next-seo.config";

function App({ Component, pageProps }: AppProps) {
  const [mounted, setMounted] = React.useState(false);
  React.useEffect(() => setMounted(true), []);
  return (
    <ThemeProvider attribute="class">
      <Head>{generateDefaultSeo(DefaultSeoProps)}</Head>
      {mounted && (
        <Layout>
          <Component {...pageProps} />
        </Layout>
      )}
    </ThemeProvider>
  );
}

export default App;
