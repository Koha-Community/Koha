import HttpClient from "./http-client.js";

export class CataloguingAPIClient extends HttpClient {
    constructor() {
        super({
            baseURL: "/cgi-bin/koha/svc/",
        });
    }

    get catalog_bib() {
        return {
            create: bib_info =>
                this.post({
                    endpoint: "new_bib/frameworkcode=%s".format(
                        bib_info.frameworkcode
                    ),
                    body: bib_info.record.toXML(),
                    headers: {
                        "Content-Type": "text/xml",
                    },
                }),
            update: bib_info =>
                this.post({
                    endpoint: "bib/%s?frameworkcode=%s".format(
                        bib_info.id,
                        bib_info.frameworkcode
                    ),
                    body: bib_info.record.toXML(),
                    headers: {
                        "Content-Type": "text/xml",
                    },
                }),
        };
    }
}

export default CataloguingAPIClient;
