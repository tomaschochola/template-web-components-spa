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

import { useCallback, type ReactElement } from 'react';
import { Outlet, ScrollRestoration, type Location } from 'react-router-dom';

export function RootRoute(): ReactElement {
  const handleKey = useCallback(({ pathname }: Location): string => pathname, []);

  return (
    <div
      data-testid="sentinel"
    >
      <Outlet />
      <ScrollRestoration
        getKey={handleKey}
      />
    </div>
  );
}
