export class SIP2APIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/api/v1/sip2/",
        });
    }

    get institutions() {
        return {
            get: id =>
                this.get({
                    endpoint: "institutions/" + id,
                }),
            getAll: params =>
                this.getAll({
                    endpoint: "institutions",
                }),
            delete: id =>
                this.delete({
                    endpoint: "institutions/" + id,
                }),
            create: institution =>
                this.post({
                    endpoint: "institutions",
                    body: institution,
                }),
            update: (institution, id) =>
                this.put({
                    endpoint: "institutions/" + id,
                    body: institution,
                }),
            count: (query = {}) =>
                this.count({
                    endpoint:
                        "institutions?" +
                        new URLSearchParams({
                            _page: 1,
                            _per_page: 1,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                }),
        };
    }

    get accounts() {
        return {
            get: id =>
                this.get({
                    endpoint: "accounts/" + id,
                    headers: {
                        "x-koha-embed": "item_fields,patron_attributes",
                    },
                }),
            getAll: params =>
                this.getAll({
                    endpoint: "accounts",
                }),
            delete: id =>
                this.delete({
                    endpoint: "accounts/" + id,
                }),
            create: account =>
                this.post({
                    endpoint: "accounts",
                    body: account,
                }),
            update: (account, id) =>
                this.put({
                    endpoint: "accounts/" + id,
                    body: account,
                }),
            count: (query = {}) =>
                this.count({
                    endpoint:
                        "accounts?" +
                        new URLSearchParams({
                            _page: 1,
                            _per_page: 1,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                }),
        };
    }
}

export default SIP2APIClient;
