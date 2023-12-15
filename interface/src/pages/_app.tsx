import * as React from 'react';
import type { AppProps } from 'next/app';
import { Analytics } from '@vercel/analytics/react';
import { ThemeProvider } from 'next-themes';
import { Layout } from '@/components/layout/Layout';
import '@/styles/globals.css';

function App({ Component, pageProps }: AppProps) {
  const [mounted, setMounted] = React.useState(false);
  React.useEffect(() => setMounted(true), []);
  return (
    <ThemeProvider attribute='class'>
      {mounted && (
        <Layout>
          <>
            <Component {...pageProps} />
            <Analytics />
          </>
        </Layout>
      )}
    </ThemeProvider>
  );
}

export default App;
