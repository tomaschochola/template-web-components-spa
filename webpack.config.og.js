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

import { fileURLToPath } from 'node:url';

import { WebpackConfigBuilder } from '@tomaschochola/tooling-webpack';

// eslint-disable-next-line no-restricted-exports
export default function (env, argv) {
  let tooling = new WebpackConfigBuilder({
    env,
    argv,
  });

  tooling = tooling
    .setEntries({
      og: ['./og/og.ts'],
    })
    .setPublicPath('./')
    .setOutputPath(fileURLToPath(new URL('./tmp/og/', import.meta.url)))
    .addBabelLoader()
    .addStyleLoaders()
    .addHtmlLoader()
    .addAssetQueryRules()
    .addEnvironmentPlugin({
      WEBPACK_MODE: tooling.webpackMode,
      WEBPACK_BUILD: tooling.webpackBuild,
      WEBPACK_SERVE: tooling.webpackServe,
      WEBPACK_WATCH: tooling.webpackWatch,
      NODE_ENV: tooling.nodeEnv,
      APP_ENV: tooling.appEnv,
      APP_NAME: tooling.appName,
      APP_VERSION: tooling.appVersion,
    })
    .addDefinePlugin()
    .addHtmlPlugin({
      filename: 'og.html',
      template: './og/og.html',
    })
    .addTerserMinimizer()
    .addCssMinimizer()
    .addHtmlMinimizer()
    .addJsonMinimizer()
    .addImageMinimizer();

  return tooling.toConfig();
}
