import { mount } from "@cypress/vue";
const dayjs = require("dayjs"); /* Cannot use our calendar JS code, it's in an include file (!)
                                   Also note that moment.js is deprecated */

const dates = {
    today_iso: dayjs().format("YYYY-MM-DD"),
    today_us: dayjs().format("MM/DD/YYYY"),
    tomorrow_iso: dayjs().add(1, "day").format("YYYY-MM-DD"),
    tomorrow_us: dayjs().add(1, "day").format("MM/DD/YYYY"),
};
function get_agreement() {
    return {
        agreement_id: 1,
        closure_reason: "",
        description: "my first agreement",
        is_perpetual: false,
        license_info: "",
        name: "agreement 1",
        renewal_priority: "",
        status: "active",
        vendor_id: null,
        periods: [
            {
                started_on: dates["today_iso"],
                ended_on: dates["tomorrow_iso"],
                cancellation_deadline: null,
                notes: null,
            },
            {
                started_on: dates["today_iso"],
                ended_on: null,
                cancellation_deadline: dates["tomorrow_iso"],
                notes: "this is a note",
            },
        ],
        user_roles: [],
        agreement_licenses: [
            {
                agreement_id: 1,
                agreement_license_id: 3,
                license: {
                    description: "license description",
                    license_id: 1,
                    name: "license name",
                    status: "expired",
                    type: "alliance"
                },
                license_id:1,
                notes: "license notes",
                physical_location: "cupboard",
                status: "controlling",
                uri: "license uri"
            },
            {
                agreement_id: 1,
                agreement_license_id: 4,
                license: {
                    description: "second license description",
                    license_id: 2,
                    name: "second license name",
                    status: "expired",
                    type: "alliance"
                },
                license_id:2,
                notes: "second license notes",
                physical_location: "cupboard",
                status: "future",
                uri: "license uri"
            }
        ],
        agreement_relationships: [
            {
                agreement_id: 1,
                notes: 'related agreement notes',
                related_agreement: {
                    agreement_id: 2,
                    description: "agreement description",
                    name: "agreement name"
                },
                related_agreement_id: 2,
                relationship: "supersedes"
            }
        ],
        agreement_packages: [],
        documents: [
            {
                agreement_id:1,
                file_description: "file description",
                file_name: "file.json",
                notes: "file notes",
                physical_location: "file physical location",
                uri: "file uri",
                uploaded_on: "2022-10-27T11:57:02+00:00"
            }
        ],
    };
}

function get_licenses_to_relate() {
    return [
        {
            license_id: 1,
            description: "a license",
            name: "first license name"
        },
        {
            license_id: 2,
            description: "a second license",
            name: "second license name"
        },
        {
            license_id: 3,
            description: "a third license",
            name: "third license name"
        },
    ]
}

describe("Agreement CRUD operations", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.intercept("GET", "/cgi-bin/koha/svc/config/systempreferences/?pref=ERMModule", '{"value":"1"}');
        cy.intercept("GET", "/cgi-bin/koha/svc/config/systempreferences/?pref=ERMProviders", '{"value":"local"}');
    });

    it("List agreements", () => {
        // GET agreements returns 500
        cy.intercept("GET", "/api/v1/erm/agreements*", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.visit("/cgi-bin/koha/erm/erm.pl");
        cy.get("#navmenulist").contains("Agreements").click();
        cy.get("main div[class='dialog alert']").contains(
            /Something went wrong/
        );

        // GET agreements returns empty list
        cy.intercept("GET", "/api/v1/erm/agreements*", []);
        cy.visit("/cgi-bin/koha/erm/agreements");
        cy.get("#agreements_list").contains("There are no agreements defined");

        // GET agreements returns something
        let agreement = get_agreement();
        let agreements = [agreement];

        cy.intercept("GET", "/api/v1/erm/agreements*", {
            statusCode: 200,
            body: agreements,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/erm/agreements/*", agreement);
        cy.visit("/cgi-bin/koha/erm/agreements");
        cy.get("#agreements_list").contains("Showing 1 to 1 of 1 entries");
        cy.get(".filters").find("label").should(($labels) => {
              expect($labels).to.have.length(2)
              expect($labels.eq(0)).to.contain('Filter by expired')
              expect($labels.eq(1)).to.contain('Show mine only')
        }); // Filter options appear

        // Test filtering
        cy.intercept("GET", "/api/v1/erm/agreements?max_expiration_date=*", []).as("getActiveAgreements");
        cy.get("#expired_filter").check();
        cy.get("#filter_table").click();
        cy.wait('@getActiveAgreements')
            .its('request.url')
            .should('include', 'max_expiration_date='+dates["today_iso"]); // Defaults to today
        cy.get("#max_expiration_date_filter").should("have.value", dates["today_iso"]); // Input box reflects default
        cy.url().should('include', "/cgi-bin/koha/erm/agreements?by_expired=true&max_expiration_date="+dates["today_iso"]); // Browser url also updated

        // Now test that the url for this particular state works
        cy.visit("/cgi-bin/koha/erm/agreements?by_expired=true&max_expiration_date="+dates["today_iso"]);
        cy.wait('@getActiveAgreements').its('request.url').should('include', 'max_expiration_date='+dates["today_iso"]);

        // Now test with a user entered date
        cy.get("#max_expiration_date_filter+input").click({ force: true });
        cy.get(".flatpickr-calendar")
            .eq(0)
            .find("span.today")
            .next("span")
            .click(); // select tomorrow
        cy.get("#filter_table").click();
        cy.wait('@getActiveAgreements').its('request.url').should('include', 'max_expiration_date='+dates["tomorrow_iso"]);
        cy.get("#max_expiration_date_filter").should("have.value", dates["tomorrow_iso"]);
        // Assert that browser url changed again to reflect the user entered date
        cy.url().should('include', "/cgi-bin/koha/erm/agreements?by_expired=true&max_expiration_date="+dates["tomorrow_iso"]);

        // Now test that the url for the updated state works
        cy.visit("/cgi-bin/koha/erm/agreements?by_expired=true&max_expiration_date="+dates["tomorrow_iso"]);
        cy.wait('@getActiveAgreements').its('request.url').should('include', 'max_expiration_date='+dates["tomorrow_iso"]);

        // Verify that the date input is automatically filled if "by_expired" ticked but date is empty
        cy.get("#max_expiration_date_filter+input").clear();
        cy.get("#expired_filter").check();
        cy.get("#filter_table").click();
        cy.get("#max_expiration_date_filter").should('have.value', dates["today_iso"]);

        // Test filter button with show mine_only ticked
    });

    it("Add agreement", () => {
        // No agreement, no license yet
        cy.intercept("GET", "/api/v1/erm/agreements*", {
            statusCode: 200,
            body: [],
        });
        cy.intercept("GET", "/api/v1/erm/licenses*", {
            statusCode: 200,
            body: [],
        });

        // Click the button in the toolbar
        cy.visit("/cgi-bin/koha/erm/agreements");
        cy.contains("New agreement").click();
        cy.get("#agreements_add h2").contains("New agreement");

        // Fill in the form for normal attributes
        let agreement = get_agreement();

        cy.get("#agreements_add").contains("Submit").click();
        cy.get("input:invalid,textarea:invalid,select:invalid").should(
            "have.length",
            2
        );
        cy.get("#agreement_name").type(agreement.name);
        cy.get("#agreement_description").type(agreement.description);
        cy.get("#agreements_add").contains("Submit").click();
        cy.get("input:invalid,textarea:invalid,select:invalid").should(
            "have.length",
            1
        ); // name, description, status
        cy.get("#agreement_status .vs__search").type(
            agreement.status + "{enter}",
            { force: true }
        );

        cy.contains("Add new period").click();
        cy.get("#agreements_add").contains("Submit").click();
        cy.get("input:invalid,textarea:invalid,select:invalid").should(
            "have.length",
            1
        ); // Start date

        // Add new periods
        cy.contains("Add new period").click();
        cy.contains("Add new period").click();
        cy.get("#agreement_periods > fieldset").should("have.length", 3);

        cy.get("#agreement_period_1").contains("Remove this period").click();

        cy.get("#agreement_periods > fieldset").should("have.length", 2);
        cy.get("#agreement_period_0");
        cy.get("#agreement_period_1");

        // Selecting the flatpickr values is a bit tedious here...
        // We have 3 date inputs per period
        cy.get("#ended_on_0+input").click();
        // Second flatpickr => ended_on for the first period
        cy.get(".flatpickr-calendar")
            .eq(1)
            .find("span.today")
            .click({ force: true }); // select today. No idea why we should force, but there is a random failure otherwise

        cy.get("#started_on_0+input").click();
        cy.get(".flatpickr-calendar")
            .eq(0)
            .find("span.today")
            .next("span")
            .click(); // select tomorrow

        cy.get("#ended_on_0").should("have.value", ""); // Has been reset correctly

        cy.get("#started_on_0+input").click();
        cy.get(".flatpickr-calendar").eq(0).find("span.today").click(); // select today
        cy.get("#ended_on_0+input").click({ force: true }); // No idea why we should force, but there is a random failure otherwise
        cy.get(".flatpickr-calendar")
            .eq(1)
            .find("span.today")
            .next("span")
            .click(); // select tomorrow

        // Second period
        cy.get("#started_on_1+input").click({ force: true });
        cy.get(".flatpickr-calendar").eq(3).find("span.today").click(); // select today
        cy.get("#cancellation_deadline_1+input").click();
        cy.get(".flatpickr-calendar")
            .eq(5)
            .find("span.today")
            .next("span")
            .click(); // select tomorrow
        cy.get("#notes_1").type("this is a note");

        // TODO Add a new user
        // How to test a new window with cypresS?
        //cy.contains("Add new user").click();
        //cy.contains("Select user").click();

        cy.get("#agreement_licenses").contains(
            "There are no licenses created yet"
        );
        cy.get("#agreement_relationships").contains(
            "There are no other agreements created yet"
        );

        // Add new document
        cy.get("#documents").contains("Add new document").click();
        cy.get("#document_0 input[id=file_0]").click();
        cy.get('#document_0 input[id=file_0]').selectFile('t/cypress/fixtures/file.json');
        cy.get("#document_0 .file_information span").contains("file.json");
        cy.get('#document_0 input[id=file_description_0]').type('file description');
        cy.get('#document_0 input[id=physical_location_0]').type('file physical location');
        cy.get('#document_0 input[id=uri_0]').type('file URI');
        cy.get('#document_0 input[id=notes_0]').type('file notes');

        // Submit the form, get 500
        cy.intercept("POST", "/api/v1/erm/agreements", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.get("#agreements_add").contains("Submit").click();
        cy.get("main div[class='dialog alert']").contains(
            "Something went wrong: SyntaxError: Unexpected end of JSON input"
        );

        // Submit the form, success!
        cy.intercept("POST", "/api/v1/erm/agreements", {
            statusCode: 201,
            body: agreement,
        });
        cy.get("#agreements_add").contains("Submit").click();
        cy.get("main div[class='dialog message']").contains(
            "Agreement created"
        );

        cy.intercept("GET", "/api/v1/erm/agreements*", {
            statusCode: 200,
            body: [{ agreement_id: 1, description: "an existing agreement" }],
        });

        // Add new license
        let licenses_to_relate = get_licenses_to_relate();
        let related_license = agreement.agreement_licenses[0];
        cy.intercept("GET", "/api/v1/erm/licenses*", {
            statusCode: 200,
            body: licenses_to_relate,
        });
        cy.visit("/cgi-bin/koha/erm/agreements/add");
        cy.get("#agreement_licenses").contains("Add new license").click();
        cy.get("#agreement_license_0").contains("Agreement license 1");
        cy.get("#agreement_license_0 #license_id_0 .vs__search").type(
            related_license.license.name
        );
        cy.get("#agreement_license_0 #license_id_0 .vs__dropdown-menu li").eq(0).click( { force: true } ); //click first license suggestion
        cy.get("#agreement_license_0 #license_status_0 .vs__search").type(
            related_license.status + "{enter}",
            { force: true }
        );
        cy.get("#agreement_license_0 #license_location_0 .vs__search").type(
            related_license.physical_location + "{enter}",
            { force: true }
        );
        cy.get("#agreement_license_0 #license_notes_0").type(related_license.notes);
        cy.get("#agreement_license_0 #license_uri_0").type(related_license.uri);

        // Add new related agreement
        let related_agreement = agreement.agreement_relationships[0];
        cy.intercept("GET", "/api/v1/erm/agreements*", {
            statusCode: 200,
            body: cy.get_agreements_to_relate(),
        });
        cy.visit("/cgi-bin/koha/erm/agreements/add");
        cy.get("#agreement_relationships").contains("Add new related agreement").click();
        cy.get("#related_agreement_0").contains("Related agreement 1");
        cy.get("#related_agreement_0 #related_agreement_id_0 .vs__search").type(
            related_agreement.related_agreement.name
        );
        cy.get("#related_agreement_0 #related_agreement_id_0 .vs__dropdown-menu li").eq(0).click( { force: true } ); //click first agreement suggestion
        cy.get("#related_agreement_0 #related_agreement_notes_0").type(related_agreement.notes);
        cy.get("#related_agreement_0 #related_agreement_relationship_0 .vs__search").type(
            related_agreement.relationship + "{enter}",
            { force: true }
        );
    });

    it("Edit agreement", () => {
        let licenses_to_relate = get_licenses_to_relate();
        let agreement = get_agreement();
        let agreements = [agreement];

        // Intercept initial /agreements request once
        cy.intercept(
            {
                method: "GET",
                url: "/api/v1/erm/agreements*",
                times: 1
            },
            {
                body: agreements
            }
        );

        // Intercept follow-up 'search' request after entering /agreements
        cy.intercept("GET", "/api/v1/erm/agreements?_page*", {
            statusCode: 200,
            body: agreements,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("get-single-agreement-search-result");
        cy.visit("/cgi-bin/koha/erm/agreements");
        cy.wait("@get-single-agreement-search-result");

        // Intercept request after edit click
        cy.intercept("GET", "/api/v1/erm/agreements/*", agreement).as(
            "get-agreement"
        );
        // Intercept related licenses request after entering agreement edit
        cy.intercept("GET", "/api/v1/erm/licenses*", {
            statusCode: 200,
            body: licenses_to_relate,
        }).as("get-related-licenses");
        // Intercept related agreements request after entering agreement edit
        cy.intercept("GET", "/api/v1/erm/agreements*", {
            statusCode: 200,
            body: cy.get_agreements_to_relate(),
        }).as("get-related-agreements");

        // Click the 'Edit' button from the list
        cy.get("#agreements_list table tbody tr:first")
            .contains("Edit")
            .click();
        cy.wait("@get-agreement");
        cy.wait(500); // Cypress is too fast! Vue hasn't populated the form yet!
        cy.get("#agreements_add h2").contains("Edit agreement");

        // Form has been correctly filled in
        cy.get("#agreement_name").should("have.value", agreements[0].name);
        cy.get("#agreement_description").should(
            "have.value",
            agreements[0].description
        );
        cy.get("#agreement_status .vs__selected").contains("Active");
        cy.get("#agreement_is_perpetual_no").should("be.checked");
        cy.get("#started_on_0").invoke("val").should("eq", dates["today_iso"]);
        cy.get("#ended_on_0").invoke("val").should("eq", dates["tomorrow_iso"]);
        cy.get("#cancellation_deadline_0").invoke("val").should("eq", "");
        cy.get("#notes_0").should("have.value", "");
        cy.get("#started_on_1").invoke("val").should("eq", dates["today_iso"]);
        cy.get("#ended_on_1").invoke("val").should("eq", "");
        cy.get("#cancellation_deadline_1")
            .invoke("val")
            .should("eq", dates["tomorrow_iso"]);
        cy.get("#notes_1").should("have.value", "this is a note");

        //Test related content
        cy.get("#agreement_license_0 #license_id_0 .vs__selected").contains("first license name");
        cy.get("#agreement_license_1 #license_id_1 .vs__selected").contains("second license name");
        cy.get("#document_0 .file_information span").contains("file.json" );
        cy.get("#related_agreement_0 #related_agreement_id_0 .vs__selected").contains("agreement name");

        // Submit the form, get 500
        cy.intercept("PUT", "/api/v1/erm/agreements/*", (req) => {
            req.reply({
                statusCode: 500,
                error: "Something went wrong",
                delay: 1000,
            });
        });
        cy.get("#agreements_add").contains("Submit").click();
        cy.get("main div[class='modal_centered']").contains("Submitting...");
        cy.wait(1000);
        cy.get("main div[class='dialog alert']").contains(
            "Something went wrong: SyntaxError: Unexpected end of JSON input"
        );

        // Submit the form, success!
        cy.intercept("PUT", "/api/v1/erm/agreements/*", {
            statusCode: 200,
            body: agreement,
        });
        cy.get("#agreements_add").contains("Submit").click();
        cy.get("main div[class='dialog message']").contains(
            "Agreement updated"
        );
    });

    it("Show agreement", () => {
        let agreement = get_agreement();
        let agreements = [agreement];
        // Click the "name" link from the list
        cy.intercept("GET", "/api/v1/erm/agreements*", {
            statusCode: 200,
            body: agreements,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/erm/agreements/*", agreement).as(
            "get-agreement"
        );
        cy.visit("/cgi-bin/koha/erm/agreements");
        let name_link = cy.get(
            "#agreements_list table tbody tr:first td:first a"
        );
        name_link.should(
            "have.text",
            agreement.name + " (#" + agreement.agreement_id + ")"
        );
        name_link.click();
        cy.wait("@get-agreement");
        cy.wait(500); // Cypress is too fast! Vue hasn't populated the form yet!
        cy.get("#agreements_show h2").contains(
            "Agreement #" + agreement.agreement_id
        );

        // TODO There are more to test here:
        // Dates correctly formatted
        // Vendors displayed
        // AV's libs displayed
        // Tables for periods and users
    });
    it("Delete agreement", () => {
        let agreement = get_agreement();
        let agreements = [agreement];

        // Delete from list
        // Click the 'Delete' button from the list
        cy.intercept("GET", "/api/v1/erm/agreements*", {
            statusCode: 200,
            body: agreements,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/erm/agreements/*", agreement);
        cy.visit("/cgi-bin/koha/erm/agreements");

        cy.get("#agreements_list table tbody tr:first")
            .contains("Delete")
            .click();
        cy.get(".dialog.alert.confirmation h1").contains("remove this agreement");
        cy.contains(agreement.name);

        // Accept the confirmation dialog, get 500
        cy.intercept("DELETE", "/api/v1/erm/agreements/*", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.contains("Yes, delete").click();
        cy.get("main div[class='dialog alert']").contains(
            "Something went wrong: SyntaxError: Unexpected end of JSON input"
        );

        // Accept the confirmation dialog, success!
        cy.intercept("DELETE", "/api/v1/erm/agreements/*", {
            statusCode: 204,
            body: null,
        });
        cy.get("#agreements_list table tbody tr:first")
            .contains("Delete")
            .click();
        cy.get(".dialog.alert.confirmation h1").contains("remove this agreement");
        cy.contains("Yes, delete").click();
        cy.get("main div[class='dialog message']").contains("Agreement").contains("deleted");

        // Delete from show
        // Click the "name" link from the list
        cy.intercept("GET", "/api/v1/erm/agreements*", {
            statusCode: 200,
            body: agreements,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/erm/agreements/*", agreement).as(
            "get-agreement"
        );
        cy.visit("/cgi-bin/koha/erm/agreements");
        let name_link = cy.get(
            "#agreements_list table tbody tr:first td:first a"
        );
        name_link.should(
            "have.text",
            agreement.name + " (#" + agreement.agreement_id + ")"
        );
        name_link.click();
        cy.wait("@get-agreement");
        cy.wait(500); // Cypress is too fast! Vue hasn't populated the form yet!
        cy.get("#agreements_show h2").contains(
            "Agreement #" + agreement.agreement_id
        );

        cy.get('#agreements_show .action_links .fa-trash').click();
        cy.get(".dialog.alert.confirmation h1").contains("remove this agreement");
        cy.contains("Yes, delete").click();

        //Make sure we return to list after deleting from show
        cy.get("#agreements_list table tbody tr:first")
    });
});
