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

import { useEffect, type ReactElement } from 'react';
import { useRouteError } from 'react-router';

interface RouteErrorBoundaryProps {
  children?: ReactElement;
  assign?: URL;
  replace?: URL;
}

export function RouteErrorBoundary({ children, assign, replace }: Readonly<RouteErrorBoundaryProps>): ReactElement | undefined {
  const error = useRouteError();

  useEffect(() => {
    window.dispatchEvent(new ErrorEvent('error', { error }));
  }, [error]);

  useEffect(() => {
    if (assign !== undefined && assign.toString() !== location.toString()) {
      location.assign(assign);
    }
  }, [assign]);

  useEffect(() => {
    if (replace !== undefined && replace.toString() !== location.toString()) {
      location.replace(replace);
    }
  }, [replace]);

  return children;
}
