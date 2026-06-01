export class BookingAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/api/v1",
        });
    }

    get bookings() {
        return {
            create: booking =>
                this.httpClient.post({
                    endpoint: "/bookings",
                    body: booking,
                }),
            update: (booking, id) =>
                this.httpClient.put({
                    endpoint: "/bookings/" + id,
                    body: booking,
                }),
        };
    }
}

export default BookingAPIClient;
