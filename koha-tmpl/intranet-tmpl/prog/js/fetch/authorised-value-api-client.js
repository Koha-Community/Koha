import HttpClient from "./http-client.js";

export class AVAPIClient extends HttpClient {
    constructor() {
        super({
            baseURL: "/cgi-bin/koha/svc/authorised_values",
            headers: {
                "Content-Type":
                    "application/x-www-form-urlencoded;charset=utf-8",
            },
        });
    }

    get values() {
        return {
            create: value =>
                this.post({
                    endpoint: "",
                    body: "category=%s&value=%s&description=%s&opac_description=%s".format(
                        encodeURIComponent(value.category),
                        encodeURIComponent(value.value),
                        encodeURIComponent(value.description),
                        encodeURIComponent(value.opac_description),
                    ),
                }),
        };
    }
}

export default AVAPIClient;
