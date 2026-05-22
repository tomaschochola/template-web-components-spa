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

import { WebpackConfigBuilder } from '@tomaschochola/tooling-webpack';

// eslint-disable-next-line no-restricted-exports
export default function (env, argv) {
  let tooling = new WebpackConfigBuilder({
    env,
    argv,
  });

  tooling = tooling
    .setEntries({
      index: ['./src/index.ts'],
    })
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
      OTLP_API_KEY: env.OTLP_API_KEY ?? argv.otlpApiKey ?? process.env.OTLP_API_KEY ?? '',
    })
    .addDefinePlugin()
    .addHtmlPlugin({
      template: './src/index.html',
      filename: 'index.html',
    })
    .addPublicCopyPlugin()
    .addCopyFrom('./generated')
    .addTerserMinimizer()
    .addCssMinimizer()
    .addHtmlMinimizer()
    .addJsonMinimizer()
    .addImageMinimizer()
    .addIgnoredWarnings([
      {
        message: /Critical dependency: the request of a dependency is an expression/,
        module: /node_modules[/\\]@protobufjs[/\\]inquire[/\\]/,
      },
    ]);

  if (tooling.isProductionMode) {
    tooling = tooling
      .addGzipCompressionPlugin()
      .addBrotliCompressionPlugin()
      .addWorkboxServiceWorkerPlugin();
  }

  return tooling.toConfig();
}
