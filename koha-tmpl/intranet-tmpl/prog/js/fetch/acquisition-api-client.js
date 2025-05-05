export class AcquisitionAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/api/v1/acquisitions/",
        });
    }

    get config() {
        return {
            get: moduleEndpoint =>
                this.httpClient.get({
                    endpoint: moduleEndpoint + "/config",
                }),
        };
    }

    get vendors() {
        return {
            get: id =>
                this.httpClient.get({
                    endpoint: "vendors/" + id,
                    headers: {
                        "x-koha-embed":
                            "aliases,subscriptions+count,interfaces,contacts,contracts,baskets+count,invoices+count",
                    },
                }),
            getAll: (query, params) =>
                this.httpClient.getAll({
                    endpoint: "vendors",
                    query,
                    params: { _order_by: "name", ...params },
                    headers: {
                        "x-koha-embed": "aliases,baskets+count",
                    },
                }),
            delete: id =>
                this.httpClient.delete({
                    endpoint: "vendors/" + id,
                }),
            create: vendor =>
                this.httpClient.post({
                    endpoint: "vendors",
                    body: vendor,
                }),
            update: (vendor, id) =>
                this.httpClient.put({
                    endpoint: "vendors/" + id,
                    body: vendor,
                }),
            count: (query = {}) =>
                this.httpClient.count({
                    endpoint:
                        "vendors?" +
                        new URLSearchParams({
                            _page: 1,
                            _per_page: 1,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                }),
        };
    }

    get baskets() {
        return {
            count: (query = {}) =>
                this.httpClient.count({
                    endpoint:
                        "baskets?" +
                        new URLSearchParams({
                            _page: 1,
                            _per_page: 1,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                }),
        };
    }
}

export default AcquisitionAPIClient;
