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

import { createBrowserRouter } from 'react-router-dom';
import { RouteErrorBoundary } from './boundaries/RouteErrorBoundary';
import { INDEX_USERS_FETCHER, indexUsersFetcher } from './fetchers/indexUsersFetcher';
import { IndexRoute } from './routes/IndexRoute';
import { NotFoundRoute } from './routes/NotFoundRoute';
import { RootRoute } from './routes/RootRoute';

export function createRouter() {
  return createBrowserRouter([
    {
      path: INDEX_USERS_FETCHER,
      loader: indexUsersFetcher,
    },
    {
      element: <RootRoute />,
      errorElement: <RouteErrorBoundary />,
      children: [
        {
          index: true,
          element: <IndexRoute />,
        },
        {
          path: '*',
          element: <NotFoundRoute />,
        },
      ],
    },
  ]);
}
