export class ClubAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/cgi-bin/koha/svc/club/",
        });
    }

    get templates() {
        return {
            delete: template_id =>
                this.httpClient.post({
                    endpoint: "template/delete",
                    body: "id=%s&op=%s".format(template_id, "cud-delete"),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                }),
        };
    }

    get clubs() {
        return {
            delete: club_id =>
                this.httpClient.post({
                    endpoint: "delete",
                    body: "id=%s&op=%s".format(club_id, "cud-delete"),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                }),
        };
    }

    get enrollments() {
        return {
            cancel: enrollment_id =>
                this.httpClient.post({
                    endpoint: "cancel_enrollment",
                    body: "id=%s&op=%s".format(enrollment_id, "cud-delete"),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                }),

            enroll: data =>
                this.httpClient.post({
                    endpoint: "enroll",
                    body: "%s&op=%s".format(
                        data, // Could do better, but too much work for now!
                        "cud-enroll"
                    ),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                }),
        };
    }
}

export default ClubAPIClient;
