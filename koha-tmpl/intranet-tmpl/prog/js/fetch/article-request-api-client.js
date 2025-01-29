export class ArticleRequestAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/cgi-bin/koha/svc/article_request",
            headers: {
                "Content-Type":
                    "application/x-www-form-urlencoded;charset=utf-8",
            },
        });
    }

    get articleRequests() {
        return {
            process: id =>
                this.httpClient.post({
                    endpoint: "",
                    body: "id=%s&op=%s".format(id, "cud-process"),
                }),
            complete: id =>
                this.httpClient.post({
                    endpoint: "",
                    body: "id=%s&op=%s".format(id, "cud-complete"),
                }),
            pending: id =>
                this.httpClient.post({
                    endpoint: "",
                    body: "id=%s&op=%s".format(id, "cud-pending"),
                }),
            update_urls: (id, urls) =>
                this.httpClient.post({
                    endpoint: "",
                    body: "id=%s&urls=%s&op=%s".format(
                        id,
                        urls,
                        "cud-update_urls"
                    ),
                }),
            update_library_id: (id, library_id) =>
                this.httpClient.post({
                    endpoint: "",
                    body: "id=%s&library_id=%s&op=%s".format(
                        id,
                        library_id,
                        "cud-update_library_id"
                    ),
                }),
        };
    }
}

export default ArticleRequestAPIClient;
