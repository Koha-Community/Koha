describe("Locked record actions in the detail page Edit menu", () => {
    const sourceName = "Cypress locked source";

    const restrictToCatalogueStaff = () => {
        cy.task("query", {
            sql: "UPDATE borrowers SET flags=4 WHERE borrowernumber=51",
        });
        cy.task("query", {
            sql: "INSERT INTO user_permissions (borrowernumber, module_bit, code) VALUES (51, 9, 'edit_catalogue'), (51, 13, 'records_batchmod')",
        });
    };

    beforeEach(() => {
        cy.task("query", {
            sql: `INSERT INTO record_sources (name, can_be_edited, is_system) VALUES ('${sourceName}', 0, 0)`,
        });
        cy.login();
    });

    afterEach(() => {
        cy.task("query", {
            sql: "DELETE FROM user_permissions WHERE borrowernumber=51 AND code IN ('edit_catalogue', 'records_batchmod')",
        });
        cy.task("query", {
            sql: "UPDATE borrowers SET flags=1 WHERE borrowernumber=51",
        });
        cy.task("query", {
            sql: `DELETE FROM record_sources WHERE name='${sourceName}'`,
        });
    });

    it("Disables edit actions on a locked record", () => {
        cy.task("insertSampleBiblio", { item_count: 1 }).then(result => {
            const biblio_id = result.biblio.biblio_id;
            cy.task("query", {
                sql: `UPDATE biblio_metadata SET record_source_id=(SELECT record_source_id FROM record_sources WHERE name='${sourceName}') WHERE biblionumber=${biblio_id}`,
            });
            restrictToCatalogueStaff();
            cy.visit(
                `/cgi-bin/koha/catalogue/MARCdetail.pl?biblionumber=${biblio_id}`
            );
            cy.get("#editbiblio").should("have.class", "disabled");
            cy.get("#modifybiblio").should("have.class", "disabled");
            cy.get("#z3950copy").should("not.exist");
            cy.get("#z3950copy-disabled").should("have.class", "disabled");
            cy.get("#deletebiblio").should("have.class", "disabled");
            cy.task("query", {
                sql: "UPDATE borrowers SET flags=1 WHERE borrowernumber=51",
            });
            cy.task("deleteSampleObjects", [result]);
        });
    });

    it("Keeps edit actions enabled on an unlocked record", () => {
        cy.task("insertSampleBiblio", { item_count: 1 }).then(result => {
            const biblio_id = result.biblio.biblio_id;
            restrictToCatalogueStaff();
            cy.visit(
                `/cgi-bin/koha/catalogue/MARCdetail.pl?biblionumber=${biblio_id}`
            );
            cy.get("#editbiblio").should("not.have.class", "disabled");
            cy.get("button#modifybiblio").should("exist");
            cy.get("#z3950copy").should("exist");
            cy.task("query", {
                sql: "UPDATE borrowers SET flags=1 WHERE borrowernumber=51",
            });
            cy.task("deleteSampleObjects", [result]);
        });
    });
});
