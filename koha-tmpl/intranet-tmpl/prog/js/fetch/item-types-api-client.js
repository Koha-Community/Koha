export class ItemTypesAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/api/v1/item_types",
        });
    }

    get types() {
        return {
            getAll: () =>
                this.httpClient.getAll({
                    endpoint: "",
                }),
        };
    }
}

export default ItemTypesAPIClient;
