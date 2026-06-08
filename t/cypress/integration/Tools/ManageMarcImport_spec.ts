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
        cy.intercept("GET", "/api/v1/import_batch_profiles").as("profiles");
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

        // Wait for the profiles request to complete before making any
        // selections. The getProfiles() callback calls select.change()
        // which resets all form values to defaults — including format to
        // ISO2709 and matcher to "". Waiting here ensures that reset has
        // already fired before we set anything.
        cy.wait("@profiles");

        //select some new options
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
        cy.get('select[name="format"]').select("MARCXML");

        // CI reproduction — simulates Apache returning 503 on the
        // first job poll (as happens during reset_all while Apache is restarting).
        // Without the job_progress.js .fail() fix: no retry fires, the 2nd request
        // never occurs, and cy.wait() times out — reproducing the exact CI error.
        // With the fix: .fail() retries, the 2nd poll goes through, test passes.
        let pollCount = 0;
        cy.intercept("GET", "/api/v1/jobs/*", req => {
            pollCount++;
            if (pollCount === 1) {
                req.reply({ statusCode: 503, body: {} });
            } else {
                req.continue();
            }
        }).as("jobPoll");

        cy.get("#mainformsubmit").click();

        const waitForJobFinished = () => {
            cy.wait("@jobPoll").then(interception => {
                const status = interception.response?.body?.status;
                expect(status, "Background job failed").not.to.eq("failed");
                if (status !== "finished") {
                    waitForJobFinished();
                }
            });
        };
        waitForJobFinished();

        cy.get("#job_callback").contains("View batch").click();

        // Now verify all values are retained
        cy.get("#new_matcher_id").should("have.value", "3");
        cy.get("#overlay_action").should("have.value", "create_new");
        cy.get("#nomatch_action").should("have.value", "ignore");
        cy.get("#item_action").should("have.value", "ignore");
    });
});
