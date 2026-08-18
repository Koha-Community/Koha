describe("Order receive preferences", () => {
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
                    object: "invoice",
                    values: { vendor_id: vendor.id },
                });
            })
            .then(generatedInvoice => {
                return cy.task("insertObject", {
                    type: "invoice",
                    object: generatedInvoice,
                });
            })
            .then(invoice => {
                cy.wrap(invoice).as("invoice");
            });

        cy.task("query", {
            sql: "SELECT value FROM systempreferences WHERE variable='AcqCreateItem'",
        }).then(value => {
            cy.wrap(value).as("syspref_AcqCreateItem");
        });
        cy.task("query", {
            sql: "SELECT value FROM systempreferences WHERE variable='UniqueItemFields'",
        }).then(value => {
            cy.wrap(value).as("syspref_UniqueItemFields");
        });
    });

    afterEach(function () {
        cy.task("deleteSampleObjects", [
            { vendor: this.vendor, invoice: this.invoice },
        ]);
        cy.set_syspref("AcqCreateItem", this.syspref_AcqCreateItem);
        cy.set_syspref("UniqueItemFields", this.syspref_UniqueItemFields);
    });

    it("preserves string-valued system preferences", function () {
        cy.set_syspref("AcqCreateItem", "ordering");
        cy.set_syspref("UniqueItemFields", "barcode|itemcallnumber");
        cy.visit(
            `/cgi-bin/koha/acqui/orderreceive.pl?invoiceid=${this.invoice.invoice_id}&multiple_orders=999999998,999999999`
        );

        cy.window().then(win => {
            const prefs = (win as any).Koha.prefs;
            expect(prefs.AcqCreateItem).to.equal("ordering");
            expect(prefs.UniqueItemFields).to.equal("barcode|itemcallnumber");
        });
    });
});
