import HttpClient from "./http-client.js";

export class CirculationAPIClient extends HttpClient {
    constructor() {
        super({
            baseURL: "/cgi-bin/koha/svc/",
        });
    }

    get checkins() {
        return {
            create: checkin =>
                this.post({
                    endpoint: "checkin",
                    body: "itemnumber=%s&borrowernumber=%s&branchcode=%s&exempt_fine=%s&op=%s".format(
                        checkin.item_id,
                        checkin.patron_id,
                        checkin.library_id,
                        checkin.exempt_fine,
                        "cud-checkin"
                    ),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                }),
        };
    }

    get checkouts() {
        return {
            mark_as_seen: checkout_id =>
                this.post({
                    endpoint: "checkout_notes",
                    body: "issue_id=%s&op=%s".format(checkout_id, "cud-seen"),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                }),
            mark_as_not_seen: checkout_id =>
                this.post({
                    endpoint: "checkout_notes",
                    body: "issue_id=%s&op=%s".format(checkout_id, "cud-notseen"),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                })
        }
    }
}

export default CirculationAPIClient;
