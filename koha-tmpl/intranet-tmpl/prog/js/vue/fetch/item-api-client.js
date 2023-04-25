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
                this.get({
                    endpoint:
                        "items?" +
                        new URLSearchParams({
                            _per_page: -1,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                    ...params,
                }),
        };
    }
}

export default ItemAPIClient;
