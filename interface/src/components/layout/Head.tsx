import NextHead from 'next/head';
import { SITE_DESCRIPTION, SITE_NAME } from '@/lib/constants';

interface Props {
  title?: string;
  description?: string;
}

export const Head = (props: Props) => {
  return (
    <NextHead>
      <title>{props.title ? `${props.title} | ${SITE_NAME}` : SITE_NAME}</title>
      <meta name='description' content={props.description ?? SITE_DESCRIPTION} />
      <meta name='viewport' content='width=device-width, initial-scale=1' />
    </NextHead>
  );
};
