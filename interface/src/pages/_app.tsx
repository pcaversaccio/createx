import * as React from "react";
import type { AppProps } from "next/app";
import { ThemeProvider } from "next-themes";
import { Layout } from "@/components/layout/Layout";
import "@/styles/globals.css";

function App({ Component, pageProps }: AppProps) {
  // const [mounted, setMounted] = React.useState(false);
  // React.useEffect(() => setMounted(true), []);
  return (
    <ThemeProvider attribute="class">
      {(
        <Layout>
          <>
            <Component {...pageProps} />
          </>
        </Layout>
      )}
    </ThemeProvider>
  );
}

export default App;
