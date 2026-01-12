describe("Suggestions", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    it("Should sanitize displayby", () => {
        cy.visit("/cgi-bin/koha/suggestion/suggestion.pl?displayby=foo");
        // Do not 500 and default to "STATUS" if displayby is not valid
        cy.get("#displayby").should("have.value", "STATUS");
    });
});
