function _ifDocumentAvailable(callback) {
    if (typeof document !== "undefined" && document.getElementById) {
        callback();
    }
}

class Dialog {
    constructor() {}

    _appendMessage(type, message) {
        _ifDocumentAvailable(() => {
            const messagesContainer = document.getElementById("messages");
            if (!messagesContainer) {
                return;
            }

            const htmlString =
                `<div class="alert alert-${type}">%s</div>`.format(message);
            messagesContainer.insertAdjacentHTML("beforeend", htmlString);
        });
    }

    setMessage(message) {
        this._appendMessage("info", message);
    }

    setError(error) {
        this._appendMessage("warning", error);
    }
}

class HttpClient {
    constructor(options = {}) {
        this._baseURL = options.baseURL || "";
        this._headers = options.headers || {
            // FIXME we actually need to merge the headers
            "Content-Type": "application/json;charset=utf-8",
            "X-Requested-With": "XMLHttpRequest",
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
     *     page-level error dialog; for callers that present errors
     *     themselves. The error is still logged and thrown, with the
     *     response status and Koha error_code attached.
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
        void mark_submitting;
        //if (mark_submitting) submitting();
        await fetch(this._baseURL + endpoint, {
            ...options,
            ...(config.signal ? { signal: config.signal } : {}),
            headers: { ...this._headers, ...headers },
        })
            .then(response => {
                const is_json = response.headers
                    .get("content-type")
                    ?.includes("application/json");

                if (return_response || !is_json) {
                    return response;
                }

                if (!response.ok) {
                    return response.text().then(text => {
                        let message;
                        let code;
                        if (text && is_json) {
                            try {
                                const json = JSON.parse(text);
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
                        } else {
                            message = response.statusText;
                        }
                        const err = new Error(message);
                        err.status = response.status;
                        err.code = code;
                        throw err;
                    });
                }
                return response.json().catch(() => {
                    const err = new Error(
                        "Invalid response from server: could not parse JSON"
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
                    new Dialog().setError(err);
                }
                if (err?.name !== "AbortError") console.error(err);
            })
            .then(() => {
                //if (mark_submitting) submitted();
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

    patch(params = {}) {
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
                method: "PATCH",
            },
            params.return_response ?? false,
            params.mark_submitting ?? true,
            params.config ?? {}
        );
    }

    delete(params = {}) {
        let csrf_token = { "CSRF-TOKEN": this.csrf_token };
        let headers = { ...csrf_token, ...params.headers };
        return this._fetchJSON(
            params.endpoint,
            headers,
            {
                parseResponse: false,
                ...params.options,
                method: "DELETE",
            },
            params.return_response ?? true,
            params.mark_submitting ?? true,
            params.config ?? {}
        );
    }
}

export default HttpClient;
