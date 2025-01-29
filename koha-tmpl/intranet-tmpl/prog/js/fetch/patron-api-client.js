export class PatronAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/api/v1/",
        });
    }

    get patrons() {
        return {
            get: id =>
                this.httpClient.get({
                    endpoint: "patrons/" + id,
                }),
        };
    }
}

export default PatronAPIClient;
