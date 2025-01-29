export class AVAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "",
        });
    }

    get values() {
        return {
            get: category =>
                this.httpClient.get({
                    endpoint: `/api/v1/authorised_value_categories/${category}/authorised_values`,
                }),
            getCategoriesWithValues: cat_array =>
                this.httpClient.get({
                    endpoint:
                        "/api/v1/authorised_value_categories" +
                        '?q={"me.category_name":[' +
                        cat_array.join(", ") +
                        "]}",
                    headers: {
                        "x-koha-embed": "authorised_values",
                    },
                }),
            create: value =>
                this.httpClient.post({
                    endpoint: "/cgi-bin/koha/svc/authorised_values",
                    body: "category=%s&value=%s&description=%s&opac_description=%s".format(
                        encodeURIComponent(value.category),
                        encodeURIComponent(value.value),
                        encodeURIComponent(value.description),
                        encodeURIComponent(value.opac_description)
                    ),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                }),
        };
    }
}

export default AVAPIClient;
