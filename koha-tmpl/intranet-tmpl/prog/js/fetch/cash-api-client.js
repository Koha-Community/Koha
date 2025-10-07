export class CashAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/api/v1/",
        });
    }

    get cash_registers() {
        return {
            getAll: (query, params, headers) =>
                this.httpClient.getAll({
                    endpoint: "cash_registers",
                    query,
                    params,
                    headers,
                }),
        };
    }
}

export default CashAPIClient;
