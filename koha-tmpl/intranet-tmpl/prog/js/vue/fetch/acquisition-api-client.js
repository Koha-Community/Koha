import HttpClient from "./http-client";

export class AcquisitionAPIClient extends HttpClient {
    constructor() {
        super({
            baseURL: "/api/v1/acquisitions/",
        });
    }

    get vendors() {
        return {
            getAll: (query, params) =>
                this.get({
                    endpoint: "vendors",
                    query,
                    params,
                    headers: {
                        "x-koha-embed": "aliases",
                    },
                }),
        };
    }
}

export default AcquisitionAPIClient;
