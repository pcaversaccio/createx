import { Footer } from '@/components/layout/Footer';
import { Header } from '@/components/layout/Header';

interface Props {
  children: JSX.Element;
}

export const Layout = ({ children }: Props) => {
  return (
    <div className='bg-primary flex min-h-screen flex-col'>
      <Header />
      <main className='text-primary my-4 h-full w-full flex-1 px-4 sm:px-6 md:justify-between lg:px-8'>
        {children}
      </main>
      <Footer />
    </div>
  );
};
