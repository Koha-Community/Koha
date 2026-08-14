// Adapter for dayjs to use the globally loaded instance from js-date-format.inc
// This prevents duplicate bundling and maintains TypeScript support.

/** @typedef {typeof import('dayjs')} DayjsModule */

if (!window["dayjs"]) {
    throw new Error(
        "dayjs is not available globally. Please ensure js-date-format.inc is included before this module."
    );
}

/** @type {DayjsModule} */
const dayjs = /** @type {DayjsModule} */ (window["dayjs"]);

export default dayjs;
