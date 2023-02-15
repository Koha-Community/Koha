class HttpClient {
    constructor(options = {}) {
        this._baseURL = options.baseURL || "";
        this._headers = options.headers || {
            "Content-Type": "application/json;charset=utf-8",
        };
    }

    async _fetchJSON(endpoint, headers = {}, options = {}) {
        const res = await fetch(this._baseURL + endpoint, {
            ...options,
            headers: { ...this._headers, ...headers },
        });

        if (!res.ok) throw new Error(res.statusText);

        if (options.parseResponse !== false && res.status !== 204)
            return res.json();

        return undefined;
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
        });
    }

    //TODO: Implement count method
}

export default HttpClient;
