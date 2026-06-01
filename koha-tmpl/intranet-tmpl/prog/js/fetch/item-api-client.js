export class ItemAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/api/v1/",
        });
    }

    get items() {
        return {
            getAll: (query, params, headers) =>
                this.httpClient.getAll({
                    endpoint: "items",
                    query,
                    params,
                    headers,
                }),
            get: id =>
                this.httpClient.get({
                    endpoint: "items/" + id,
                    headers: {
                        "x-koha-embed": "+strings",
                    },
                }),
        };
    }

    get bundled_items() {
        return {
            add: (item_id, body, params = {}) =>
                this.httpClient.post({
                    endpoint: "items/" + item_id + "/bundled_items",
                    body,
                    ...params,
                }),
        };
    }

    get item_types() {
        return {
            getAll: (query, params, headers) =>
                this.httpClient.getAll({
                    endpoint: "item_types",
                    query,
                    params,
                    headers,
                }),
        };
    }
}

export default ItemAPIClient;
