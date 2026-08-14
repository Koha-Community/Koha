export class LibraryAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/api/v1/libraries",
        });
    }

    get libraries() {
        return {
            getAll: (query, params, headers) =>
                this.httpClient.getAll({
                    endpoint: "",
                    query,
                    params,
                    headers,
                }),
            get: id =>
                this.httpClient.get({
                    endpoint: `/${id}`,
                }),
            closed_dates: (library_id, params = {}, config) => {
                const query = new URLSearchParams(params).toString();
                return this.httpClient.get({
                    endpoint:
                        `/${library_id}/closed_dates` +
                        (query ? "?" + query : ""),
                    config,
                });
            },
        };
    }
}

export default LibraryAPIClient;
