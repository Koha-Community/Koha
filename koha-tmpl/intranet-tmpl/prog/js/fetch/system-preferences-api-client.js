/* keep tidy */
import HttpClient from "./http-client.js";

export class SysprefAPIClient extends HttpClient {
    constructor() {
        super({
            baseURL: "/cgi-bin/koha/svc/config/systempreferences",
        });
    }

    get sysprefs() {
        return {
            get: variable =>
                this.get({
                    endpoint: "/?pref=" + variable,
                }),
            update: (variable, value) =>
                this.post({
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
                this.post({
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
