export class CircRuleAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/api/v1/circulation_rules",
        });
    }

    get config() {
        return {
            getAll: () =>
                this.httpClient.get({
                    endpoint: "/config",
                }),
        };
    }

    get circ_rules() {
        return {
            getAll: (query, params, headers) =>
                this.httpClient.getAll({
                    endpoint: "",
                    query,
                    params,
                    headers,
                }),
            update: rule =>
                this.httpClient.put({
                    endpoint: "",
                    body: rule,
                }),
            count: (query = {}) =>
                this.httpClient.count({
                    endpoint:
                        "?" +
                        new URLSearchParams({
                            _page: 1,
                            _per_page: 1,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                }),
        };
    }

    get rules() {
        return {
            get: (params = {}, config) =>
                this.httpClient.get({
                    endpoint: "?" + new URLSearchParams(params).toString(),
                    config,
                }),
        };
    }
}

export default CircRuleAPIClient;
