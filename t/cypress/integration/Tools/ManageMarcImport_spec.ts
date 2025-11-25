// File: t/cypress/integration/tools/ManageMarcImport_spec.ts

describe("Breadcrumb tests", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    it("Breadcrumbs", () => {
        cy.visit("/cgi-bin/koha/cataloguing/cataloging-home.pl");
        cy.contains("Manage staged records").should("exist");
        cy.get("#breadcrumbs").contains("Cataloging");
    });
});

describe("loads the manage MARC import page", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    it("loads the manage MARC import page", () => {
        cy.visit("/cgi-bin/koha/tools/manage-marc-import.pl");
        cy.contains("Manage staged MARC records").should("exist");
    });

    it("upload a MARC record", () => {
        cy.visit("/cgi-bin/koha/tools/stage-marc-import.pl");

        cy.fixture("sample.xml", null).as("sample_xml");
        cy.get("input[type=file]").selectFile("@sample_xml");
        cy.get("#fileuploadbutton").click();

        cy.get("#fileuploadstatus").contains("100%");
        cy.get("legend")
            .contains("Look for existing records in catalog?")
            .should("be.visible");

        //check default values
        cy.get("select#matcher option:selected").should("have.value", "");
        cy.get("select#overlay_action option:selected").should(
            "have.value",
            "replace"
        );
        cy.get("select#nomatch_action option:selected").should(
            "have.value",
            "create_new"
        );
        cy.get("select#item_action option:selected").should(
            "have.value",
            "always_add"
        );

        cy.get('select[name="format"]').should("have.value", "MARCXML");

        //select some new options
        cy.get("#matcher").select("3", { force: true });
        cy.get("#matcher")
            .select("3", { force: true })
            .should("have.value", "3");
        cy.get("#overlay_action")
            .select("create_new", { force: true })
            .should("have.value", "create_new");
        cy.get("#nomatch_action")
            .select("ignore", { force: true })
            .should("have.value", "ignore");
        cy.get("#item_action")
            .select("ignore", { force: true })
            .should("have.value", "ignore");

        cy.get("#mainformsubmit").click();

        cy.get("#job_callback").should("exist");

        cy.contains("View batch").click();

        // Now verify all values are retained
        cy.get("#new_matcher_id").should("have.value", "3");
        cy.get("#overlay_action").should("have.value", "create_new");
        cy.get("#nomatch_action").should("have.value", "ignore");
        cy.get("#item_action").should("have.value", "ignore");
    });
});
