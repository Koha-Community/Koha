export class CataloguingAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/api/v1/",
        });
    }

    get cash_registers() {
        return {
            getAll: (query, params, headers) =>
                this.getAll({
                    endpoint: "cash_registers",
                    query,
                    params,
                    headers,
                }),
        };
    }
}

export default CashAPIClient;
