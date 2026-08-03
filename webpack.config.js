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

import { resolve } from 'node:path';
import { WebpackConfigBuilder } from '@tomaschochola/tooling-webpack';

export default function (env = {}, argv = {}) {
  let tooling = new WebpackConfigBuilder({
    env,
    argv,
  });

  const appEnv = tooling.appEnv;
  const appName = tooling.appName;
  const appVersion = tooling.appVersion;
  const webpackMode = tooling.webpackMode;

  const isProductionApp = tooling.isProductionMode && appEnv === 'production';

  tooling = tooling
    .setOutputPath(resolve('dist'))
    .setEntries({
      index: ['./src/polyfills.ts', './src/observability.ts', './src/index.ts'],
    })
    .setDevServerPort(61101)
    .addBabelLoader()
    .addStyleLoaders()
    .addHtmlLoader()
    .addAssetQueryRules()
    .addDefinePlugin({
      'process.env.APP_ENV': JSON.stringify(appEnv),
      'process.env.APP_NAME': JSON.stringify(appName),
      'process.env.APP_VERSION': JSON.stringify(appVersion),
      'process.env.WEBPACK_MODE': JSON.stringify(webpackMode),
    })
    .addHtmlPlugin({
      template: './src/index.html',
      filename: 'index.html',
    })
    .addPublicCopyPlugin()
    .addRobotsPlugin({
      indexable: isProductionApp,
    })
    .addCopyFrom('./generated')
    .addTerserMinimizer()
    .addCssMinimizer()
    .addHtmlMinimizer()
    .addJsonMinimizer()
    .addImageMinimizer();

  if (tooling.isProductionMode) {
    tooling = tooling.addGzipCompressionPlugin().addBrotliCompressionPlugin().addWorkboxServiceWorkerPlugin();
  }

  const config = tooling.toConfig();

  if (appEnv === 'playwright') {
    config.devServer = {
      ...config.devServer,
      client: false,
      hot: false,
      liveReload: false,
      webSocketServer: false,
    };
  }

  return config;
}
