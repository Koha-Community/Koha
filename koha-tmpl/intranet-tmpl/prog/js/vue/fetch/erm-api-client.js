import HttpClient from "./http-client";

export class ERMAPIClient extends HttpClient {
    constructor() {
        super({
            baseURL: "/api/v1/erm/",
        });
    }

    get config() {
        return {
            get: () =>
                this.get({
                    endpoint: "config",
                }),
        };
    }

    get agreements() {
        return {
            get: id =>
                this.get({
                    endpoint: "agreements/" + id,
                    headers: {
                        "x-koha-embed":
                            "periods,user_roles,user_roles.patron,agreement_licenses,agreement_licenses.license,agreement_relationships,agreement_relationships.related_agreement,documents,agreement_packages,agreement_packages.package,vendor",
                    },
                }),
            getAll: (query, params) =>
                this.getAll({
                    endpoint: "agreements",
                    query,
                    params,
                }),
            delete: id =>
                this.delete({
                    endpoint: "agreements/" + id,
                }),
            create: agreement =>
                this.post({
                    endpoint: "agreements",
                    body: agreement,
                }),
            update: (agreement, id) =>
                this.put({
                    endpoint: "agreements/" + id,
                    body: agreement,
                }),
            count: (query = {}) =>
                this.count({
                    endpoint:
                        "agreements?" +
                        new URLSearchParams({
                            _page: 1,
                            _per_page: 1,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                }),
        };
    }

    get licenses() {
        return {
            get: id =>
                this.get({
                    endpoint: "licenses/" + id,
                    headers: {
                        "x-koha-embed":
                            "user_roles,user_roles.patron,vendor,documents",
                    },
                }),
            getAll: (query, params) =>
                this.getAll({
                    endpoint: "licenses",
                    query,
                    params,
                    headers: {
                        "x-koha-embed": "vendor",
                    },
                }),
            delete: id =>
                this.delete({
                    endpoint: "licenses/" + id,
                }),
            create: license =>
                this.post({
                    endpoint: "licenses",
                    body: license,
                }),
            update: (license, id) =>
                this.put({
                    endpoint: "licenses/" + id,
                    body: license,
                }),
            count: (query = {}) =>
                this.count({
                    endpoint:
                        "licenses?" +
                        new URLSearchParams({
                            _page: 1,
                            _per_page: 1,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                }),
        };
    }

    get localPackages() {
        return {
            get: id =>
                this.get({
                    endpoint: "eholdings/local/packages/" + id,
                    headers: {
                        "x-koha-embed":
                            "package_agreements,package_agreements.agreement,resources+count,vendor",
                    },
                }),
            getAll: (query, params) =>
                this.getAll({
                    endpoint: "eholdings/local/packages",
                    query,
                    params,
                    headers: {
                        "x-koha-embed": "resources+count,vendor.name",
                    },
                }),
            delete: id =>
                this.delete({
                    endpoint: "eholdings/local/packages/" + id,
                }),
            create: local_package =>
                this.post({
                    endpoint: "eholdings/local/packages",
                    body: local_package,
                }),
            update: (local_package, id) =>
                this.put({
                    endpoint: "eholdings/local/packages/" + id,
                    body: local_package,
                }),
            count: (query = {}) =>
                this.count({
                    endpoint:
                        "eholdings/local/packages?" +
                        new URLSearchParams({
                            _page: 1,
                            _per_page: 1,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                }),
        };
    }

    get localTitles() {
        return {
            get: id =>
                this.get({
                    endpoint: "eholdings/local/titles/" + id,
                    headers: {
                        "x-koha-embed": "resources,resources.package",
                    },
                }),
            delete: id =>
                this.delete({
                    endpoint: "eholdings/local/titles/" + id,
                }),
            create: local_package =>
                this.post({
                    endpoint: "eholdings/local/titles",
                    body: local_package,
                }),
            update: (local_package, id) =>
                this.put({
                    endpoint: "eholdings/local/titles/" + id,
                    body: local_package,
                }),
            count: (query = {}) =>
                this.count({
                    endpoint:
                        "eholdings/local/titles?" +
                        new URLSearchParams({
                            _page: 1,
                            _per_page: 1,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                }),
            import: body =>
                this.post({
                    endpoint: "eholdings/local/titles/import",
                    body,
                }),
        };
    }

    get localResources() {
        return {
            get: id =>
                this.get({
                    endpoint: "eholdings/local/resources/" + id,
                    headers: {
                        "x-koha-embed": "title,package,vendor",
                    },
                }),
        };
    }

    get EBSCOPackages() {
        return {
            get: id =>
                this.get({
                    endpoint: "eholdings/ebsco/packages/" + id,
                    headers: {
                        "x-koha-embed":
                            "package_agreements,package_agreements.agreement,resources+count,vendor",
                    },
                }),
            patch: (id, body) =>
                this.patch({
                    endpoint: "eholdings/ebsco/packages/" + id,
                    body,
                }),
        };
    }

    get EBSCOTitles() {
        return {
            get: id =>
                this.get({
                    endpoint: "eholdings/ebsco/titles/" + id,
                    headers: {
                        "x-koha-embed": "resources,resources.package",
                    },
                }),
        };
    }

    get EBSCOResources() {
        return {
            get: id =>
                this.get({
                    endpoint: "eholdings/ebsco/resources/" + id,
                    headers: {
                        "x-koha-embed": "title,package,vendor",
                    },
                }),
            patch: (id, body) =>
                this.patch({
                    endpoint: "eholdings/ebsco/resources/" + id,
                    body,
                }),
        };
    }

    get usage_data_providers() {
        return {
            get: id =>
                this.get({
                    endpoint: "usage_data_providers/" + id,
                }),
            getAll: query =>
                this.get({
                    endpoint: "usage_data_providers",
                    query,
                }),
            delete: id =>
                this.delete({
                    endpoint: "usage_data_providers/" + id,
                }),
            create: usage_data_provider =>
                this.post({
                    endpoint: "usage_data_providers",
                    body: usage_data_provider,
                }),
            update: (usage_data_provider, id) =>
                this.put({
                    endpoint: "usage_data_providers/" + id,
                    body: usage_data_provider,
                }),
            run: (id, begin_date, end_date) =>
                this.get({
                    endpoint:
                        "usage_data_providers/" +
                        id +
                        "/run?begin_date=" +
                        begin_date +
                        "&end_date=" +
                        end_date,
                }),
            test: id =>
                this.get({
                    endpoint: "usage_data_providers/" + id + "/test_connection",
                }),
            count: (query = {}) =>
                this.count({
                    endpoint:
                        "usage_data_providers?" +
                        new URLSearchParams({
                            _page: 1,
                            _per_page: 1,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                }),
        };
    }

    get counter_files() {
        return {
            delete: id =>
                this.delete({
                    endpoint: "counter_files/" + id,
                }),
            count: (query = {}) =>
                this.count({
                    endpoint:
                        "counter_files?" +
                        new URLSearchParams({
                            _page: 1,
                            _per_page: 1,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                }),
        };
    }

    get default_usage_reports() {
        return {
            getAll: query =>
                this.get({
                    endpoint: "default_usage_reports",
                    query,
                }),
            create: default_usage_report =>
                this.post({
                    endpoint: "default_usage_reports",
                    body: default_usage_report,
                }),
            delete: (id) =>
                this.delete({
                    endpoint: "default_usage_reports/" + id,
                }),
        };
    }

    get usage_platforms() {
        return {
            count: (query = {}) =>
                this.count({
                    endpoint:
                        "usage_platforms?" +
                        new URLSearchParams({
                            _page: 1,
                            _per_page: 1,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                }),
        };
    }

    get usage_items() {
        return {
            count: (query = {}) =>
                this.count({
                    endpoint:
                        "usage_items?" +
                        new URLSearchParams({
                            _page: 1,
                            _per_page: 1,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                }),
        };
    }

    get usage_databases() {
        return {
            count: (query = {}) =>
                this.count({
                    endpoint:
                        "usage_databases?" +
                        new URLSearchParams({
                            _page: 1,
                            _per_page: 1,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                }),
        };
    }

    get usage_titles() {
        return {
            count: (query = {}) =>
                this.count({
                    endpoint:
                        "usage_titles?" +
                        new URLSearchParams({
                            _page: 1,
                            _per_page: 1,
                            ...(query && { q: JSON.stringify(query) }),
                        }),
                }),
        };
    }
}

export default ERMAPIClient;
