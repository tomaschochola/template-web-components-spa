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
  useEffect,
  useState,
  type ReactNode,
} from 'react';

export interface SuspenseValueProps<T> {
  readonly resolve?: T;
  readonly delay?: number;
  readonly fallback?: ReactNode;
  readonly children: ((value: Exclude<T, undefined>) => ReactNode);
}

export function SuspenseValue<T>({
  resolve,
  delay = 200,
  fallback,
  children,
}: SuspenseValueProps<T>): ReactNode {
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

  if (resolve === undefined) {
    return show || delay <= 0 ? fallback : null;
  }

  return children(resolve as unknown as Exclude<T, undefined>); // eslint-disable-line @typescript-eslint/no-unsafe-type-assertion
}
