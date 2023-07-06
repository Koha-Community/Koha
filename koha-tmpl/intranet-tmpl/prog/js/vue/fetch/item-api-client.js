import HttpClient from "./http-client";

export class ItemAPIClient extends HttpClient {
    constructor() {
        super({
            baseURL: "/api/v1/",
        });
    }

    get items() {
        return {
            getAll: (query, params) =>
                this.getAll({
                    endpoint: "items",
                    query,
                    params,
                }),
        };
    }
}

export default ItemAPIClient;
