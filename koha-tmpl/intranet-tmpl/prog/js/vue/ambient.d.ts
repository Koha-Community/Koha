/**
 * Ambient module declarations for third-party libraries that ship without
 * type definitions, and for non-code side-effect imports (CSS).
 */

declare module "*.css";

interface BootstrapModal {
    show(): void;
    hide(): void;
    toggle(): void;
    dispose(): void;
}

interface Window {
    flatpickr: typeof import("flatpickr").default;
    flatpickr_dateformat_string?: string;
    bootstrap: {
        Modal: {
            new (element: Element | string, options?: object): BootstrapModal;
            getInstance(element: Element | string): BootstrapModal | null;
            getOrCreateInstance(
                element: Element | string,
                options?: object
            ): BootstrapModal;
        };
    };
}

declare module "vue-select";
