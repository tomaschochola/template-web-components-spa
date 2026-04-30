/**
 * @file
 * @author Tomáš Chochola <tomaschochola@tomaschochola.cz>
 * @copyright © 2026 Tomáš Chochola <tomaschochola@tomaschochola.cz>
 *
 * @license CC-BY-ND-4.0
 *
 * @see {@link https://creativecommons.org/licenses/by-nd/4.0/} License
 * @see {@link https://github.com/tomaschochola} GitHub Profile
 * @see {@link https://github.com/sponsors/tomaschochola} GitHub Sponsors
 */

import { Webpack } from '@tomaschochola/tooling-webpack';

// eslint-disable-next-line no-restricted-exports
export default function (env, argv) {
  let webpack = new Webpack(env, argv)
    .entry({
      index: ['./src/index.ts', './src/index.scss'],
    })
    .browserslist()
    .environment()
    .environment({
      APP_ENV: env.APP_ENV ?? argv.appEnv ?? process.env.APP_ENV ?? null,
      OTLP_API_KEY: env.OTLP_API_KEY ?? argv.otlpApiKey ?? process.env.OTLP_API_KEY ?? null,
      APP_NAME: env.APP_NAME ?? argv.appName ?? process.env.APP_NAME ?? process.env.npm_package_name ?? null,
      APP_VERSION: env.APP_VERSION ?? argv.appVersion ?? process.env.APP_VERSION ?? process.env.npm_package_version ?? null,
    })
    .define()
    .html({
      template: './src/index.html',
      filename: 'index.html',
    })
    .copy();

  if (webpack.WEBPACK_MODE === 'production') {
    webpack = webpack.gzip().brotli().pwa({
      exclude: [/\.map$/, /^social\//],
    });
  }

  const config = webpack.build();

  return {
    ...config,
    ignoreWarnings: [
      ...(config.ignoreWarnings ?? []),
      {
        module: /node_modules[/\\]@protobufjs[/\\]inquire[/\\]/,
        message: /Critical dependency: the request of a dependency is an expression/,
      },
    ],
  };
}
