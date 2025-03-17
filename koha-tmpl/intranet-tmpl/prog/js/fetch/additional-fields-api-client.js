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

export default AdditionalFieldsAPIClient;
