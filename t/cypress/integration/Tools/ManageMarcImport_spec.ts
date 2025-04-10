// File: t/cypress/integration/tools/ManageMarcImport_spec.ts

describe("Breadcrumb tests", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    it("Breadcrumbs", () => {
        cy.visit("/cgi-bin/koha/cataloguing/cataloging-home.pl");
        cy.contains("Manage staged records").click();
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
        cy.contains("Manage staged MARC records").click();
    });

    it("upload a MARC record", () => {
        cy.visit("/cgi-bin/koha/tools/stage-marc-import.pl");

        cy.get('input[type="file"]').selectFile(
            "t/cypress/fixtures/sample.mrc"
        );
        cy.get('form[id="uploadfile"]').within(() => {
            cy.get('button[id="fileuploadbutton"]').click();
        });

        //wait after file upload, it can go to quickly here
        cy.wait(2000);

        //check default values
        cy.get('select[name="matcher"] option:selected').should(
            "have.value",
            ""
        );
        cy.get('select[name="overlay_action"] option:selected').should(
            "have.value",
            "replace"
        );
        cy.get('select[name="nomatch_action"] option:selected').should(
            "have.value",
            "create_new"
        );
        cy.get('select[name="item_action"] option:selected').should(
            "have.value",
            "always_add"
        );

        cy.get('select[name="format"]').select("MARCXML", { force: true });
        cy.get("#format").should("have.value", "MARCXML");

        //select some new options
        cy.get("#matcher").select("3", { force: true });
        cy.get("#overlay_action").select("create_new", { force: true });
        cy.get("#nomatch_action").select("ignore", { force: true });
        cy.get("#item_action").select("ignore", { force: true });

        //remove focus
        //cy.get('#item_action').blur();
        cy.screenshot("after_selection");

        // Now verify all values
        cy.get("#matcher").should("have.value", "3");
        cy.get("#overlay_action").should("have.value", "create_new");
        cy.get("#nomatch_action").should("have.value", "ignore");
        cy.get("#item_action").should("have.value", "ignore");

        cy.screenshot("right_before_submission");
        cy.get("#mainformsubmit").click();

        cy.get("#job_callback").should("exist");

        //wait for View batch link to load with the batch ID
        cy.wait(5000);

        cy.screenshot("after_waiting");
        cy.contains("View batch").click();

        cy.wait(2000);
        // Now verify all values are retained
        cy.get("#new_matcher_id").should("have.value", "3");
        cy.get("#overlay_action").should("have.value", "create_new");
        cy.get("#nomatch_action").should("have.value", "ignore");
        cy.get("#item_action").should("have.value", "ignore");
    });
});
