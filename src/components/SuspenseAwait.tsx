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

import {
  Suspense,
  useEffect,
  useState,
  type ReactElement,
  type ReactNode,
} from 'react';
import { Await } from 'react-router';
import { UNLIMITED_PROMISE } from '../helpers/promises';

export interface SuspenseAwaitProps<T> {
  readonly resolve?: Promise<T>;
  readonly delay?: number;
  readonly fallback?: ReactNode;
  readonly errorElement?: ReactNode;
  readonly children: ((value: T) => ReactNode);
}

export function SuspenseAwait<T>({
  resolve = UNLIMITED_PROMISE,
  delay = 200,
  fallback,
  errorElement,
  children,
}: SuspenseAwaitProps<T>): ReactElement {
  const [show, setShow] = useState(delay <= 0);

  useEffect(() => {
    if (delay <= 0) {
      return;
    }

    const timeout = setTimeout(() => {
      setShow(true);
    }, delay);

    return () => {
      clearTimeout(timeout);
    };
  }, [delay]);

  return (
    <Suspense
      fallback={show || delay <= 0 ? fallback : null}
    >
      <Await
        resolve={resolve}
        errorElement={errorElement}
      >
        {children}
      </Await>
    </Suspense>
  );
}
