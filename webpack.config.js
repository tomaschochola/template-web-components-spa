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
  return new Webpack(env, argv)
    .setEntry({
      index: ['./src/index.ts'],
    })
    .presetDefaults({
      pluginCopy: true,
      pluginPwa: true,
    })
    .pluginEnvironment({
      OTLP_API_KEY: env.OTLP_API_KEY ?? argv.otlpApiKey ?? process.env.OTLP_API_KEY ?? '',
    })
    .pluginHtml({
      template: './src/index.html',
      filename: 'index.html',
    })
    .pluginCopyFrom('./generated')
    .mergeConfig((_env, _argv, conf) => ({
      ...conf,
      ignoreWarnings: [
        ...(conf.ignoreWarnings ?? []),
        {
          message: /Critical dependency: the request of a dependency is an expression/,
          module: /node_modules[/\\]@protobufjs[/\\]inquire[/\\]/,
        },
      ],
    }))
    .buildConfig();
}
