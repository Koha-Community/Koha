export class DefaultAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "",
        });
    }

    get koha() {
        return {
            get: params => this.httpClient.get(params),
            getAll: params => this.httpClient.getAll(params),
            post: params => this.httpClient.post(params),
            put: params => this.httpClient.put(params),
            delete: params => this.httpClient.delete(params),
        };
    }
}

export default DefaultAPIClient;
