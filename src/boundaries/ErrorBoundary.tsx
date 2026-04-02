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

import { Component, type ReactElement } from 'react';

export class ErrorBoundary extends Component<{
  children?: ReactElement;
  fallback?: ReactElement;
  assign?: URL;
  replace?: URL;
}, { error?: Error }> {
  public constructor(props: {
    children: ReactElement;
    fallback: ReactElement;
  }) {
    super(props);

    this.state = { error: undefined };
  }

  public override shouldComponentUpdate(_nextProps: Readonly<{
    children?: ReactElement;
    fallback?: ReactElement;
    assign?: URL;
    replace?: URL;
  }>, nextState: Readonly<{ error?: Error }>): boolean {
    const { error } = this.state;
    const { error: nextError } = nextState;

    return error !== nextError;
  }

  public override componentDidCatch(error: Error): void {
    this.setState({ error });

    window.dispatchEvent(new ErrorEvent('error', { error }));

    const { assign, replace } = this.props;

    if (assign !== undefined && assign.toString() !== location.toString()) {
      location.assign(assign);
    }

    if (replace !== undefined && replace.toString() !== location.toString()) {
      location.replace(replace);
    }
  }

  public override render(): ReactElement | undefined {
    const { error } = this.state;
    const { fallback, children } = this.props;

    if (error !== undefined) {
      return fallback;
    }

    return children;
  }
}
