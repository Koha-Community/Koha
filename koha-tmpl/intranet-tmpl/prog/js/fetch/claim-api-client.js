export class ClaimAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/api/v1",
        });
    }

    get return_claims() {
        return {
            create: claim =>
                this.httpClient.post({
                    endpoint: "/return_claims",
                    body: claim,
                }),
        };
    }
}

export default ClaimAPIClient;
