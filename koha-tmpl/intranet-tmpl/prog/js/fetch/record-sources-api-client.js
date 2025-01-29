export class RecordSourcesAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/api/v1/record_sources",
        });
    }

    get record_sources() {
        return {
            create: record_source =>
                this.httpClient.post({
                    endpoint: "",
                    body: record_source,
                }),
            delete: id =>
                this.httpClient.delete({
                    endpoint: "/" + id,
                }),
            update: (record_source, id) =>
                this.httpClient.put({
                    endpoint: "/" + id,
                    body: record_source,
                }),
            get: id =>
                this.httpClient.get({
                    endpoint: "/" + id,
                }),
            getAll: (query, params) =>
                this.httpClient.getAll({
                    endpoint: "/",
                    query,
                    params,
                    headers: {},
                }),
            count: (query = {}) =>
                this.httpClient.count({
                    endpoint:
                        "?" +
                        new URLSearchParams({
                            _page: 1,
                            _per_page: 1,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                }),
        };
    }
}

export default RecordSourcesAPIClient;
