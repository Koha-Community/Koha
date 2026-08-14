export class BiblioAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/api/v1/",
        });
    }

    get biblios() {
        return {
            delete: id =>
                this.httpClient.delete({
                    endpoint: "biblios/" + id,
                }),
        };
    }

    get items() {
        return {
            get: id =>
                this.httpClient.get({
                    endpoint: "biblios/" + id + "/items",
                }),
        };
    }
}

export default BiblioAPIClient;
