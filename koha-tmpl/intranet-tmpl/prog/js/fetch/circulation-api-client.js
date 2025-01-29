export class CirculationAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/cgi-bin/koha/svc/",
        });
    }

    get checkins() {
        return {
            create: checkin =>
                this.httpClient.post({
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
            renew: checkout =>
                this.httpClient.post({
                    endpoint: "renew",
                    body:
                        "itemnumber=%s&borrowernumber=%s&branchcode=%s&override_limit=%s".format(
                            checkout.item_id,
                            checkout.patron_id,
                            checkout.library_id,
                            checkout.override_limit
                        ) +
                        (checkout.seen !== undefined
                            ? "&seen=%s".format(checkout.seen)
                            : "") +
                        (checkout.date_due !== undefined
                            ? "&date_due=%s".format(checkout.date_due)
                            : ""),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                }),
            mark_as_seen: checkout_id =>
                this.httpClient.post({
                    endpoint: "checkout_notes",
                    body: "issue_id=%s&op=%s".format(checkout_id, "cud-seen"),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                }),
            mark_as_not_seen: checkout_id =>
                this.httpClient.post({
                    endpoint: "checkout_notes",
                    body: "issue_id=%s&op=%s".format(
                        checkout_id,
                        "cud-notseen"
                    ),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                }),
        };
    }
}

export default CirculationAPIClient;
