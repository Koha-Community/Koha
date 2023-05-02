import HttpClient from "./http-client";

export class PatronAPIClient extends HttpClient {
    constructor() {
        super({
            baseURL: "/api/v1/",
        });
    }

    get patrons() {
        return {
            get: id =>
                this.get({
                    endpoint: "patrons/" + id,
                }),
        };
    }
}

export default PatronAPIClient;
