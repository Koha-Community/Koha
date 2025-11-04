import ERMAPIClient from "@fetch/erm-api-client";

export class AdditionalFieldsAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/api/v1/extended_attribute_types",
        });
    }

    get additional_fields() {
        return {
            getAll: resource_type =>
                this.httpClient.getAll({
                    endpoint: "",
                    params: { resource_type },
                }),
        };
    }
}

export class AdditionalFieldsAPIClientWrapper {
    constructor(HttpClient) {
        this.clients = {
            admin: new AdditionalFieldsAPIClient(HttpClient),
            erm: new ERMAPIClient(HttpClient),
        };
    }

    get additional_fields() {
        return {
            getAll: resource_type => {
                let moduleName = this.getModuleName(resource_type);
                return this.clients[moduleName].additional_fields.getAll(
                    resource_type
                );
            },
        };
    }

    getModuleName(resource_type) {
        const moduleMappings = {
            erm: ["agreement", "license", "package"],
        };

        for (const [module, resourceTypes] of Object.entries(moduleMappings)) {
            if (resourceTypes.includes(resource_type)) return module;
        }

        return "admin";
    }
}

export default AdditionalFieldsAPIClientWrapper;
