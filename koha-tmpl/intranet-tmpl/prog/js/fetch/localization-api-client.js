import HttpClient from "./http-client.js";

export class LocalizationAPIClient extends HttpClient {
    constructor() {
        super({
            baseURL: "/cgi-bin/koha/svc/localization",
        });
    }

    get localizations() {
        return {
            create: localization =>
                this.post({
                    endpoint: "",
                    body: "entity=%s&code=%s&lang=%s&translation=%s".format(
                        encodeURIComponent(localization.entity),
                        encodeURIComponent(localization.code),
                        encodeURIComponent(localization.lang),
                        encodeURIComponent(localization.translation)
                    ),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                }),
            update: localization =>
                this.put({
                    endpoint: "",
                    body: "id=%s&lang=%s&translation=%s".format(
                        encodeURIComponent(localization.id),
                        encodeURIComponent(localization.lang),
                        encodeURIComponent(localization.translation)
                    ),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                }),
            delete: id =>
                this.delete({
                    endpoint: "/?id=%s".format(id),
                    headers: {
                        "Content-Type":
                            "application/x-www-form-urlencoded;charset=utf-8",
                    },
                }),
        };
    }
}

export default LocalizationAPIClient;
