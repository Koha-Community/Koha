import HttpClient from "./http-client";

export class AVAPIClient extends HttpClient {
    constructor() {
        super({
            baseURL: "/api/v1/authorised_value_categories/",
        });
    }

    get values() {
        return {
            getAll: (category_name, query) =>
                this.get({
                    endpoint: category_name + "/values?" + (query || "_per_page=-1"),
                }),
        };
    }
}

export default AVAPIClient;