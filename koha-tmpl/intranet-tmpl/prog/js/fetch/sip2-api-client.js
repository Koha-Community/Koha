export class SIP2APIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/api/v1/sip2",
        });
    }

    get institutions() {
        return {
            getAll: params =>
                this.getAll({
                    endpoint: "institutions",
                }),
        };
    }
}

export default SIP2APIClient;
