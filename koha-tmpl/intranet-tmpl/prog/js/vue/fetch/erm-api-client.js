import HttpClient from "./http-client";

export class ERMAPIClient extends HttpClient {
    constructor() {
        super({
            baseURL: "/api/v1/erm/",
        });
    }

    get agreements() {
        return {
            get: (id) =>
                this.get({
                    endpoint: "agreements/" + id,
                    headers: {
                        "x-koha-embed":
                            "periods,user_roles,user_roles.patron,agreement_licenses,agreement_licenses.license,agreement_relationships,agreement_relationships.related_agreement,documents,agreement_packages,agreement_packages.package,vendor",
                    },
                }),
            getAll: (query) =>
                this.get({
                    endpoint: "agreements?" + (query || "_per_page=-1"),
                }),
            delete: (id) =>
                this.delete({
                    endpoint: "agreements/" + id,
                    headers: this.getDefaultJSONPayloadHeader(),
                }),
            create: (agreement) =>
                this.post({
                    endpoint: "agreements",
                    body: agreement,
                    headers: this.getDefaultJSONPayloadHeader(),
                }),
            update: (agreement, id) =>
                this.put({
                    endpoint: "agreements/" + id,
                    body: agreement,
                    headers: this.getDefaultJSONPayloadHeader(),
                }),
            //count: () => this.count("agreements"), //TODO: Implement count method
        };
    }
}

export default ERMAPIClient;
