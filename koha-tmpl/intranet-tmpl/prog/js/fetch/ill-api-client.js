export class ILLAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/api/v1/ill/",
        });
    }

    get supplying() {
        return {
            get: id =>
                this.httpClient.get({
                    endpoint: "iso18626_requests/" + id,
                    headers: {
                        "x-koha-embed": "requesting_agency,messages,hold",
                    },
                }),
            getAll: (query, params) =>
                this.httpClient.getAll({
                    endpoint: "iso18626_requests",
                    query,
                    params,
                }),
            patch: (iso18626_request, id) =>
                this.httpClient.patch({
                    endpoint: "iso18626_requests/" + id,
                    body: iso18626_request,
                }),
            count: (query = {}) =>
                this.httpClient.count({
                    endpoint:
                        "iso18626_requests?" +
                        new URLSearchParams({
                            _page: 1,
                            _per_page: 20,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                }),
        };
    }

    get requesting_agencies() {
        return {
            get: id =>
                this.httpClient.get({
                    endpoint: "iso18626_requesting_agencies/" + id,
                    headers: {
                        "x-koha-embed": "ill_partner",
                    },
                }),
            getAll: (query, params) =>
                this.httpClient.getAll({
                    endpoint: "iso18626_requesting_agencies",
                    query,
                    params,
                }),
            delete: id =>
                this.httpClient.delete({
                    endpoint: "iso18626_requesting_agencies/" + id,
                }),
            create: iso18626_requesting_agency =>
                this.httpClient.post({
                    endpoint: "iso18626_requesting_agencies",
                    body: iso18626_requesting_agency,
                }),
            update: (iso18626_requesting_agency, id) =>
                this.httpClient.put({
                    endpoint: "iso18626_requesting_agencies/" + id,
                    body: iso18626_requesting_agency,
                }),
            count: (query = {}) =>
                this.httpClient.count({
                    endpoint:
                        "iso18626_requesting_agencies?" +
                        new URLSearchParams({
                            _page: 1,
                            _per_page: 1,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                }),
        };
    }
}

export default ILLAPIClient;
