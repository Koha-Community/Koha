const { APIClient } = require("./../../plugins/dist/api-client.cjs.js");

describe("Using APIClient", () => {
    let client = APIClient.default;
    it("should 404 for non-existent biblio", async () => {
        try {
            await client.koha.get({
                endpoint: "/api/v1/public/biblios/99999",
                return_response: true,
            });
        } catch (error) {
            expect(error.response.status).to.equal(404);
        }
    });
});

describe("Using the api-client plugin", () => {
    it("should 404 for non-existent biblio", async () => {
        try {
            await cy.task("apiGet", {
                endpoint: "/api/v1/public/biblios/99999",
                return_response: true,
            });
        } catch (error) {
            expect(error.response.status).to.equal(404);
        }
    });
});
