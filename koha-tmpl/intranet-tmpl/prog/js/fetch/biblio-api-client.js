export class BiblioAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/api/v1/",
        });
    }

    /**
     * Return API operations scoped to a bibliographic record.
     *
     * @returns {Object} Bibliographic record API operations.
     */
    get biblios() {
        return {
            delete: id =>
                this.httpClient.delete({
                    endpoint: "biblios/" + id,
                }),
            /**
             * Fetch items belonging to a bibliographic record.
             *
             * @param {string|number} id Bibliographic record identifier.
             * @param {Object} [params] Pagination and request parameters.
             * @param {Object} [headers] Request headers.
             * @param {Object} [config] Per-request HTTP configuration.
             * @param {Object} [query] Koha REST query.
             * @returns {Promise<Object[]>} Matching items.
             */
            items: (id, params, headers, config, query) =>
                this.httpClient.getAll({
                    endpoint: "biblios/" + id + "/items",
                    params,
                    query,
                    headers,
                    config,
                }),
            /**
             * Fetch bookings belonging to a bibliographic record.
             *
             * @param {string|number} id Bibliographic record identifier.
             * @param {Object} [query] Koha REST query.
             * @param {Object} [params] Pagination and request parameters.
             * @returns {Promise<Object[]>} Matching bookings.
             */
            bookings: (id, query, params) =>
                this.httpClient.getAll({
                    endpoint: "biblios/" + id + "/bookings",
                    query,
                    params,
                }),
            /**
             * Fetch booking availability for a bibliographic record.
             *
             * @param {string|number} id Bibliographic record identifier.
             * @param {Object} params Availability query parameters.
             * @param {Object} [config] Per-request HTTP configuration.
             * @returns {Promise<Object>} Booking availability response.
             */
            booking_availability: (id, params, config) =>
                this.httpClient.get({
                    endpoint:
                        "biblios/" +
                        id +
                        "/booking_availability?" +
                        new URLSearchParams(params),
                    config,
                }),
            /**
             * Fetch current checkouts for a bibliographic record.
             *
             * @param {string|number} id Bibliographic record identifier.
             * @returns {Promise<Object[]>} Matching checkouts.
             */
            checkouts: id =>
                this.httpClient.getAll({
                    endpoint: "biblios/" + id + "/checkouts",
                }),
            /**
             * Fetch valid pickup locations for a bibliographic record.
             *
             * @param {string|number} id Bibliographic record identifier.
             * @param {Object} [params] Pickup-location query parameters.
             * @param {Object} [config] Per-request HTTP configuration.
             * @returns {Promise<Object[]>} Matching pickup locations.
             */
            pickup_locations: (id, params, config) =>
                this.httpClient.getAll({
                    endpoint: "biblios/" + id + "/pickup_locations",
                    params,
                    config,
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
