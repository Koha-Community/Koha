/**
 * Generic utility functions for Vue components
 */

/**
 * Creates a debounced version of a function that delays invocation
 * until after `delay` milliseconds have elapsed since the last call.
 *
 * @template {(...args: any[]) => any} T
 * @param {T} fn - The function to debounce
 * @param {number} delay - Delay in milliseconds
 * @returns {((...args: Parameters<T>) => void) & { cancel: () => void }}
 */
export function debounce(fn, delay) {
    let timeout;

    /**
     * Schedule the wrapped function after the configured quiet period.
     *
     * @param {...Parameters<T>} args Wrapped function arguments.
     * @returns {void}
     */
    const debounced = function (...args) {
        clearTimeout(timeout);
        timeout = setTimeout(() => fn.apply(this, args), delay);
    };

    /**
     * Cancel a pending invocation.
     *
     * @returns {void}
     */
    debounced.cancel = () => {
        clearTimeout(timeout);
        timeout = undefined;
    };
    return debounced;
}

/**
 * Compare mixed string/number IDs without treating null as an ID.
 *
 * @param {string|number|null|undefined} first
 * @param {string|number|null|undefined} second
 * @returns {boolean}
 */
export function idsEqual(first, second) {
    if (first == null || second == null) return false;
    return String(first) === String(second);
}

/**
 * Check whether a list contains an ID across string/number boundaries.
 *
 * @param {Array<string|number>} list
 * @param {string|number} target
 * @returns {boolean}
 */
export function includesId(list, target) {
    return Array.isArray(list) && list.some(id => idsEqual(id, target));
}
