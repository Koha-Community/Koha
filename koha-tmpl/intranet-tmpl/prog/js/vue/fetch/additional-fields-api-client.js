import HttpClient from "./http-client";

export class AdditionalFieldsAPIClient extends HttpClient {
    constructor() {
        super({
            baseURL: "/api/v1/extended_attribute_types",
        });
    }

    get additional_fields() {
        return {
            getAll: resource_type =>
                this.get({
                    endpoint: "?resource_type=" + resource_type,
                }),
        };
    }
}

export default AdditionalFieldsAPIClient;
