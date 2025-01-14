import HttpClient from "./http-client.js";

export class CoverImageAPIClient extends HttpClient {
    constructor() {
        super({
            baseURL: "/cgi-bin/koha/svc/cover_images",
        });
    }

    get cover_images() {
        return {
            delete: image_id =>
                this.post({
                    endpoint: "",
                    body: "imagenumber=%s&op=%s".format(image_id, "cud-delete"),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                }),
        };
    }
}

export default CoverImageAPIClient;
