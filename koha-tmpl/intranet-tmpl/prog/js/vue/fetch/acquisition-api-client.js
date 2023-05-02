import HttpClient from "./http-client";

export class AcquisitionAPIClient extends HttpClient {
    constructor() {
        super({
            baseURL: "/api/v1/acquisitions/",
        });
    }

    get vendors() {
        return {
            getAll: query =>
                this.get({
                    endpoint: "vendors?" + (query || "_per_page=-1"),
                    headers: {
                        "x-koha-embed": "aliases",
                    },
                }),
        };
    }
}

export default AcquisitionAPIClient;
