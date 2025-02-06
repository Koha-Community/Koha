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
                        "x-koha-embed":
                            "custom_item_fields,item_fields,custom_patron_fields,patron_attributes,sort_bin_mappings,system_preference_overrides",
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

    get listeners() {
        return {
            get: id =>
                this.get({
                    endpoint: "listeners/" + id,
                }),
            getAll: params =>
                this.getAll({
                    endpoint: "listeners",
                }),
            delete: id =>
                this.delete({
                    endpoint: "listeners/" + id,
                }),
            create: listener =>
                this.post({
                    endpoint: "listeners",
                    body: listener,
                }),
            update: (listener, id) =>
                this.put({
                    endpoint: "listeners/" + id,
                    body: listener,
                }),
            count: (query = {}) =>
                this.count({
                    endpoint:
                        "listeners?" +
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
