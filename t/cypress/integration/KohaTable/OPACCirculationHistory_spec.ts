describe("opac-readingrecord", () => {
    beforeEach(() => {
        cy.loginOpac();
        let objects_to_cleanup = [];
        cy.task("apiGet", {
            endpoint: "/api/v1/patrons/51",
        })
            .then(patron => {
                [...Array(51)].forEach(() => {
                    cy.task("insertSampleCheckout", {
                        patron: patron,
                    }).then(objects_checkout => {
                        cy.task("query", {
                            sql: "INSERT INTO old_issues SELECT * FROM issues WHERE issue_id=?",
                            values: [objects_checkout.checkout.checkout_id],
                        })
                            .then(() => {
                                cy.task("query", {
                                    sql: "DELETE FROM issues WHERE issue_id=?",
                                    values: [
                                        objects_checkout.checkout.checkout_id,
                                    ],
                                });
                            })
                            .then(() => {
                                objects_checkout.old_checkout =
                                    objects_checkout.checkout;
                                delete objects_checkout.checkout;
                                objects_to_cleanup.push(objects_checkout);
                            });
                    });
                });
            })
            .then(() => {
                cy.wrap(objects_to_cleanup).as("objects_to_cleanup");
            });
    });

    afterEach(function () {
        cy.task("deleteSampleObjects", this.objects_to_cleanup);
    });

    it("50 items should be displayed by default", function () {
        cy.visitOpac("/cgi-bin/koha/opac-readingrecord.pl");

        cy.contains("Showing 1 to 50 of 50 entries");
        cy.get("table#readingrec tbody tr").should("have.length", 50);

        cy.contains("Show all items").click();
        cy.contains("Showing 1 to 51 of 51 entries");
        cy.get("table#readingrec tbody tr").should("have.length", 51);
    });
});
