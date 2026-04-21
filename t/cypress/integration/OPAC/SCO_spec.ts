describe("SCO", () => {
    beforeEach(() => {
        cy.task("insertSampleBiblio", { item_count: 1 }).then(objects => {
            cy.wrap(objects).as("objects");
            cy.task("query", {
                sql: "UPDATE items SET barcode='+42+' WHERE itemnumber=?",
                values: [objects.items[0].item_id],
            });
        });
    });

    afterEach(function () {
        cy.task("query", {
            sql: "DELETE FROM issues WHERE itemnumber=?",
            values: [this.objects.items[0].item_id],
        });

        cy.task("deleteSampleObjects", this.objects);
    });

    it("Should not crash if barcode contains '+'", function () {
        cy.visitOpac("/cgi-bin/koha/sco/sco-main.pl?op=logout");
        cy.get("#patronlogin").type("kkoha"); // FIXME Why is the first character not displayed??
        cy.get("#patronpw").type("koha");
        cy.get("#mainform button").click();
        cy.get("#barcode").type("+42+");
        cy.get("#scan_form button[type='submit']").click();
        cy.get("div.alert-info")
            .contains("Item checked out (+42+)")
            .should("be.visible");
        cy.task("query", {
            sql: "DELETE FROM issues WHERE itemnumber=?",
            values: [this.objects.items[0].item_id],
        });
    });
});
