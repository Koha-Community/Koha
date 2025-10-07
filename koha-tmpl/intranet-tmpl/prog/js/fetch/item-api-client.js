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
