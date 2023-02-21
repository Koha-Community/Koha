import { setError } from "../messages";

class HttpClient {
    constructor(options = {}) {
        this._baseURL = options.baseURL || "";
        this._headers = options.headers || {
            "Content-Type": "application/json;charset=utf-8",
        };
    }

    async _fetchJSON(
        endpoint,
        headers = {},
        options = {},
        return_response = false
    ) {
        let res, error;
        await fetch(this._baseURL + endpoint, {
            ...options,
            headers: { ...this._headers, ...headers },
        })
            .then((response) => this.checkError(response, return_response))
            .then(
                (result) => {
                    res = result;
                },
                (err) => {
                    error = err;
                    setError(err.toString());
                }
            )
            .catch((err) => {
                error = err;
                setError(err);
            });

        if (error) throw Error(error);

        return res;
    }

    get(params = {}) {
        return this._fetchJSON(params.endpoint, params.headers, {
            ...params.options,
            method: "GET",
        });
    }

    post(params = {}) {
        return this._fetchJSON(params.endpoint, params.headers, {
            ...params.options,
            body: params.body ? JSON.stringify(params.body) : undefined,
            method: "POST",
        });
    }

    put(params = {}) {
        return this._fetchJSON(params.endpoint, params.headers, {
            ...params.options,
            body: params.body ? JSON.stringify(params.body) : undefined,
            method: "PUT",
        });
    }

    delete(params = {}) {
        return this._fetchJSON(params.endpoint, params.headers, {
            parseResponse: false,
            ...params.options,
            method: "DELETE",
        }, true);
    }

    count(params = {}) {
        let res;
        return this._fetchJSON(params.endpoint, params.headers, {}, 1).then(
            (response) => {
                if (response) {
                    return response.headers.get("X-Total-Count");
                }
            },
            (error) => {
                setError(error.toString());
            }
        );
    }

    checkError(response, return_response = 0) {
        if (response.status >= 200 && response.status <= 299) {
            return return_response ? response : response.json();
        } else {
            console.log("Server returned an error:");
            console.log(response);
            throw Error("%s (%s)".format(response.statusText, response.status));
        }
    }
}

export default HttpClient;
