import { formatApiError } from "@fetch/api-error";

describe("formatApiError", () => {
    it("formats authentication and authorization errors", () => {
        const unauthorized = Object.assign(new Error("Server detail"), {
            status: 401,
        });
        const forbidden = Object.assign(new Error("Server detail"), {
            status: 403,
        });

        expect(formatApiError(unauthorized)).to.equal(
            "Your session has expired. Please log in again."
        );
        expect(formatApiError(forbidden)).to.equal(
            "You are not authorized to perform this action."
        );
    });

    it("includes messages from errors, strings, and objects", () => {
        expect(formatApiError(new Error("Request failed"))).to.equal(
            "An error occurred: Request failed"
        );
        expect(formatApiError("Network unavailable")).to.equal(
            "An error occurred: Network unavailable"
        );
        expect(formatApiError({ message: "Invalid pickup location" })).to.equal(
            "An error occurred: Invalid pickup location"
        );
    });

    it("describes transport failures without exposing the raw TypeError", () => {
        expect(formatApiError(new TypeError("Failed to fetch"))).to.equal(
            "Could not reach the server. Check your connection and try again."
        );
    });

    it("keeps the server message for a TypeError that carries a status", () => {
        const serverError = Object.assign(new TypeError("Bad payload"), {
            status: 400,
        });

        expect(formatApiError(serverError)).to.equal(
            "An error occurred: Bad payload"
        );
    });

    it("uses the unexpected-error fallback without a usable message", () => {
        [{}, null, undefined, ""].forEach(error => {
            expect(formatApiError(error)).to.equal(
                "An unexpected error occurred."
            );
        });
    });

    it("formats the message after translating its placeholder", () => {
        cy.stub(window, "__").callsFake(message =>
            message === "An error occurred: %s"
                ? "Server message: [%s]"
                : message
        );

        expect(formatApiError(new Error("Request failed"))).to.equal(
            "Server message: [Request failed]"
        );
    });
});
