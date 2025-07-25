describe("Vue breadcrumbs", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");

        cy.task("buildSampleObject", {
            object: "vendor",
            values: { active: 1, name: "This should be in the breadcrumb" },
        })
            .then(generatedVendor => {
                delete generatedVendor.list_currency;
                delete generatedVendor.invoice_currency;
                return cy.task("insertObject", {
                    type: "vendor",
                    object: generatedVendor,
                });
            })
            .then(vendor => {
                cy.wrap(vendor).as("vendor");
            });
    });
    afterEach(function () {
        cy.task("deleteSampleObjects", [
            { vendor: this.vendor, basket: this.basket },
        ]);
    });
    it("Should format a breadcrumb if the method is passed", function () {
        cy.visit(`/cgi-bin/koha/acqui/acqui-home.pl`);
        cy.get("#supplierpage").type(this.vendor.name);
        cy.get("#supplierpage").type("{enter}");

        cy.get("#breadcrumbs").contains(
            "Search for vendor: " + this.vendor.name
        );
    });
    it("Should pass a specified value into the breadcrumb", function () {
        cy.visit(`/cgi-bin/koha/acquisition/vendors/${this.vendor.id}`);

        cy.get("#breadcrumbs").contains(this.vendor.name);
    });
    it("Should append an additional breadcrumb when editing", function () {
        cy.visit(`/cgi-bin/koha/acquisition/vendors/${this.vendor.id}`);
        cy.get("#toolbar").contains("Edit").click();
        cy.get("#breadcrumbs").contains(this.vendor.name);
        cy.get("#breadcrumbs").contains("Modify vendor");
    });
});
