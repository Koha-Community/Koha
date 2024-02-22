import HttpClient from "./http-client.js";

export class PatronAPIClient extends HttpClient {
    constructor() {
        super({
            baseURL: "/cgi-bin/koha/svc/",
        });
    }

    get lists() {
        return {
            add_patrons: ({ patron_ids, list_id, new_list_name }) =>
                this.post({
                    endpoint: "members/add_to_list",
                    body: "add_to_patron_list=%s&new_patron_list=%s&%s".format(
                        list_id,
                        new_list_name,
                        patron_ids
                            .map(id => "borrowernumber=%s".format(id))
                            .join("&")
                    ),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                }),
        };
    }
}

export default PatronAPIClient;
