export class CoverImageAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/cgi-bin/koha/svc/cover_images",
        });
    }

    get cover_images() {
        return {
            delete: image_id =>
                this.httpClient.post({
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
