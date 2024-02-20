import HttpClient from "./http-client.js";

export class ClubAPIClient extends HttpClient {
    constructor() {
        super({
            baseURL: "/cgi-bin/koha/svc/club/",
        });
    }

    get templates() {
        return {
            delete: template_id =>
                this.post({
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
                this.post({
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
                this.post({
                    endpoint: "cancel_enrollment",
                    body: "id=%s&op=%s".format(enrollment_id, "cud-delete"),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                }),

            enroll: data =>
                this.post({
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
