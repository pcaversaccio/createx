import { useCallback } from 'react';
import { MoonIcon, SunIcon } from '@heroicons/react/20/solid';
import { useTheme } from 'next-themes';

export const ThemeSwitcher = ({ className = '' }) => {
  const { resolvedTheme, setTheme } = useTheme();

  const toggleTheme = useCallback(() => {
    setTheme(resolvedTheme === 'light' ? 'dark' : 'light');
  }, [resolvedTheme, setTheme]);

  return (
    <button onClick={toggleTheme} className={`${className} text-secondary`}>
      {resolvedTheme === 'light' && <MoonIcon className='h-6 w-6' />}
      {resolvedTheme !== 'light' && <SunIcon className='h-6 w-6' />}
    </button>
  );
};
