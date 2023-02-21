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
                }),
            create: (agreement) =>
                this.post({
                    endpoint: "agreements",
                    body: agreement,
                }),
            update: (agreement, id) =>
                this.put({
                    endpoint: "agreements/" + id,
                    body: agreement,
                }),
            //count: () => this.count("agreements"), //TODO: Implement count method
        };
    }

    get licenses() {
        return {
            get: (id) =>
                this.get({
                    endpoint: "licenses/" + id,
                    headers: {
                        "x-koha-embed":
                        "user_roles,user_roles.patron,vendor,documents"
                    },
                }),
            getAll: (query) =>
                this.get({
                    endpoint: "licenses?" + (query || "_per_page=-1"),
                    headers: {
                        "x-koha-embed": "vendor.name",
                    },
                }),
            delete: (id) =>
                this.delete({
                    endpoint: "licenses/" + id,
                }),
            create: (license) =>
                this.post({
                    endpoint: "licenses",
                    body: license,
                }),
            update: (license, id) =>
                this.put({
                    endpoint: "licenses/" + id,
                    body: license,
                }),
        };
    }
}

export default ERMAPIClient;
