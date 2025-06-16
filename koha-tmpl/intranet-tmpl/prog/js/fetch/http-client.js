function _ifDocumentAvailable(callback) {
    if (typeof document !== "undefined" && document.getElementById) {
        callback();
    }
}

class Dialog {
    constructor(options = {}) {}

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

    async _fetchJSON(
        endpoint,
        headers = {},
        options = {},
        return_response = false,
        mark_submitting = false
    ) {
        let res, error;
        //if (mark_submitting) submitting();
        await fetch(this._baseURL + endpoint, {
            ...options,
            headers: { ...this._headers, ...headers },
        })
            .then(response => {
                const is_json = response.headers
                    .get("content-type")
                    ?.includes("application/json");
                if (!response.ok) {
                    return response.text().then(text => {
                        let message;
                        if (text && is_json) {
                            let json = JSON.parse(text);
                            message =
                                json.error ||
                                json.errors.map(e => e.message).join("\n") ||
                                json;
                        } else {
                            message = response.statusText;
                        }
                        throw new Error(message);
                    });
                }
                if (return_response || !is_json) {
                    return response;
                }
                return response.json();
            })
            .then(result => {
                res = result;
            })
            .catch(err => {
                error = err;
                new Dialog().setError(err);
                console.error(err);
            })
            .then(() => {
                //if (mark_submitting) submitted();
            });

        if (error) throw Error(error);

        return res;
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
            false,
            true
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
            false,
            true
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
            true,
            true
        );
    }
}

export default HttpClient;
