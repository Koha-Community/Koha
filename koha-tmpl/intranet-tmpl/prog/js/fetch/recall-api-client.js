export class RecallAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/cgi-bin/koha/svc/recall",
        });
    }

    get recalls() {
        return {
            cancel: recall_id =>
                this.httpClient.post({
                    endpoint: "",
                    body: "recall_id=%s&op=%s".format(recall_id, "cud-cancel"),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                }),
            expire: recall_id =>
                this.httpClient.post({
                    endpoint: "",
                    body: "recall_id=%s&op=%s".format(recall_id, "cud-expire"),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                }),

            revert: recall_id =>
                this.httpClient.post({
                    endpoint: "",
                    body: "recall_id=%s&op=%s".format(recall_id, "cud-revert"),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                }),

            overdue: recall_id =>
                this.httpClient.post({
                    endpoint: "",
                    body: "recall_id=%s&op=%s".format(recall_id, "cud-overdue"),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                }),

            transit: recall_id =>
                this.httpClient.post({
                    endpoint: "",
                    body: "recall_id=%s&op=%s".format(recall_id, "cud-transit"),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                }),
        };
    }
}

export default RecallAPIClient;
