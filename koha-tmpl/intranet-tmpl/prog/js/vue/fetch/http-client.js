import { setError, submitting, submitted } from "../messages";
import { $__ } from "../i18n";

function _ifDocumentAvailable(callback) {
    if (typeof document !== "undefined" && document.getElementById) {
        callback();
    }
}

class HttpClient {
    constructor(options = {}) {
        this._baseURL = options.baseURL || "";
        this._headers = options.headers || {
            "Content-Type": "application/json;charset=utf-8",
        };
        this.csrf_token = this._getCsrfToken(options);
    }

    _getCsrfToken(options) {
        let token = null;
        _ifDocumentAvailable(() => {
            const metaTag = document.querySelector('meta[name="csrf-token"]');
            if (metaTag) {
                token = metaTag.getAttribute("content");
            }
        });
        return token !== null ? token : options.csrfToken || null;
    }

    /**
     * @param {Object} [config] - Per-request behaviour switches
     * @param {boolean} [config.suppressDefaultErrorDialog] - Skip the
     *     page-level error message; for callers that present errors
     *     themselves. The error is still thrown, with the response status
     *     and Koha error_code attached, and the parsed
     *     response body as `body`.
     * @param {AbortSignal} [config.signal] - Cancels the underlying fetch.
     */
    async _fetchJSON(
        endpoint,
        headers = {},
        options = {},
        return_response = false,
        mark_submitting = false,
        config = {}
    ) {
        let res, error;
        if (mark_submitting) submitting();
        await fetch(this._baseURL + endpoint, {
            ...options,
            ...(config.signal ? { signal: config.signal } : {}),
            headers: { ...this._headers, ...headers },
        })
            .then(response => {
                if (!response.ok) {
                    return response.text().then(text => {
                        let message = response.statusText;
                        let code;
                        let body;
                        if (text) {
                            try {
                                const json = JSON.parse(text);
                                body = json;
                                message =
                                    json.error ||
                                    json.errors
                                        ?.map(e => e.message)
                                        .join("\n") ||
                                    json.message ||
                                    json;
                                code = json.error_code;
                            } catch {
                                // Content-type claimed JSON but the body
                                // wasn't (truncated response, proxy error
                                // page, session-expired redirect, ...).
                                // Fall back to the real HTTP failure rather
                                // than surfacing the parse error.
                                message = response.statusText;
                            }
                        }
                        const err = new Error(message);
                        err.status = response.status;
                        err.code = code;
                        err.body = body;
                        throw err;
                    });
                }
                if (return_response) return response;
                return response.json().catch(() => {
                    const err = new Error(
                        $__(
                            "Invalid response from server: could not parse JSON"
                        )
                    );
                    err.status = response.status;
                    throw err;
                });
            })
            .then(result => {
                res = result;
            })
            .catch(err => {
                error = err;
                if (
                    err?.name !== "AbortError" &&
                    !config.suppressDefaultErrorDialog
                ) {
                    setError(err);
                }
            })
            .then(() => {
                if (mark_submitting) submitted();
            });

        if (error) throw error;

        return res;
    }

    get(params = {}) {
        return this._fetchJSON(
            params.endpoint,
            params.headers,
            {
                ...params.options,
                method: "GET",
            },
            params.return_response ?? false,
            params.mark_submitting ?? false,
            params.config ?? {}
        );
    }

    getAll(params = {}) {
        let url =
            params.endpoint +
            "?" +
            new URLSearchParams({
                _per_page: -1,
                ...(params.params && params.params),
                ...(params.query && { q: JSON.stringify(params.query) }),
            });
        return this._fetchJSON(
            url,
            params.headers,
            {
                ...params.options,
                method: "GET",
            },
            params.return_response ?? false,
            params.mark_submitting ?? false,
            params.config ?? {}
        );
    }

    post(params = {}) {
        const body = params.body
            ? typeof params.body === "string"
                ? params.body
                : JSON.stringify(params.body)
            : undefined;
        let csrf_token = { "CSRF-TOKEN": this.csrf_token };
        let headers = { ...csrf_token, ...params.headers };
        return this._fetchJSON(
            params.endpoint,
            headers,
            {
                ...params.options,
                body,
                method: "POST",
            },
            params.return_response ?? false,
            params.mark_submitting ?? true,
            params.config ?? {}
        );
    }

    put(params = {}) {
        const body = params.body
            ? typeof params.body === "string"
                ? params.body
                : JSON.stringify(params.body)
            : undefined;
        let csrf_token = { "CSRF-TOKEN": this.csrf_token };
        let headers = { ...csrf_token, ...params.headers };
        return this._fetchJSON(
            params.endpoint,
            headers,
            {
                ...params.options,
                body,
                method: "PUT",
            },
            params.return_response ?? false,
            params.mark_submitting ?? true,
            params.config ?? {}
        );
    }

    delete(params = {}) {
        const body = params.body
            ? typeof params.body === "string"
                ? params.body
                : JSON.stringify(params.body)
            : undefined;
        let csrf_token = { "CSRF-TOKEN": this.csrf_token };
        let headers = { ...csrf_token, ...params.headers };
        return this._fetchJSON(
            params.endpoint,
            headers,
            {
                parseResponse: false,
                ...params.options,
                body,
                method: "DELETE",
            },
            params.return_response ?? true,
            params.mark_submitting ?? true,
            params.config ?? {}
        );
    }

    count(params = {}) {
        let res;
        return this._fetchJSON(
            params.endpoint,
            params.headers,
            {},
            params.return_response ?? true,
            params.mark_submitting ?? false,
            params.config ?? {}
        ).then(
            response => {
                if (response) {
                    return response.headers.get("X-Total-Count");
                }
            },
            error => {}
        );
    }

    patch(params = {}) {
        const body = params.body
            ? typeof params.body === "string"
                ? params.body
                : JSON.stringify(params.body)
            : undefined;
        return this._fetchJSON(
            params.endpoint,
            params.headers,
            {
                ...params.options,
                body,
                method: "PATCH",
            },
            params.return_response ?? false,
            params.mark_submitting ?? false,
            params.config ?? {}
        );
    }
}

export default HttpClient;
