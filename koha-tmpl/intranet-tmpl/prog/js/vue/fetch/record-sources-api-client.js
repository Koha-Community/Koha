import HttpClient from "./http-client";

export class RecordSourcesAPIClient extends HttpClient {
    constructor() {
        super({
            baseURL: "/api/v1/record_sources",
        });
    }

    get record_sources() {
        return {
            create: record_source =>
                this.post({
                    endpoint: "",
                    body: record_source,
                }),
            delete: id =>
                this.delete({
                    endpoint: "/" + id,
                }),
            update: (record_source, id) =>
                this.put({
                    endpoint: "/" + id,
                    body: record_source,
                }),
            get: id =>
                this.get({
                    endpoint: "/" + id,
                }),
            getAll: (query, params) =>
                this.getAll({
                    endpoint: "/",
                    query,
                    params,
                    headers: {},
                }),
            count: (query = {}) =>
                this.count({
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
