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

import { metrics, ValueType, type Gauge, type Histogram } from '@opentelemetry/api';
import { logs, SeverityNumber } from '@opentelemetry/api-logs';
import { CompositePropagator, W3CBaggagePropagator, W3CTraceContextPropagator } from '@opentelemetry/core';
import { OTLPLogExporter } from '@opentelemetry/exporter-logs-otlp-http';
import { OTLPMetricExporter } from '@opentelemetry/exporter-metrics-otlp-http';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';
import { registerInstrumentations } from '@opentelemetry/instrumentation';
import { DocumentLoadInstrumentation } from '@opentelemetry/instrumentation-document-load';
import { FetchInstrumentation } from '@opentelemetry/instrumentation-fetch';
import { XMLHttpRequestInstrumentation } from '@opentelemetry/instrumentation-xml-http-request';
import { browserDetector } from '@opentelemetry/opentelemetry-browser-detector';
import { defaultResource, detectResources, resourceFromAttributes } from '@opentelemetry/resources';
import { BatchLogRecordProcessor, LoggerProvider } from '@opentelemetry/sdk-logs';
import { MeterProvider, PeriodicExportingMetricReader } from '@opentelemetry/sdk-metrics';
import { BatchSpanProcessor } from '@opentelemetry/sdk-trace-base';
import { WebTracerProvider } from '@opentelemetry/sdk-trace-web';
import {
  ATTR_ERROR_TYPE,
  ATTR_EXCEPTION_MESSAGE,
  ATTR_EXCEPTION_STACKTRACE,
  ATTR_EXCEPTION_TYPE,
  ATTR_SERVICE_NAME,
  ATTR_SERVICE_VERSION,
  ATTR_URL_FRAGMENT,
  ATTR_URL_FULL,
  ATTR_URL_PATH,
  ATTR_URL_QUERY,
  ERROR_TYPE_VALUE_OTHER,
} from '@opentelemetry/semantic-conventions';
import { ATTR_DEPLOYMENT_ENVIRONMENT_NAME } from '@opentelemetry/semantic-conventions/incubating';
import { onCLS, onFCP, onINP, onLCP, onTTFB, type Metric } from 'web-vitals';

const APP_NAME = process.env.APP_NAME;
const APP_VERSION = process.env.APP_VERSION;
const APP_ENV = process.env.APP_ENV;

if (APP_NAME === '') {
  throw new Error('APP_NAME must not be empty when observability is enabled.');
}

if (APP_VERSION === '') {
  throw new Error('APP_VERSION must not be empty when observability is enabled.');
}

if (APP_ENV === '') {
  throw new Error('APP_ENV must not be empty when observability is enabled.');
}

const resource = defaultResource()
  .merge(
    resourceFromAttributes({
      [ATTR_SERVICE_NAME]: APP_NAME,
      [ATTR_SERVICE_VERSION]: APP_VERSION,
      [ATTR_DEPLOYMENT_ENVIRONMENT_NAME]: APP_ENV,
    }),
  )
  .merge(detectResources({ detectors: [browserDetector] }));

const tracerProvider = new WebTracerProvider({
  resource: resource,
  spanProcessors: [
    new BatchSpanProcessor(
      new OTLPTraceExporter({
        url: location.origin + '/otlp/v1/traces',
      }),
    ),
  ],
});

tracerProvider.register({
  propagator: new CompositePropagator({
    propagators: [new W3CTraceContextPropagator(), new W3CBaggagePropagator()],
  }),
});

const meterProvider = new MeterProvider({
  resource: resource,
  readers: [
    new PeriodicExportingMetricReader({
      exporter: new OTLPMetricExporter({
        url: location.origin + '/otlp/v1/metrics',
      }),
    }),
  ],
});

metrics.setGlobalMeterProvider(meterProvider);

const loggerProvider = new LoggerProvider({
  resource: resource,
  processors: [
    new BatchLogRecordProcessor({
      exporter: new OTLPLogExporter({
        url: location.origin + '/otlp/v1/logs',
      }),
    }),
  ],
});

logs.setGlobalLoggerProvider(loggerProvider);

registerInstrumentations({
  tracerProvider: tracerProvider,
  meterProvider: meterProvider,
  loggerProvider: loggerProvider,
  instrumentations: [new DocumentLoadInstrumentation(), new FetchInstrumentation(), new XMLHttpRequestInstrumentation()],
});

const meter = metrics.getMeter('web-vitals');

const lcpRecorder = meter.createHistogram('web_vitals.lcp', {
  description: 'Largest Contentful Paint',
  unit: 'ms',
  valueType: ValueType.DOUBLE,
});

const clsRecorder = meter.createGauge('web_vitals.cls', {
  description: 'Cumulative Layout Shift',
  unit: 'score',
  valueType: ValueType.DOUBLE,
});

const ttfbRecorder = meter.createHistogram('web_vitals.ttfb', {
  description: 'Time to First Byte',
  unit: 'ms',
  valueType: ValueType.DOUBLE,
});

const fcpRecorder = meter.createHistogram('web_vitals.fcp', {
  description: 'First Contentful Paint',
  unit: 'ms',
  valueType: ValueType.DOUBLE,
});

const inpRecorder = meter.createHistogram('web_vitals.inp', {
  description: 'Input Performance',
  unit: 'ms',
  valueType: ValueType.DOUBLE,
});

function recordWebVital(recorder: Histogram | Gauge, metric: Metric) {
  recorder.record(metric.value, {
    rating: metric.rating,
    navigation: metric.navigationType,
  });
}

onLCP((metric) => {
  recordWebVital(lcpRecorder, metric);
});

onCLS((metric) => {
  recordWebVital(clsRecorder, metric);
});

onTTFB((metric) => {
  recordWebVital(ttfbRecorder, metric);
});

onFCP((metric) => {
  recordWebVital(fcpRecorder, metric);
});

onINP((metric) => {
  recordWebVital(inpRecorder, metric);
});

const logger = logs.getLogger(APP_NAME, APP_VERSION);

function emitError(error: unknown, fallbackMessage: string): void {
  const exception = error instanceof Error ? error : undefined;
  const message = exception?.message ?? (typeof error === 'string' ? error : fallbackMessage);

  logger.emit({
    attributes: {
      [ATTR_ERROR_TYPE]: exception?.name ?? ERROR_TYPE_VALUE_OTHER,
      [ATTR_EXCEPTION_TYPE]: exception?.name,
      [ATTR_EXCEPTION_MESSAGE]: message,
      [ATTR_EXCEPTION_STACKTRACE]: exception?.stack,
      [ATTR_URL_FULL]: location.href,
      [ATTR_URL_PATH]: location.pathname,
      [ATTR_URL_QUERY]: location.search.slice(1),
      [ATTR_URL_FRAGMENT]: location.hash.slice(1),
    },
    severityNumber: SeverityNumber.ERROR,
    severityText: 'ERROR',
    body: message,
  });
}

window.addEventListener('error', (event: ErrorEvent) => {
  emitError(event.error as unknown, event.message);
});

window.addEventListener('unhandledrejection', (event: PromiseRejectionEvent) => {
  emitError(event.reason as unknown, 'Unhandled promise rejection.');
});
