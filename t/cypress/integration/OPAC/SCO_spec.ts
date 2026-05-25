describe("SCO", () => {
    beforeEach(() => {
        cy.task("insertSampleBiblio", { item_count: 1 }).then(objects => {
            cy.wrap(objects).as("objects");
            cy.task("query", {
                sql: "UPDATE items SET barcode=CONCAT('+', itemnumber, '+') WHERE itemnumber=?",
                values: [objects.items[0].item_id],
            });
        });
        cy.task("query", {
            sql: "SELECT value FROM systempreferences WHERE variable='WebBasedSelfCheck'",
        }).then(value => {
            cy.wrap(value).as("syspref_WebBasedSelfCheck");
        });
    });

    afterEach(function () {
        cy.task("deleteSampleObjects", this.objects);
        cy.login();
        cy.set_syspref("WebBasedSelfCheck", this.syspref_WebBasedSelfCheck);
    });

    it("Should not crash if barcode contains '+'", function () {
        const barcode = `+${this.objects.items[0].item_id}+`;
        cy.visitOpac("/cgi-bin/koha/sco/sco-main.pl?op=logout");
        cy.get("#patronlogin").should("be.visible").type("kkoha"); // FIXME Why is the first character not displayed??
        cy.get("#patronpw").type("koha");
        cy.get("#mainform button").click();
        cy.get("#barcode").should("be.visible").type(barcode);
        cy.get("#scan_form button[type='submit']").click();
        cy.get("div.alert-info")
            .contains(`Item checked out (${barcode})`)
            .should("be.visible");
        cy.task("query", {
            sql: "DELETE FROM issues WHERE itemnumber=?",
            values: [this.objects.items[0].item_id],
        });
    });
});
