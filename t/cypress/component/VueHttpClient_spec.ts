import { createPinia, setActivePinia } from "pinia";
import HttpClient from "@koha-vue/fetch/http-client";
import { useMainStore } from "@koha-vue/stores/main";

function response(body, status = 200, text = JSON.stringify(body)) {
    return {
        ok: status >= 200 && status < 300,
        status,
        statusText: "Server error",
        headers: { get: () => "application/json" },
        json: async () => body,
        text: async () => text,
    };
}

describe("Vue HttpClient", () => {
    let fetchStub;

    beforeEach(() => {
        setActivePinia(createPinia());
        fetchStub = cy.stub(window, "fetch");
    });

    it("returns successful JSON responses", async () => {
        fetchStub.resolves(response({ result: "ok" }));
        const client = new HttpClient({ baseURL: "/api/v1" });

        const result = await client.get({ endpoint: "/test" });

        expect(result).to.deep.equal({ result: "ok" });
    });

    it("preserves the status and error_code of an API failure", async () => {
        fetchStub.resolves(
            response(
                {
                    error: "Booking would conflict",
                    error_code: "booking_would_conflict",
                },
                400
            )
        );
        const client = new HttpClient();

        const error = await client
            .post({ endpoint: "/bookings", body: {} })
            .catch(caught => caught);

        expect(error).to.be.an.instanceOf(Error);
        expect(error.message).to.equal("Booking would conflict");
        expect(error.status).to.equal(400);
        expect(error.code).to.equal("booking_would_conflict");
    });

    it("joins structured validation errors", async () => {
        fetchStub.resolves(
            response(
                { errors: [{ message: "First" }, { message: "Second" }] },
                422
            )
        );
        const client = new HttpClient();

        const error = await client
            .get({ endpoint: "/test" })
            .catch(caught => caught);

        expect(error.message).to.equal("First\nSecond");
        expect(error.status).to.equal(422);
    });

    it("falls back to the status text for a malformed error body", async () => {
        fetchStub.resolves(response(null, 502, "<html>Bad gateway</html>"));
        const client = new HttpClient();

        const error = await client
            .get({ endpoint: "/test" })
            .catch(caught => caught);

        expect(error.message).to.equal("Server error");
        expect(error.status).to.equal(502);
    });

    it("rethrows the original network error", async () => {
        const originalError = new TypeError("Failed to fetch");
        fetchStub.callsFake(() => Promise.reject(originalError));
        const client = new HttpClient();

        const error = await client
            .get({ endpoint: "/test" })
            .catch(caught => caught);

        expect(error).to.equal(originalError);
    });

    it("surfaces a clear error for a malformed 200 OK body instead of an unhandled parse failure", async () => {
        fetchStub.resolves({
            ok: true,
            status: 200,
            statusText: "OK",
            headers: { get: () => "application/json" },
            json: async () => {
                throw new SyntaxError("Unexpected token < in JSON");
            },
            text: async () => "<html>Not JSON</html>",
        });
        const client = new HttpClient();

        const error = await client
            .get({ endpoint: "/test" })
            .catch(caught => caught);

        expect(error).to.be.an.instanceOf(Error);
        expect(error.message).to.equal(
            "Invalid response from server: could not parse JSON"
        );
        expect(error.status).to.equal(200);
    });

    it("does not surface a global error message for an aborted request", async () => {
        const abortError = new DOMException("Aborted", "AbortError");
        fetchStub.callsFake(() => Promise.reject(abortError));
        const client = new HttpClient();

        const error = await client
            .get({ endpoint: "/test" })
            .catch(caught => caught);

        expect(error).to.equal(abortError);
        expect(useMainStore().error).to.equal(null);
    });
});
