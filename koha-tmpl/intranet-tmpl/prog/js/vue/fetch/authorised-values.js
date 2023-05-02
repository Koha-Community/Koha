import HttpClient from "./http-client";

export class AVAPIClient extends HttpClient {
    constructor() {
        super({
            baseURL: "/api/v1/authorised_value_categories",
        });
    }

    get values() {
        return {
            getCategoriesWithValues: cat_array =>
                this.get({
                    endpoint:
                        '?q={"me.category_name":[' +
                        cat_array.join(", ") +
                        "]}",
                    headers: {
                        "x-koha-embed": "authorised_values",
                    },
                }),
        };
    }
}

export default AVAPIClient;
