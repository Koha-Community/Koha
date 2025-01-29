export class TicketAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/cgi-bin/koha/svc/",
        });
    }

    get tickets() {
        return {
            mark_as_viewed: ticket_id =>
                this.httpClient.post({
                    endpoint: "problem_reports",
                    body: "report_id=%s&op=%s".format(ticket_id, "cud-viewed"),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                }),
            mark_as_closed: ticket_id =>
                this.httpClient.post({
                    endpoint: "problem_reports",
                    body: "report_id=%s&op=%s".format(ticket_id, "cud-closed"),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                }),
            mark_as_new: ticket_id =>
                this.httpClient.post({
                    endpoint: "problem_reports",
                    body: "report_id=%s&op=%s".format(ticket_id, "cud-new"),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                }),
        };
    }
}

export default TicketAPIClient;
