describe("Sticky toolbar - basic behavior", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    it("Should stick on scroll", () => {
        cy.visit("/cgi-bin/koha/acqui/acqui-home.pl");

        cy.get("#toolbar").contains("New vendor").click();
        cy.scrollTo("bottom");
        cy.get("#toolbar").should("be.visible");
        cy.get("#toolbar").should("have.class", "floating");

        cy.scrollTo("top");
        cy.get("#toolbar").should("not.have.class", "floating");
    });
});

describe("Sticky toolbar - vendors", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");

        cy.task("buildSampleObject", {
            object: "vendor",
            values: { active: 1 },
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
                return cy.task("buildSampleObject", {
                    object: "basket",
                    values: { vendor_id: vendor.id },
                });
            })
            .then(generatedBasket => {
                return cy.task("insertObject", {
                    type: "basket",
                    object: generatedBasket,
                });
            })
            .then(basket => {
                cy.wrap(basket).as("basket");
            });
    });
    afterEach(function () {
        cy.task("deleteSampleObjects", [
            { vendor: this.vendor, basket: this.basket },
        ]);
    });
    it("Should open non-Vue links correctly in the same tab", function () {
        cy.visit(`/cgi-bin/koha/acquisition/vendors/${this.vendor.id}`);

        cy.get("#toolbar a").contains("Receive shipments").click();
        cy.get("h1").contains(
            `Receive shipment from vendor ${this.vendor.name}`
        );
    });
});
