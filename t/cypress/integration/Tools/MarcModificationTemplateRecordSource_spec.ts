describe("MARC modification template record source", () => {
    const templateName = "Cypress record source template";
    const plainTemplateName = "Cypress plain template";
    const sourceName = "Cypress vendor";

    beforeEach(() => {
        cy.task("query", {
            sql: `INSERT INTO record_sources (name, can_be_edited, is_system) VALUES ('${sourceName}', 1, 0)`,
        });
        cy.task("query", {
            sql: `INSERT INTO marc_modification_templates (name) VALUES ('${templateName}'), ('${plainTemplateName}')`,
        });
        cy.login();
    });

    afterEach(() => {
        cy.task("query", {
            sql: "UPDATE borrowers SET flags=1 WHERE borrowernumber=51",
        });
        cy.task("query", {
            sql: `DELETE FROM marc_modification_templates WHERE name IN ('${templateName}', '${plainTemplateName}')`,
        });
        cy.task("query", {
            sql: `DELETE FROM record_sources WHERE name='${sourceName}'`,
        });
    });

    const openTemplate = () => {
        cy.visit("/cgi-bin/koha/tools/marc_modification_templates.pl");
        cy.contains("tr", templateName)
            .find("a[href*='op=select_template']")
            .click({ force: true });
    };

    it("Sets the record source with the set_record_sources permission", () => {
        openTemplate();
        cy.get("#set_record_source select#record_source_id").select(sourceName);
        cy.get("#set_record_source input[type='submit']").click();
        cy.get(
            "#set_record_source select#record_source_id option:selected"
        ).should("have.text", sourceName);
        cy.get("#template_record_source").should("not.exist");
    });

    it("Shows the record source read-only without the permission", () => {
        openTemplate();
        cy.get("#set_record_source select#record_source_id").select(sourceName);
        cy.get("#set_record_source input[type='submit']").click();

        cy.task("query", {
            sql: "UPDATE borrowers SET flags=8196 WHERE borrowernumber=51",
        });
        openTemplate();
        cy.get("#set_record_source").should("not.exist");
        cy.get("#template_record_source").contains(sourceName);
    });

    it("Hides source templates in batch modification without the permission", () => {
        cy.task("query", {
            sql: `UPDATE marc_modification_templates SET record_source_id=(SELECT record_source_id FROM record_sources WHERE name='${sourceName}') WHERE name='${templateName}'`,
        });

        cy.visit("/cgi-bin/koha/tools/batch_record_modification.pl");
        cy.get("#marc_modification_template_id").contains(templateName);
        cy.get("#marc_modification_template_id").contains(plainTemplateName);

        cy.task("query", {
            sql: "UPDATE borrowers SET flags=8196 WHERE borrowernumber=51",
        });
        cy.visit("/cgi-bin/koha/tools/batch_record_modification.pl");
        cy.get("#marc_modification_template_id").contains(plainTemplateName);
        cy.get("#marc_modification_template_id").should(
            "not.contain.text",
            templateName
        );
    });
});
