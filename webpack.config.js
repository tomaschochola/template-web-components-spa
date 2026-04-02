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
      OTLP_API_KEY: env.OTLP_API_KEY ?? argv.otlpApiKey ?? process.env.OTLP_API_KEY ?? null,
    })
    .define()
    .html({
      template: './src/index.html',
      filename: 'index.html',
    })
    .copy();

  if (webpack.isProduction) {
    webpack = webpack.gzip().brotli().pwa();
  }

  return webpack.build();
}
