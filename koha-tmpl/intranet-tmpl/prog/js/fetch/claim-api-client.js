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
            resolve: (claim_id, { resolution, new_lost_status } = {}) =>
                this.httpClient.put({
                    endpoint: `/return_claims/${claim_id}/resolve`,
                    body: {
                        resolution,
                        ...(new_lost_status ? { new_lost_status } : {}),
                    },
                }),
        };
    }
}

export default ClaimAPIClient;
