describe("members/readingrec", () => {
    const table_id = "table_readingrec";
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.task("insertSampleCheckout").then(objects_checkout => {
            cy.wrap(objects_checkout).as("objects_checkout");
        });
    });

    afterEach(function () {
        cy.task("deleteSampleObjects", [this.objects_checkout]);
    });

    it("'Type' column should be hidden", function () {
        cy.visit(
            `/cgi-bin/koha/members/readingrec.pl?borrowernumber=${this.objects_checkout.patron.patron_id}`
        );

        cy.get(`#${table_id} th`).contains("Type").should("not.exist");
        cy.get(`#${table_id} th:first`).contains("Date");
    });
});
