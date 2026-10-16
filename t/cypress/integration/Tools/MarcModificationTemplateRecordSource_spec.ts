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

    it("Hides source templates when staging MARC records without the permission", () => {
        cy.task("query", {
            sql: `UPDATE marc_modification_templates SET record_source_id=(SELECT record_source_id FROM record_sources WHERE name='${sourceName}') WHERE name='${templateName}'`,
        });

        cy.visit("/cgi-bin/koha/tools/stage-marc-import.pl");
        cy.get("#marc_modification_template_id").contains(templateName);
        cy.get("#marc_modification_template_id").contains(plainTemplateName);

        cy.task("query", {
            sql: "UPDATE borrowers SET flags=8196 WHERE borrowernumber=51",
        });
        cy.visit("/cgi-bin/koha/tools/stage-marc-import.pl");
        cy.get("#marc_modification_template_id").contains(plainTemplateName);
        cy.get("#marc_modification_template_id").should(
            "not.contain.text",
            templateName
        );
    });

    it("Refuses to stage with a source template without the permission", () => {
        cy.task("query", {
            sql: `UPDATE marc_modification_templates SET record_source_id=(SELECT record_source_id FROM record_sources WHERE name='${sourceName}') WHERE name='${templateName}'`,
        });
        cy.task("query", {
            sql: "UPDATE borrowers SET flags=8196 WHERE borrowernumber=51",
        });

        cy.task("query", {
            sql: `SELECT template_id FROM marc_modification_templates WHERE name='${templateName}'`,
        }).then(rows => {
            const templateId = rows[0].template_id;
            cy.visit("/cgi-bin/koha/tools/stage-marc-import.pl");
            cy.get("input[name='csrf_token']")
                .first()
                .invoke("val")
                .then(csrfToken => {
                    cy.request({
                        method: "POST",
                        url: "/cgi-bin/koha/tools/stage-marc-import.pl",
                        form: true,
                        body: {
                            csrf_token: csrfToken,
                            op: "cud-stage",
                            uploadedfileid: "1",
                            record_type: "biblio",
                            marc_modification_template_id: templateId,
                        },
                    }).then(response => {
                        expect(response.status).to.eq(200);
                        expect(response.body).to.contain(
                            "you do not have permission to set record sources"
                        );
                        expect(response.body).not.to.contain(
                            "The job has been enqueued"
                        );
                    });
                });
        });
    });

    describe("svc/import_bib", () => {
        const marcxml =
            '<record xmlns="http://www.loc.gov/MARC21/slim"><leader>00000nam a2200000 a 4500</leader><datafield tag="245" ind1="0" ind2="0"><subfield code="a">Cypress import_bib record source</subfield></datafield></record>';

        const postImportBib = () =>
            cy
                .task("query", {
                    sql: `SELECT template_id FROM marc_modification_templates WHERE name='${templateName}'`,
                })
                .then(rows => {
                    cy.visit("/cgi-bin/koha/mainpage.pl");
                    return cy
                        .get("meta[name='csrf-token']")
                        .invoke("attr", "content")
                        .then(csrfToken =>
                            cy.request({
                                method: "POST",
                                url: "/cgi-bin/koha/svc/import_bib",
                                form: true,
                                body: {
                                    csrf_token: csrfToken,
                                    xml: marcxml,
                                    marc_modification_template_id:
                                        rows[0].template_id,
                                },
                            })
                        );
                });

        beforeEach(() => {
            cy.task("query", {
                sql: `UPDATE marc_modification_templates SET record_source_id=(SELECT record_source_id FROM record_sources WHERE name='${sourceName}') WHERE name='${templateName}'`,
            });
        });

        afterEach(() => {
            cy.task("query", {
                sql: "DELETE FROM user_permissions WHERE borrowernumber=51 AND module_bit=9 AND code='edit_catalogue'",
            });
            cy.task("query", {
                sql: `DELETE FROM import_batches WHERE batch_type='webservice' AND record_source_id=(SELECT record_source_id FROM record_sources WHERE name='${sourceName}')`,
            });
        });

        it("Accepts a source template with the set_record_sources permission", () => {
            postImportBib().then(response => {
                expect(response.status).to.eq(200);
                expect(response.body).to.contain("<status>ok</status>");
            });
        });

        it("Refuses a source template without the set_record_sources permission", () => {
            cy.task("query", {
                sql: "UPDATE borrowers SET flags=4 WHERE borrowernumber=51",
            });
            cy.task("query", {
                sql: "INSERT INTO user_permissions (borrowernumber, module_bit, code) VALUES (51, 9, 'edit_catalogue')",
            });

            postImportBib().then(response => {
                expect(response.status).to.eq(200);
                expect(response.body).to.contain("<status>failed</status>");
                expect(response.body).to.contain(
                    "<error>set_record_source_not_allowed</error>"
                );
            });
        });
    });
});
