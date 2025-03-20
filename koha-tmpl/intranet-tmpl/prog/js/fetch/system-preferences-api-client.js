export class SysprefAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/cgi-bin/koha/svc/config/systempreferences",
        });
    }

    get sysprefs() {
        return {
            get: variable =>
                this.httpClient.get({
                    endpoint: "/?pref=" + variable,
                }),
            update: (variable, value) =>
                this.httpClient.post({
                    endpoint: "",
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
                    endpoint: "",
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
