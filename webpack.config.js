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

export default function (env = {}, argv = {}) {
  let tooling = new WebpackConfigBuilder({
    env,
    argv,
  });

  const appEnv = tooling.appEnv;
  const appName = tooling.appName;
  const appVersion = tooling.appVersion;

  const isProductionApp = tooling.isProductionMode && appEnv === 'production';

  tooling = tooling
    .setDevtool(tooling.isProductionMode ? false : 'source-map')
    .setEntries({
      index: [
        // './src/polyfills.ts',
        // './src/observability.ts',
        '@fontsource-variable/atkinson-hyperlegible-next',
        './src/index.scss',
        './src/index.ts',
        './src/workbox.ts',
      ],
    })
    .setDevServerPort(61100)
    .enableDevServerHistoryApiFallback()
    .addBabelLoader()
    .addStyleLoaders()
    .addHtmlLoader()
    .addAssetQueryRules()
    .addDefinePlugin({
      'process.env.APP_ENV': JSON.stringify(appEnv),
      'process.env.APP_NAME': JSON.stringify(appName),
      'process.env.APP_VERSION': JSON.stringify(appVersion),
    })
    .addHtmlPlugin({
      template: './src/index.html',
    })
    .addPublicCopyPlugin()
    .addCopyPlugin([
      {
        from: './generated/favicons',
        to: '.',
      },
      {
        from: './generated/open-graph/open-graph.png',
        to: 'artifacts/open-graph.png',
      },
    ])
    .addRobotsPlugin({
      indexable: isProductionApp,
    })
    .addTerserMinimizer()
    .addCssMinimizer()
    .addHtmlMinimizer()
    .addJsonMinimizer()
    .addImageMinimizer();

  if (isProductionApp) {
    tooling = tooling.addGzipCompressionPlugin().addBrotliCompressionPlugin().addWorkboxServiceWorkerPlugin();
  } else {
    tooling = tooling.addCopyPlugin([
      {
        from: './assets/service-worker-retirement.js',
        to: 'sw.js',
      },
    ]);
  }

  return tooling.toConfig();
}
