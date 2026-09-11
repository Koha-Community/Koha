export class PatronAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/api/v1/",
        });
    }

    /**
     * Return patron retrieval and search operations.
     *
     * @returns {Object} Patron API operations.
     */
    get patrons() {
        return {
            /**
             * Fetch a patron.
             *
             * @param {string|number} id Patron identifier.
             * @param {Object} [headers] Request headers.
             * @param {Object} [config] Per-request HTTP configuration.
             * @returns {Promise<Object>} Patron representation.
             */
            get: (id, headers, config) =>
                this.httpClient.get({
                    endpoint: "patrons/" + id,
                    headers,
                    config,
                }),
            /**
             * Search for patrons.
             *
             * @param {Object} [query] Koha REST query.
             * @param {Object} [params] Pagination and request parameters.
             * @param {Object} [headers] Request headers.
             * @param {Object} [config] Per-request HTTP configuration.
             * @returns {Promise<Object>} Patron search response.
             */
            search: (query, params, headers, config) =>
                this.httpClient.get({
                    endpoint:
                        "patrons?" +
                        new URLSearchParams({
                            ...(query && { q: JSON.stringify(query) }),
                            ...params,
                        }).toString(),
                    headers,
                    config,
                }),
        };
    }

    get categories() {
        return {
            getAll: (query, params, headers) =>
                this.httpClient.getAll({
                    endpoint: "patron_categories",
                    query,
                    params,
                    headers,
                }),
        };
    }

    get self_renewal() {
        return {
            start: (id, query, params, headers) =>
                this.httpClient.getAll({
                    endpoint: `public/patrons/${id}/self_renewal`,
                    query,
                    params,
                    headers,
                }),
            submit: (id, renewal) =>
                this.httpClient.post({
                    endpoint: `public/patrons/${id}/self_renewal`,
                    body: renewal,
                }),
        };
    }
}

export default PatronAPIClient;
