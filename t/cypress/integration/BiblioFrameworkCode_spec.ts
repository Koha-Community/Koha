describe("Handling biblio frameworks in controller scripts", () => {
    before(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });
    describe("Handle 'Default' frameworkcode in addbiblio.pl", () => {
        it("should handle frameworkcode='Default' without error", () => {
            cy.request({
                method: "GET",
                url: "/cgi-bin/koha/cataloguing/addbiblio.pl",
                qs: {
                    frameworkcode: "Default",
                    z3950: 1,
                    breedingid: "test",
                },
                failOnStatusCode: false,
            }).then(response => {
                expect(response.status).to.eq(200);
            });
        });

        it("should handle undefined frameworkcode when creating new record", () => {
            cy.request({
                method: "GET",
                url: "/cgi-bin/koha/cataloguing/addbiblio.pl",
                qs: {
                    op: "add",
                },
                failOnStatusCode: false,
            }).then(response => {
                expect(response.status).to.eq(200);
            });
        });

        it("should handle empty frameworkcode when editing existing record", () => {
            cy.task("insertSampleBiblio", { item_count: 1 }).then(result => {
                const biblio = result.biblio;
                cy.request({
                    method: "GET",
                    url: "/cgi-bin/koha/cataloguing/addbiblio.pl",
                    qs: {
                        biblionumber: biblio.biblio_id,
                        frameworkcode: "",
                    },
                    failOnStatusCode: false,
                }).then(response => {
                    expect(response.status).to.eq(200);
                });

                cy.task("deleteSampleObjects", [result]);
            });
        });
    });
});
