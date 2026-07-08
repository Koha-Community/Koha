export class ItemListsAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/api/v1/item-lists",
        });
    }

    get config() {
        return {
            get: () =>
                this.httpClient.get({
                    endpoint: "/config",
                }),
        };
    }

    get item_lists() {
        return {
            create: item_list =>
                this.httpClient.post({
                    endpoint: "",
                    body: item_list,
                }),
            delete: id =>
                this.httpClient.delete({
                    endpoint: "/" + id,
                }),
            update: (item_list, id) =>
                this.httpClient.put({
                    endpoint: "/" + id,
                    body: item_list,
                }),
            get: id =>
                this.httpClient.get({
                    endpoint: "/" + id,
                    headers: { "x-koha-embed": "item_list_shares+count" },
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

    items(item_list_id) {
        return {
            add: (external_ids, item_ids) =>
                this.httpClient.post({
                    endpoint: "/" + item_list_id + "/items",
                    body: { external_ids, item_ids },
                }),
            remove: item_id =>
                this.httpClient.delete({
                    endpoint: "/" + item_list_id + "/items",
                    body: { item_ids: [item_id] },
                }),
            removeMany: item_ids =>
                this.httpClient.delete({
                    endpoint: "/" + item_list_id + "/items",
                    body: { item_ids },
                }),
            getAll: (query, params) =>
                this.httpClient.getAll({
                    endpoint: "/" + item_list_id + "/items",
                    query,
                    params,
                    headers: {},
                }),
            count: (query = {}) =>
                this.httpClient.count({
                    endpoint:
                        "/" +
                        item_list_id +
                        "/items?" +
                        new URLSearchParams({
                            _page: 1,
                            _per_page: 1,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                }),
        };
    }

    shares(item_list_id) {
        return {
            add: (patron_id, permission) =>
                this.httpClient.put({
                    endpoint: "/" + item_list_id + "/shares",
                    body: { patron_id, permission },
                }),
            remove: patron_id =>
                this.httpClient.delete({
                    endpoint: "/" + item_list_id + "/shares/" + patron_id,
                }),
            getAll: (query, params) =>
                this.httpClient.getAll({
                    endpoint: "/" + item_list_id + "/shares",
                    query,
                    params,
                    headers: {},
                }),
            count: (query = {}) =>
                this.httpClient.count({
                    endpoint:
                        "/" +
                        item_list_id +
                        "/shares?" +
                        new URLSearchParams({
                            _page: 1,
                            _per_page: 1,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                }),
        };
    }
}

export default ItemListsAPIClient;
