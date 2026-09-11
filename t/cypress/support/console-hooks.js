// Console hooks shared by e2e.js and component.ts.
//
// Goals:
//   - console.warn throws so real warnings (Vue, deprecation) fail tests fast,
//     but with a usable message — Error objects are stringified to their
//     stack/message instead of `{}` (the JSON.stringify default for Errors).
//   - logger output throws on DataTables warnings (legacy behavior).
//
// Why this matters: Bug 41129 chased a silent flatpickr init failure
// because flatpickr's outer try/catch swallowed a thrown `console.warn`
// triggered by a benign config edge case. The old wrap stringified the
// thrown Error as `{}`, hiding the real message. Duck-typing the Error
// shape preserves stack/message across the cross-realm boundary.

function safeStringifyArg(arg) {
    // Duck-type Error: cross-realm `instanceof Error` returns false when
    // the Error was constructed in a different JS context (the AUT vs the
    // runner). Check for the surface instead.
    if (
        arg &&
        typeof arg === "object" &&
        (typeof arg.message === "string" || typeof arg.stack === "string")
    ) {
        return (
            arg.stack ||
            `${arg.name || "Error"}: ${arg.message || "(no message)"}`
        );
    }
    if (typeof arg === "string") return arg;
    try {
        return JSON.stringify(arg);
    } catch (e) {
        return `[object ${arg?.constructor?.name || typeof arg}]`;
    }
}

function stringifyArgs(args) {
    return args.map(safeStringifyArg).join(" ");
}

Cypress.on("window:before:load", win => {
    win.console.warn = (...args) => {
        const message = stringifyArgs(args);
        throw new Error(`JS Warning detected: ${message}`);
    };

    win.console["log"] = (...args) => {
        const message = stringifyArgs(args);
        if (message.match(/DataTables warning: /)) {
            throw new Error(`DataTables warning detected in log: ${message}`);
        }
    };
});
