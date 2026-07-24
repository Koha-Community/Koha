export class SysprefAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "",
        });
    }

    get sysprefs() {
        return {
            get: variable =>
                this.httpClient.get({
                    endpoint:
                        "/cgi-bin/koha/svc/config/systempreferences/?pref=" +
                        variable,
                }),
            getAll: (query, params) =>
                this.httpClient.getAll({
                    endpoint: "/api/v1/sysprefs",
                    query,
                    params: { _order_by: "name", ...params },
                    headers: {},
                }),
            update: (variable, value) =>
                this.httpClient.post({
                    endpoint: "/cgi-bin/koha/svc/config/systempreferences",
                    body: "pref_%s=%s".format(
                        encodeURIComponent(variable),
                        encodeURIComponent(value)
                    ),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                }),
            update_all: sysprefs =>
                this.httpClient.post({
                    endpoint: "/cgi-bin/koha/svc/config/systempreferences",
                    body: Object.keys(sysprefs)
                        .map(variable =>
                            sysprefs[variable].length
                                ? sysprefs[variable].map(value =>
                                      "%s=%s".format(
                                          variable,
                                          encodeURIComponent(value)
                                      )
                                  )
                                : "%s=".format(variable)
                        )
                        .flat(Infinity)
                        .join("&"),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                }),
        };
    }
}

export default SysprefAPIClient;
