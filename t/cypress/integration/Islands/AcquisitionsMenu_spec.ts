describe("Acquisitions menu", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");

        cy.set_syspref("EDIFACT", 0);
        cy.set_syspref("MarcOrderingAutomation", 0);
        cy.visit("/cgi-bin/koha/acqui/acqui-home.pl");
    });

    it("Should render a left menu", () => {
        cy.get(".sidebar_menu").should("be.visible");
        cy.get(".sidebar_menu a").should("have.length", 14);
    });

    it("Should show/hide links based on sysprefs", () => {
        cy.set_syspref("EDIFACT", 1).then(() => {
            cy.reload(true);
            cy.get(".sidebar_menu a").should("have.length", 17);
        });
    });

    it("Should show/hide links based on permissions", () => {
        cy.get(".sidebar_menu").should("be.visible");

        cy.task("query", {
            sql: "UPDATE borrowers SET flags=2052 WHERE borrowernumber=51",
        }).then(() => {
            cy.reload(true);
            cy.get(".sidebar_menu a").should("have.length", 8);
            cy.task("query", {
                sql: "UPDATE borrowers SET flags=1 WHERE borrowernumber=51",
            });
        });
    });
    it("Should correctly apply the 'current' class", () => {
        cy.get(".sidebar_menu").should("be.visible");

        cy.get(".sidebar_menu a")
            .contains("Acquisitions home")
            .should("have.class", "current");
        cy.get(".sidebar_menu a").contains("Budgets").click();
        cy.get(".sidebar_menu a")
            .contains("Budgets")
            .should("have.class", "current");
    });
});
