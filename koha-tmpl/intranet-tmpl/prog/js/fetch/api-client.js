import HttpClient from "./http-client.js";

/**
 * @template {object} T
 * @typedef {new (...args: unknown[]) => T} ClientConstructor
 */

/**
 * @template {object} T
 * @typedef {ClientConstructor<T> | { default: ClientConstructor<T> }} ClientModule
 */

/**
 * Determines whether a value can safely be treated as an object for property
 * access (including functions, which are callable objects in JS).
 *
 * @param {unknown} value
 * @returns {value is object | Function}
 */
const isObjectLike = value =>
    (typeof value === "object" && value !== null) ||
    typeof value === "function";

/**
 * Lazily instantiates an API client module the first time a consumer actually
 * uses it. Callers still interact with `APIClient.foo` synchronously, but under
 * the hood a proxy defers the dynamic `import()` until a method is invoked or a
 * promise chain is attached. This keeps existing call sites unchanged while
 * preventing every specialised client from being fetched on initial page load.
 *
 * @template {object} T
 * @param {() => Promise<ClientModule<T> | ClientConstructor<T>>} loader dynamic importer for the client module
 * @returns {T} proxy exposing the API client interface with lazy loading
 */
const createClientProxy = loader => {
    /** @type {Promise<T> | undefined} */
    let instancePromise;

    /**
     * Extracts the client constructor from a dynamic import namespace.
     *
     * @param {ClientModule<T> | ClientConstructor<T>} namespace
     * @returns {ClientConstructor<T>}
     */
    const resolveClientConstructor = namespace => {
        if (typeof namespace === "function") {
            return /** @type {ClientConstructor<T>} */ (namespace);
        }

        if (isObjectLike(namespace)) {
            const maybeDefault = Reflect.get(
                /** @type {object} */ (namespace),
                "default"
            );
            if (typeof maybeDefault === "function") {
                return /** @type {ClientConstructor<T>} */ (maybeDefault);
            }
        }
        throw new TypeError("API client module did not export a constructor");
    };

    /**
     * Resolves (or re-resolves after failure) the underlying client instance.
     *
     * @returns {Promise<T>} promise resolving to the concrete client
     */
    const loadInstance = () => {
        if (!instancePromise) {
            instancePromise = loader()
                .then(resolveClientConstructor)
                .then(Client => new Client(HttpClient))
                .catch(error => {
                    instancePromise = undefined;
                    throw error;
                });
        }
        return instancePromise;
    };

    /**
     * Creates a proxy layer that defers property access and function calls
     * until the client instance is available while keeping the existing call
     * structure intact (including promise chaining support).
     *
     * @param {(client: T) => unknown} accessor resolver for the current target
     * @param {(client: T) => unknown} [parentAccessor=accessor] context resolver
     * @returns {unknown} proxy forwarding operations to the resolved target
     */
    const createProxy = (accessor, parentAccessor = accessor) => {
        /**
         * Forwards promise chaining when consumers treat the proxy like a promise.
         *
         * @param {(value: unknown) => unknown} onFulfilled
         * @param {(reason: unknown) => unknown} [onRejected]
         * @returns {Promise<unknown>}
         */
        const handleThen = (onFulfilled, onRejected) =>
            loadInstance()
                .then(client => accessor(client))
                .then(onFulfilled, onRejected);

        /**
         * Propagates errors when consumers attach a catch handler to the proxy.
         *
         * @param {(reason: unknown) => unknown} onRejected
         * @returns {Promise<unknown>}
         */
        const handleCatch = onRejected =>
            loadInstance()
                .then(client => accessor(client))
                .catch(onRejected);

        /**
         * Executes finally handlers while preserving the resolved value chain.
         *
         * @param {() => unknown} onFinally
         * @returns {Promise<unknown>}
         */
        const handleFinally = onFinally =>
            loadInstance()
                .then(client => accessor(client))
                .finally(onFinally);

        /**
         * Returns a proxy that represents a nested property on the client.
         *
         * @param {PropertyKey} prop
         * @returns {unknown}
         */
        const forwardProperty = prop =>
            createProxy(client => {
                const target = accessor(client);
                if (!isObjectLike(target)) {
                    return undefined;
                }
                return Reflect.get(/** @type {object} */ (target), prop);
            }, accessor);

        /**
         * Invokes a method on the resolved client while keeping the original
         * `this` binding semantics.
         *
         * @param {unknown} thisArg
         * @param {unknown[]} argArray
         * @returns {Promise<unknown>}
         */
        const invokeTarget = (thisArg, argArray) =>
            loadInstance().then(client => {
                const target = accessor(client);
                if (typeof target !== "function") {
                    throw new TypeError("API client property is not callable");
                }
                const context = parentAccessor
                    ? parentAccessor(client)
                    : (thisArg ?? undefined);
                return target.apply(context, argArray);
            });

        return new Proxy(function () {}, {
            get(_, prop) {
                if (prop === "then") {
                    return handleThen;
                }
                if (prop === "catch") {
                    return handleCatch;
                }
                if (prop === "finally") {
                    return handleFinally;
                }

                return forwardProperty(prop);
            },
            apply(_, thisArg, args) {
                return invokeTarget(thisArg, /** @type {unknown[]} */ (args));
            },
        });
    };

    return /** @type {T} */ (createProxy(client => client));
};

export const APIClient = {
    article_request: createClientProxy(
        () => import("./article-request-api-client.js")
    ),
    authorised_values: createClientProxy(
        () => import("./authorised-values-api-client.js")
    ),
    acquisition: createClientProxy(() => import("./acquisition-api-client.js")),
    cataloguing: createClientProxy(() => import("./cataloguing-api-client.js")),
    circulation: createClientProxy(() => import("./circulation-api-client.js")),
    club: createClientProxy(() => import("./club-api-client.js")),
    cover_image: createClientProxy(() => import("./cover-image-api-client.js")),
    localization: createClientProxy(
        () => import("./localization-api-client.js")
    ),
    patron: createClientProxy(() => import("./patron-api-client.js")),
    patron_list: createClientProxy(() => import("./patron-list-api-client.js")),
    recall: createClientProxy(() => import("./recall-api-client.js")),
    sysprefs: createClientProxy(
        () => import("./system-preferences-api-client.js")
    ),
    ticket: createClientProxy(() => import("./ticket-api-client.js")),
    default: createClientProxy(() => import("./default-api-client.js")),
};

export default APIClient;
