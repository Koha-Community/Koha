export class PreservationAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/api/v1/preservation/",
        });
    }

    get config() {
        return {
            get: () =>
                this.httpClient.get({
                    endpoint: "config",
                }),
        };
    }

    get trains() {
        return {
            get: id =>
                this.httpClient.get({
                    endpoint: "trains/" + id,
                    headers: {
                        "x-koha-embed":
                            "default_processing,default_processing.attributes,items,items.attributes,items.attributes+strings,items.attributes.processing_attribute,items.processing",
                    },
                }),
            getAll: (query = {}) =>
                this.httpClient.get({
                    endpoint:
                        "trains?" +
                        new URLSearchParams({
                            _per_page: -1,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                }),
            delete: id =>
                this.httpClient.delete({
                    endpoint: "trains/" + id,
                }),
            create: train =>
                this.httpClient.post({
                    endpoint: "trains",
                    body: train,
                }),
            update: (train, id) =>
                this.httpClient.put({
                    endpoint: "trains/" + id,
                    body: train,
                }),
            count: (query = {}) =>
                this.httpClient.count({
                    endpoint:
                        "trains?" +
                        new URLSearchParams({
                            _page: 1,
                            _per_page: 1,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                }),
        };
    }

    get processings() {
        return {
            get: id =>
                this.httpClient.get({
                    endpoint: "processings/" + id,
                    headers: {
                        "x-koha-embed": "attributes",
                    },
                }),
            getAll: query =>
                this.httpClient.get({
                    endpoint:
                        "processings?" +
                        new URLSearchParams({
                            _per_page: -1,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                }),

            delete: id =>
                this.httpClient.delete({
                    endpoint: "processings/" + id,
                }),
            create: processing =>
                this.httpClient.post({
                    endpoint: "processings",
                    body: processing,
                }),
            update: (processing, id) =>
                this.httpClient.put({
                    endpoint: "processings/" + id,
                    body: processing,
                }),
            count: (query = {}) =>
                this.httpClient.count({
                    endpoint:
                        "processings?" +
                        new URLSearchParams({
                            _page: 1,
                            _per_page: 1,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                }),
        };
    }

    get train_items() {
        return {
            get: (train_id, id) =>
                this.httpClient.get({
                    endpoint: "trains/" + train_id + "/items/" + id,
                    headers: {
                        "x-koha-embed":
                            "attributes,catalogue_item,catalogue_item.biblio",
                    },
                }),
            delete: (train_id, id) =>
                this.httpClient.delete({
                    endpoint: "trains/" + train_id + "/items/" + id,
                }),
            create: (train_item, train_id) =>
                this.httpClient.post({
                    endpoint: "trains/" + train_id + "/items",
                    body: train_item,
                }),
            createAll: (train_items, train_id) =>
                this.httpClient.post({
                    endpoint: "trains/" + train_id + "/items/batch",
                    body: train_items,
                }),
            copy: (new_train_id, train_id, id) =>
                this.httpClient.post({
                    endpoint: "trains/" + train_id + "/items/" + id + "/copy",
                    body: { train_id: new_train_id },
                }),
            update: (train_item, train_id, id) =>
                this.httpClient.put({
                    endpoint: "trains/" + train_id + "/items/" + id,
                    body: train_item,
                }),
            count: (train_id, query = {}) =>
                this.httpClient.count({
                    endpoint:
                        "trains/" +
                        train_id +
                        "/items?" +
                        new URLSearchParams({
                            _page: 1,
                            _per_page: 1,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                }),
        };
    }

    get waiting_list_items() {
        return {
            get_from_barcode: barcode => {
                const q = {
                    "me.barcode": barcode,
                };

                const params = {
                    _page: 1,
                    _per_page: 1,
                    q: JSON.stringify(q),
                };
                return this.httpClient
                    .get({
                        endpoint:
                            "waiting-list/items?" + new URLSearchParams(params),
                        headers: {
                            "x-koha-embed": "biblio",
                        },
                    })
                    .then(response => {
                        return response.length ? response[0] : undefined;
                    });
            },
            delete: id =>
                this.httpClient.delete({
                    endpoint: "waiting-list/items/" + id,
                }),
            createAll: items =>
                this.httpClient.post({
                    endpoint: "waiting-list/items",
                    body: items,
                }),
            count: (query = {}) =>
                this.httpClient.count({
                    endpoint:
                        "waiting-list/items?" +
                        new URLSearchParams({
                            _page: 1,
                            _per_page: 1,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                }),
        };
    }
}

export default PreservationAPIClient;
