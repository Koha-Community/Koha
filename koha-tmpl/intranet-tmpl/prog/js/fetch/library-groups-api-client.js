export class LibraryGroupsAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/api/v1/library_groups",
        });
    }

    get library_groups() {
        return {
            getAll: (query, params) =>
                this.httpClient.getAll({
                    endpoint: "",
                    query,
                    params,
                    headers: {},
                }),
        };
    }
}

export default LibraryGroupsAPIClient;
