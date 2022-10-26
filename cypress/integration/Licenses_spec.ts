import { mount } from "@cypress/vue";
const dayjs = require("dayjs"); /* Cannot use our calendar JS code, it's in an include file (!)
                                   Also note that moment.js is deprecated */

const dates = {
    today_iso: dayjs().format("YYYY-MM-DD"),
    today_us: dayjs().format("MM/DD/YYYY"),
    tomorrow_iso: dayjs().add(1, "day").format("YYYY-MM-DD"),
    tomorrow_us: dayjs().add(1, "day").format("MM/DD/YYYY"),
};
function get_license() {
    return {
        license_id: 1,
        name: "license 1",
        description: "my first license",
        type: "local",
        status: "active",
        started_on: dates["today_iso"],
        ended_on: dates["tomorrow_iso"],
    };
}

describe("License CRUD operations", () => {
    beforeEach(() => {
        cy.login("koha", "koha");
        cy.title().should("eq", "Koha staff interface");
    });

    it("List license", () => {
        // GET license returns 500
        cy.intercept("GET", "/api/v1/erm/licenses", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.visit("/cgi-bin/koha/erm/erm.pl");
        cy.get("#navmenulist").contains("Licenses").click();
        cy.get("main div[class='dialog alert']").contains(
            /Something went wrong/
        );

        // GET licenses returns empty list
        cy.intercept("GET", "/api/v1/erm/licenses*", []);
        cy.visit("/cgi-bin/koha/erm/licenses");
        cy.get("#licenses_list").contains("There are no licenses defined.");

        // GET licenses returns something
        let license = get_license();
        let licenses = [license];

        cy.intercept("GET", "/api/v1/erm/licenses*", {
            statusCode: 200,
            body: licenses,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/erm/licenses/*", license);
        cy.visit("/cgi-bin/koha/erm/licenses");
        cy.get("#licenses_list").contains("Showing 1 to 1 of 1 entries");
    });

    it("Add license", () => {
        // Click the button in the toolbar
        cy.visit("/cgi-bin/koha/erm/licenses");
        cy.contains("New license").click();
        cy.get("#licenses_add h2").contains("New license");

        // Fill in the form for normal attributes
        let license = get_license();

        cy.get("#licenses_add").contains("Submit").click();
        cy.get("input:invalid,textarea:invalid,select:invalid").should(
            "have.length",
            4
        );
        cy.get("#license_name").type(license.name);
        cy.get("#license_description").type(license.description);
        cy.get("#licenses_add").contains("Submit").click();
        cy.get("#license_type .vs__search").type(license.type + '{enter}',{force:true});
        cy.get("#license_status .vs__search").type(license.status + '{enter}',{force:true});

        cy.get("#started_on+input").click();
        cy.get(".flatpickr-calendar")
            .eq(0)
            .find("span.today")
            .click({ force: true });

        cy.get("#ended_on+input").click();
        cy.get(".flatpickr-calendar")
            .eq(1)
            .find("span.today")
            .next("span")
            .click();

        // Submit the form, get 500
        cy.intercept("POST", "/api/v1/erm/licenses", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.get("#licenses_add").contains("Submit").click();
        cy.get("main div[class='dialog alert']").contains(
            "Something went wrong: Internal Server Error"
        );

        // Submit the form, success!
        cy.intercept("POST", "/api/v1/erm/licenses", {
            statusCode: 201,
            body: license,
        });
        cy.get("#licenses_add").contains("Submit").click();
        cy.get("main div[class='dialog message']").contains(
            "License created"
        );
    });

    it("Edit license", () => {
        let license = get_license();
        let licenses = [license];
        // Click the 'Edit' button from the list
        cy.intercept("GET", "/api/v1/erm/licenses*", {
            statusCode: 200,
            body: licenses,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/erm/licenses/*", license).as(
            "get-license"
        );
        cy.visit("/cgi-bin/koha/erm/licenses");
        cy.get("#licenses_list table tbody tr:first")
            .contains("Edit")
            .click();
        cy.wait("@get-license");
        cy.wait(500); // Cypress is too fast! Vue hasn't populated the form yet!
        cy.get("#licenses_add h2").contains("Edit license");

        // Form has been correctly filled in
        cy.get("#license_name").should("have.value", license.name);
        cy.get("#license_description").should(
            "have.value",
            license.description
        );
        cy.get("#license_type .vs__selected").contains("Local");
        cy.get("#license_status .vs__selected").contains("Active");
        cy.get("#started_on").invoke("val").should("eq", dates["today_iso"]);
        cy.get("#ended_on").invoke("val").should("eq", dates["tomorrow_iso"]);

        // Submit the form, get 500
        cy.intercept("PUT", "/api/v1/erm/licenses/*", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.get("#licenses_add").contains("Submit").click();
        cy.get("main div[class='dialog alert']").contains(
            "Something went wrong: Internal Server Error"
        );

        // Submit the form, success!
        cy.intercept("PUT", "/api/v1/erm/licenses/*", {
            statusCode: 200,
            body: license,
        });
        cy.get("#licenses_add").contains("Submit").click();
        cy.get("main div[class='dialog message']").contains(
            "License updated"
        );
    });

    it("Show license", () => {
        let license = get_license();
        let licenses = [license];
        // Click the "name" link from the list
        cy.intercept("GET", "/api/v1/erm/licenses*", {
            statusCode: 200,
            body: licenses,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/erm/licenses/*", license).as(
            "get-license"
        );
        cy.visit("/cgi-bin/koha/erm/licenses");
        let name_link = cy.get(
            "#licenses_list table tbody tr:first td:first a"
        );
        name_link.should(
            "have.text",
            license.name + " (#" + license.license_id + ")"
        );
        name_link.click();
        cy.wait("@get-license");
        cy.wait(500); // Cypress is too fast! Vue hasn't populated the form yet!
        cy.get("#licenses_show h2").contains(
            "License #" + license.license_id
        );
    });

    it("Delete license", () => {
        let license = get_license();
        let licenses = [license];

        // Click the 'Delete' button from the list
        cy.intercept("GET", "/api/v1/erm/licenses*", {
            statusCode: 200,
            body: licenses,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/erm/licenses/*", license);
        cy.visit("/cgi-bin/koha/erm/licenses");

        cy.get("#licenses_list table tbody tr:first")
            .contains("Delete")
            .click();
        cy.get("#licenses_confirm_delete h2").contains("Delete license");
        cy.contains("License name: " + license.name);

        // Submit the form, get 500
        cy.intercept("DELETE", "/api/v1/erm/licenses/*", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.contains("Yes, delete").click();
        cy.get("main div[class='dialog alert']").contains(
            "Something went wrong: Internal Server Error"
        );

        // Submit the form, success!
        cy.intercept("DELETE", "/api/v1/erm/licenses/*", {
            statusCode: 204,
            body: null,
        });
        cy.contains("Yes, delete").click();
        cy.get("main div[class='dialog message']").contains(
            "License deleted"
        );
    });
});
