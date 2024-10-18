export class PatronAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/api/v1/patrons/",
        });
    }

    get patrons() {
        return {
            get: id =>
                this.httpClient.get({
                    endpoint: id,
                }),
        };
    }

    get patron_categories() {
        return {
            getAll: (query, params, headers) =>
                this.getAll({
                    endpoint: "patron_categories",
                    query,
                    params,
                    headers,
                }),
        };
    }
}

export default PatronAPIClient;
