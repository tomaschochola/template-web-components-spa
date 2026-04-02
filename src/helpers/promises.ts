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

interface WrappedPromise<T> extends Promise<T> {
  status: 'pending' | 'fulfilled' | 'rejected';
  value: T | undefined;
  reason: unknown;
}

export function wrapPromise<T>(promise: Promise<T>): Promise<T> {
  // eslint-disable-next-line @typescript-eslint/no-unsafe-type-assertion
  const wrapped = promise as WrappedPromise<T>;

  wrapped.status = 'pending';
  wrapped.value = undefined;
  wrapped.reason = undefined;

  return wrapped.then(
    (value: T) => {
      wrapped.status = 'fulfilled';
      wrapped.value = value;
      wrapped.reason = undefined;

      return value;
    },
    (reason: unknown) => {
      wrapped.status = 'rejected';
      wrapped.reason = reason;
      wrapped.value = undefined;

      throw reason;
    },
  );
}

export const UNLIMITED_PROMISE = new Promise<never>(() => {
  return undefined;
});

export function unlimitedPromise<T>(promise: Promise<T> | undefined): Promise<T> {
  if (promise === undefined) {
    return UNLIMITED_PROMISE;
  }

  return promise;
}
