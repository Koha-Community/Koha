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
        agreement_licenses: [],
        agreement_relationships: [],
    };
}

describe("Agreement CRUD operations", () => {
    beforeEach(() => {
        cy.login("koha", "koha");
        cy.title().should("eq", "Koha staff interface");
    });

    it("List agreements", () => {
        // GET agreements returns 500
        cy.intercept("GET", "/api/v1/erm/agreements", {
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
        cy.get("#agreements_list").contains("There are no agreements defined.");

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
    });

    it("Add agreement", () => {
        // Click the button in the toolbar
        cy.visit("/cgi-bin/koha/erm/agreements");
        cy.contains("New agreement").click();
        cy.get("#agreements_add h2").contains("New agreement");

        // Fill in the form for normal attributes
        let agreement = get_agreement();

        cy.get("#agreements_add").contains("Submit").click();
        cy.get("input:invalid,textarea:invalid,select:invalid").should(
            "have.length",
            3
        );
        cy.get("#agreement_name").type(agreement.name);
        cy.get("#agreement_description").type(agreement.description);
        cy.get("#agreements_add").contains("Submit").click();
        cy.get("input:invalid,textarea:invalid,select:invalid").should(
            "have.length",
            1
        ); // name, description, status
        cy.get("#agreement_status").select(agreement.status);

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
        cy.get("#ended_on_0").click();
        // Second flatpickr => ended_on for the first period
        cy.get(".flatpickr-calendar")
            .eq(1)
            .find("span.today")
            .click({ force: true }); // select today. No idea why we should force, but there is a random failure otherwise

        cy.get("#started_on_0").click();
        cy.get(".flatpickr-calendar")
            .eq(0)
            .find("span.today")
            .next("span")
            .click(); // select tomorrow

        cy.get("#ended_on_0").should("have.value", ""); // Has been reset correctly

        cy.get("#started_on_0").click();
        cy.get(".flatpickr-calendar").eq(0).find("span.today").click(); // select today
        cy.get("#ended_on_0").click({ force: true }); // No idea why we should force, but there is a random failure otherwise
        cy.get(".flatpickr-calendar")
            .eq(1)
            .find("span.today")
            .next("span")
            .click(); // select tomorrow

        // Second period
        cy.get("#started_on_1").click({ force: true });
        cy.get(".flatpickr-calendar").eq(3).find("span.today").click(); // select today
        cy.get("#cancellation_deadline_1").click();
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

        // Submit the form, get 500
        cy.intercept("POST", "/api/v1/erm/agreements", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.get("#agreements_add").contains("Submit").click();
        cy.get("main div[class='dialog alert']").contains(
            "Something went wrong: Internal Server Error"
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
    });

    it("Edit agreement", () => {
        let agreement = get_agreement();
        let agreements = [agreement];
        // Click the 'Edit' button from the list
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
        cy.get("#agreement_status").should("have.value", agreement.status);
        cy.get("#agreement_is_perpetual_no").should("be.checked");
        cy.get("#started_on_0").invoke("val").should("eq", dates["today_us"]);
        cy.get("#ended_on_0").invoke("val").should("eq", dates["tomorrow_us"]);
        cy.get("#cancellation_deadline_0").invoke("val").should("eq", "");
        cy.get("#notes_0").should("have.value", "");
        cy.get("#started_on_1").invoke("val").should("eq", dates["today_us"]);
        cy.get("#ended_on_1").invoke("val").should("eq", "");
        cy.get("#cancellation_deadline_1")
            .invoke("val")
            .should("eq", dates["tomorrow_us"]);
        cy.get("#notes_1").should("have.value", "this is a note");

        // Submit the form, get 500
        cy.intercept("PUT", "/api/v1/erm/agreements/*", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.get("#agreements_add").contains("Submit").click();
        cy.get("main div[class='dialog alert']").contains(
            "Something went wrong: Internal Server Error"
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
        cy.get("#agreements_confirm_delete h2").contains("Delete agreement");
        cy.contains("Agreement name: " + agreement.name);

        // Submit the form, get 500
        cy.intercept("DELETE", "/api/v1/erm/agreements/*", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.contains("Yes, delete").click();
        cy.get("main div[class='dialog alert']").contains(
            "Something went wrong: Internal Server Error"
        );

        // Submit the form, success!
        cy.intercept("DELETE", "/api/v1/erm/agreements/*", {
            statusCode: 204,
            body: null,
        });
        cy.contains("Yes, delete").click();
        cy.get("main div[class='dialog message']").contains(
            "Agreement deleted"
        );
    });
});
