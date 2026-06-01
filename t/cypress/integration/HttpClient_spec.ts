describe("HttpClient", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    it("handles C4::Service error format without crashing", () => {
        // C4::Service returns { type, message } on failure — not the OpenAPI
        // { error } or { errors: [...] } shape that http-client.js was written for.
        // Without the fix, accessing json.errors.map(...) throws:
        //   TypeError: Cannot read properties of undefined (reading 'map')
        cy.intercept("POST", "/cgi-bin/koha/svc/config/systempreferences", {
            statusCode: 400,
            headers: { "content-type": "application/json" },
            body: { type: "auth", message: "expired" },
        }).as("sysprefUpdate");

        cy.window().then(win => {
            const client = win.APIClient.sysprefs;
            return client.sysprefs
                .update("WebBasedSelfCheck", "1")
                .catch(err => {
                    expect(err.message).to.include("expired");
                });
        });

        cy.wait("@sysprefUpdate");
    });
});
