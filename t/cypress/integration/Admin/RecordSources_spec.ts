import { mount } from "@cypress/vue";
const dayjs = require("dayjs"); /* Cannot use our calendar JS code, it's in an include file (!)
                                   Also note that moment.js is deprecated */

describe("Breadcrumbs tests", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    it("Breadcrumbs", () => {
        cy.visit("/cgi-bin/koha/admin/admin-home.pl");
        cy.contains("Record sources").click();
        cy.get("#breadcrumbs").contains("Administration");
        cy.get(".item-last").contains("Record sources");
        // use the 'New' button
        cy.contains("New record source").click();
        cy.get(".current").contains("Add record source");
        cy.get("#breadcrumbs")
            .contains("Record sources")
            .should("have.attr", "href")
            .and("equal", "/cgi-bin/koha/admin/record_sources");
    });
});

describe("Record sources CRUD tests", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    it("Add", () => {
        cy.visit("/cgi-bin/koha/admin/admin-home.pl");
        cy.contains("Record sources").click();
        cy.contains("New record source").click();
        cy.get("#name").type("Poop");

        // Submit the form, get 201
        cy.intercept("POST", "/api/v1/record_sources", {
            statusCode: 201,
            body: {},
        });
        cy.get("#record_source_edit").contains("Submit").click();

        cy.get("main div[class='dialog message']").contains(
            "Record source created!"
        );
    });

    it("List", () => {
        cy.intercept("GET", "/api/v1/record_sources*", {
            statusCode: 200,
            body: [],
            headers: {
                "X-Base-Total-Count": "0",
                "X-Total-Count": "0",
            },
        });
        cy.visit("/cgi-bin/koha/admin/record_sources");
        cy.get("#record_sources_list").contains(
            "There are no record sources defined"
        );

        cy.intercept("GET", "/api/v1/record_sources*", {
            statusCode: 200,
            body: [
                { record_source_id: 1, name: "Source 1", can_be_edited: true },
                { record_source_id: 2, name: "Source 2", can_be_edited: false },
                { record_source_id: 3, name: "Source 3", can_be_edited: true },
            ],
            headers: {
                "X-Base-Total-Count": "3",
                "X-Total-Count": "3",
            },
        });
        cy.visit("/cgi-bin/koha/admin/record_sources");
        cy.get("#record_sources_list").contains("Showing 1 to 3 of 3 entries");

        // Test true => "Yes"
        let row_1 = cy.get(".dataTable > tbody > tr:first-child");
        row_1.get("td:nth-child(3n+3)").contains("Yes");
        // Test false => "No"
        let row_2 = cy.get(".dataTable > tbody > tr:nth-child(2n+2)");
        row_2.get("td:nth-child(3n+3)").contains("No");

        // Action buttons displayed
        row_1.get("td:last-child").contains("Edit");
        row_1.get("td:last-child").contains("Delete");
    });

    it("Edit", () => {
        cy.intercept("GET", "/api/v1/record_sources*", {
            statusCode: 200,
            body: [
                { record_source_id: 1, name: "Source 1", can_be_edited: true },
                { record_source_id: 2, name: "Source 2", can_be_edited: false },
                { record_source_id: 3, name: "Source 3", can_be_edited: true },
            ],
            headers: {
                "X-Base-Total-Count": "3",
                "X-Total-Count": "3",
            },
        });
        cy.visit("/cgi-bin/koha/admin/record_sources");
        cy.intercept("GET", "/api/v1/record_sources/1", {
            statusCode: 200,
            body: {
                record_source_id: 1,
                name: "Source 1",
                can_be_edited: true,
            },
        });
        cy.get("#record_sources_list table tbody tr:first")
            .contains("Edit")
            .click();
        cy.get("#name").should("have.value", "Source 1");
        cy.get("#can_be_edited").should("be.checked");

        cy.intercept("GET", "/api/v1/record_sources/1", {
            statusCode: 200,
            body: {
                record_source_id: 1,
                name: "Source 1",
                can_be_edited: false,
            },
        });
        cy.visit("/cgi-bin/koha/admin/record_sources/edit/1");
        cy.get("#name").should("have.value", "Source 1");
        cy.get("#can_be_edited").should("not.be.checked");

        // Submit the form, get 500
        cy.intercept("PUT", "/api/v1/record_sources/1", {
            statusCode: 201,
            body: {
                record_source_id: 1,
                name: "Poop",
                can_be_edited: false,
            },
        });
        cy.get("#record_source_edit").contains("Submit").click();
    });

    it("Delete", () => {
        cy.intercept("GET", "/api/v1/record_sources*", {
            statusCode: 200,
            body: [
                { record_source_id: 1, name: "Source 1", can_be_edited: true },
                { record_source_id: 2, name: "Source 2", can_be_edited: false },
                { record_source_id: 3, name: "Source 3", can_be_edited: true },
            ],
            headers: {
                "X-Base-Total-Count": "3",
                "X-Total-Count": "3",
            },
        });
        cy.visit("/cgi-bin/koha/admin/record_sources");
        cy.intercept("DELETE", "/api/v1/record_sources/2", {
            statusCode: 204,
            body: {},
        });
        cy.get("#record_sources_list table tbody tr:nth-child(2n+2)")
            .contains("Delete")
            .click();
        cy.get(".dialog.alert.confirmation h1").contains(
            "Are you sure you want to remove this record source?"
        );
        cy.contains("Source 2");
        cy.contains("No, do not remove").click();

        cy.get("#record_sources_list table tbody tr:nth-child(2n+2)")
            .contains("Delete")
            .click();
        cy.contains("Source 2");
        cy.contains("Yes, remove").click();
        cy.get("main div[class='dialog message']").contains(
            "Record source 'Source 2' removed"
        );
    });
});
