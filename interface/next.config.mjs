// @ts-check

/**
 * @type {import('next').NextConfig}
 **/
const nextConfig =
  // Check if running in a continuous integration (CI) environment.
  process.env.CI === "true"
    ? {
        /**
         * Enable static exports for the App Router.
         * @see https://nextjs.org/docs/pages/building-your-application/deploying/static-exports.
         */
        output: "export",

        /**
         * Disable server-based image optimization. Next.js does not support
         * dynamic features with static exports.
         * @see https://nextjs.org/docs/pages/api-reference/components/image#unoptimized.
         */
        images: {
          unoptimized: true,
        },

        /**
         * Use a custom build directory instead of `.next`.
         * @see https://nextjs.org/docs/pages/api-reference/next-config-js/distDir.
         */
        distDir: "dist",
      }
    : // For local development, just set a custom build directory instead of `.next`.
      {
        distDir: "dist",
      };

export default nextConfig;
