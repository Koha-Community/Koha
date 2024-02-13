import HttpClient from "./http-client.js";

export class ArticleRequestAPIClient extends HttpClient {
    constructor() {
        super({
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
                this.post({
                    endpoint: "",
                    body: "id=%s&op=%s".format(id, "cud-process"),
                }),
            complete: id =>
                this.post({
                    endpoint: "",
                    body: "id=%s&op=%s".format(id, "cud-complete"),
                }),
            pending: id =>
                this.post({
                    endpoint: "",
                    body: "id=%s&op=%s".format(id, "cud-pending"),
                }),
            update_urls: (id, urls) =>
                this.post({
                    endpoint: "",
                    body: "id=%s&urls=%s&op=%s".format(
                        id,
                        urls,
                        "cud-update_urls"
                    ),
                }),
            update_library_id: (id, library_id) =>
                this.post({
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
