export class SIP2APIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/api/v1/sip2/",
        });
    }

    get institutions() {
        return {
            get: id =>
                this.httpClient.get({
                    endpoint: "institutions/" + id,
                }),
            getAll: params =>
                this.httpClient.getAll({
                    endpoint: "institutions",
                }),
            delete: id =>
                this.httpClient.delete({
                    endpoint: "institutions/" + id,
                }),
            create: institution =>
                this.httpClient.post({
                    endpoint: "institutions",
                    body: institution,
                }),
            update: (institution, id) =>
                this.httpClient.put({
                    endpoint: "institutions/" + id,
                    body: institution,
                }),
            count: (query = {}) =>
                this.httpClient.count({
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
                this.httpClient.get({
                    endpoint: "accounts/" + id,
                    headers: {
                        "x-koha-embed":
                            "institution,custom_item_fields,item_fields,custom_patron_fields,patron_attributes,screen_msg_regexs,sort_bin_mappings,system_preference_overrides",
                    },
                }),
            getAll: params =>
                this.httpClient.getAll({
                    endpoint: "accounts",
                }),
            delete: id =>
                this.httpClient.delete({
                    endpoint: "accounts/" + id,
                }),
            create: account =>
                this.httpClient.post({
                    endpoint: "accounts",
                    body: account,
                }),
            update: (account, id) =>
                this.httpClient.put({
                    endpoint: "accounts/" + id,
                    body: account,
                }),
            count: (query = {}) =>
                this.httpClient.count({
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

    get system_preference_overrides() {
        return {
            get: id =>
                this.httpClient.get({
                    endpoint: "system_preference_overrides/" + id,
                }),
            getAll: params =>
                this.httpClient.getAll({
                    endpoint: "system_preference_overrides",
                }),
            delete: id =>
                this.httpClient.delete({
                    endpoint: "system_preference_overrides/" + id,
                }),
            create: system_preference_override =>
                this.httpClient.post({
                    endpoint: "system_preference_overrides",
                    body: system_preference_override,
                }),
            update: (system_preference_override, id) =>
                this.httpClient.put({
                    endpoint: "system_preference_overrides/" + id,
                    body: system_preference_override,
                }),
            count: (query = {}) =>
                this.httpClient.count({
                    endpoint:
                        "system_preference_overrides?" +
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
