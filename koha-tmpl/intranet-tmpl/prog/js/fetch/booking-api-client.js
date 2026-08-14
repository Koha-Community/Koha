export class BookingAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/api/v1",
        });
    }

    /**
     * Return booking create and update operations.
     *
     * @returns {Object} Booking API operations.
     */
    get bookings() {
        return {
            /**
             * Create a booking.
             *
             * @param {Object} booking Booking representation.
             * @param {Object} [config] Per-request HTTP configuration.
             * @returns {Promise<Object>} Created booking.
             */
            create: (booking, config) =>
                this.httpClient.post({
                    endpoint: "/bookings",
                    body: booking,
                    config,
                }),
            /**
             * Replace a booking.
             *
             * @param {Object} booking Booking representation.
             * @param {string|number} id Booking identifier.
             * @param {Object} [config] Per-request HTTP configuration.
             * @returns {Promise<Object>} Updated booking.
             */
            update: (booking, id, config) =>
                this.httpClient.put({
                    endpoint: "/bookings/" + id,
                    body: booking,
                    config,
                }),
        };
    }
}

export default BookingAPIClient;
