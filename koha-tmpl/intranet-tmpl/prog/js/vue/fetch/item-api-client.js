import HttpClient from "./http-client";

export class ItemAPIClient extends HttpClient {
    constructor() {
        super({
            baseURL: "/api/v1/",
        });
    }

    get items() {
        return {
            getAll: (query, params, headers) =>
                this.getAll({
                    endpoint: "items",
                    query,
                    params,
                    headers,
                }),
        };
    }
}

export default ItemAPIClient;
