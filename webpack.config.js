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

function isEnabled(value) {
  return value === true || value === 'true';
}

export default function (env = {}, argv = {}) {
  let tooling = new WebpackConfigBuilder({
    env,
    argv,
  });

  const appEnv = tooling.appEnv;
  const appName = tooling.appName;
  const appVersion = tooling.appVersion;
  const otelEnabled = isEnabled(env.OTEL_ENABLED ?? process.env.OTEL_ENABLED);
  const otlpApiKey = env.OTLP_API_KEY ?? process.env.OTLP_API_KEY ?? '';
  const polyfillsEnabled = isEnabled(env.POLYFILLS_ENABLED ?? process.env.POLYFILLS_ENABLED);
  const entries = [];

  if (polyfillsEnabled) {
    entries.push('./src/polyfills.ts');
  }

  if (otelEnabled) {
    entries.push('./src/observability.ts');
  }

  entries.push('./src/index.ts');

  const isProductionApp = tooling.isProductionMode && appEnv === 'production';

  tooling = tooling
    .setEntries({
      index: entries,
    })
    .setDevServerPort(61101)
    .setDevServerServer(appEnv === 'local' ? 'https' : 'http')
    .addBabelLoader()
    .addStyleLoaders()
    .addHtmlLoader()
    .addAssetQueryRules()
    .addDefinePlugin({
      'process.env.APP_ENV': JSON.stringify(appEnv),
      'process.env.APP_NAME': JSON.stringify(appName),
      'process.env.APP_VERSION': JSON.stringify(appVersion),
      'process.env.OTLP_API_KEY': JSON.stringify(otlpApiKey),
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
