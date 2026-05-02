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

import { Webpack } from '@tomaschochola/tooling-webpack';

// eslint-disable-next-line no-restricted-exports
export default function (env, argv) {
  return new Webpack(env, argv)
    .entry({
      og: ['./og/og.ts'],
    })
    .defaults()
    .public('./')
    .output(fileURLToPath(new URL('./tmp/og/', import.meta.url)))
    .html({
      filename: 'og.html',
      template: './og/og.html',
    })
    .build();
}
