import { mount } from "@cypress/vue";

function get_requesting_agency() {
    return {
        iso18626_requesting_agency_id: 1,
        patron_id: 1,
        name: "Test Agency",
        type: "ISIL",
        account_id: "TEST-001",
        securityCode: "secret123",
        callback_endpoint: "https://example.com/callback",
        ill_partner: {
            patron_id: 1,
            firstname: "ILL",
            surname: "Partner",
            cardnumber: "ILL001",
        },
    };
}

describe("Requesting agencies CRUD operations", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.set_syspref("ILLModule", 1);
    });

    it("List requesting agencies", () => {
        // GET requesting agencies returns 500
        cy.intercept("GET", "/api/v1/ill/iso18626_requesting_agencies*", {
            statusCode: 500,
        });
        cy.visit("/cgi-bin/koha/ill/ill.pl");
        cy.get(".sidebar_menu").contains("Requesting agencies").click();
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong"
        );

        // GET requesting agencies returns empty list
        cy.intercept("GET", "/api/v1/ill/iso18626_requesting_agencies*", []);
        cy.visit("/cgi-bin/koha/ill/iso18626_requesting_agencies");
        cy.get("#iso18626_requesting_agencys_list").contains(
            "There are no requesting agencies defined"
        );

        // GET requesting agencies returns populated list
        let agency = get_requesting_agency();
        cy.intercept("GET", "/api/v1/ill/iso18626_requesting_agencies*", {
            statusCode: 200,
            body: [agency],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.visit("/cgi-bin/koha/ill/iso18626_requesting_agencies");
        cy.get("#iso18626_requesting_agencys_list").contains(
            "Showing 1 to 1 of 1 entries"
        );
    });

    it("Add requesting agency", () => {
        let agency = get_requesting_agency();

        cy.intercept("GET", "/api/v1/ill/iso18626_requesting_agencies*", {
            statusCode: 200,
            body: [],
        }).as("getAgencies");

        cy.visit("/cgi-bin/koha/ill/iso18626_requesting_agencies");
        cy.wait("@getAgencies");
        cy.contains("New requesting agency").click();
        cy.get("#iso18626_requesting_agencys_add h2").contains(
            "New requesting agency"
        );

        // Clicking save without required fields shows validation errors
        cy.get("#iso18626_requesting_agencys_add").contains("Save").click();
        cy.get("input:invalid,textarea:invalid,select:invalid").should(
            "have.length.above",
            0
        );

        // Fill in required fields
        cy.get("#name").type(agency.name);
        cy.get("#type .vs__search").type(agency.type + "{enter}", {
            force: true,
        });
        cy.get("#account_id").type(agency.account_id);
        cy.get("#securityCode").type(agency.securityCode);

        // Submit without patron shows HTML5 validation on the patron field
        cy.get("#iso18626_requesting_agencys_add").contains("Save").click();
        cy.get(".patron-search-input").then($el => {
            expect($el[0].validationMessage).to.eq(
                "Please select a patron from the results list."
            );
        });

        // Select a patron via autocomplete
        cy.intercept("GET", "/api/v1/patrons*", {
            statusCode: 200,
            body: [
                {
                    ...agency.ill_partner,
                    library: { library_id: "CPL", name: "Central Library" },
                },
            ],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("searchPatrons");
        cy.get(".patron-search-input").type("ILL");
        cy.wait("@searchPatrons");
        cy.get("li.ui-menu-item").first().click();

        // Confirm the selected partner is shown with surname and Remove link
        cy.get("#patron_selection_patron_id").within(() => {
            cy.contains(agency.ill_partner.surname);
            cy.get("a.removePatron").should("exist");
        });

        // Submit, success
        cy.intercept("POST", "/api/v1/ill/iso18626_requesting_agencies", {
            statusCode: 201,
            body: agency,
        });
        cy.get("#iso18626_requesting_agencys_add").contains("Save").click();
        cy.get("main div[class='alert alert-info']").contains(
            "Requesting agency created"
        );
    });

    it("Edit requesting agency", () => {
        let agency = get_requesting_agency();
        let agencies = [agency];

        cy.intercept("GET", "/api/v1/ill/iso18626_requesting_agencies?_page*", {
            statusCode: 200,
            body: agencies,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("getAgencies");

        cy.visit("/cgi-bin/koha/ill/iso18626_requesting_agencies");
        cy.wait("@getAgencies");

        cy.intercept(
            "GET",
            "/api/v1/ill/iso18626_requesting_agencies/*",
            agency
        ).as("getAgency");

        cy.get("#iso18626_requesting_agencys_list table tbody tr:first")
            .contains("Edit")
            .click();
        cy.wait("@getAgency");
        cy.get("#iso18626_requesting_agencys_add h2").contains(
            "Edit requesting agency #" + agency.iso18626_requesting_agency_id
        );

        // Form is pre-filled with existing values
        cy.get("#name").should("have.value", agency.name);
        cy.get("#account_id").should("have.value", agency.account_id);

        // Submit, get 500
        cy.intercept("PUT", "/api/v1/ill/iso18626_requesting_agencies/*", {
            statusCode: 500,
        });
        cy.get("#iso18626_requesting_agencys_add").contains("Save").click();
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong"
        );

        // Submit, success
        cy.intercept("PUT", "/api/v1/ill/iso18626_requesting_agencies/*", {
            statusCode: 200,
            body: agency,
        });
        cy.get("#iso18626_requesting_agencys_add").contains("Save").click();
        cy.get("main div[class='alert alert-info']").contains(
            "Requesting agency updated"
        );
    });

    it("Show requesting agency", () => {
        let agency = get_requesting_agency();

        cy.intercept("GET", "/api/v1/ill/iso18626_requesting_agencies*", {
            statusCode: 200,
            body: [agency],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("getAgencies");
        cy.intercept(
            "GET",
            "/api/v1/ill/iso18626_requesting_agencies/*",
            agency
        ).as("getAgency");

        cy.visit("/cgi-bin/koha/ill/iso18626_requesting_agencies");
        cy.wait("@getAgencies");

        cy.get(
            "#iso18626_requesting_agencys_list table tbody tr:first td:first a"
        ).click();
        cy.wait("@getAgency");
        cy.get("#iso18626_requesting_agencys_show h2").contains(
            "Requesting agency #" + agency.iso18626_requesting_agency_id
        );
    });

    it("Delete requesting agency", () => {
        let agency = get_requesting_agency();

        cy.intercept("GET", "/api/v1/ill/iso18626_requesting_agencies*", {
            statusCode: 200,
            body: [agency],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("getAgencies");
        cy.intercept(
            "GET",
            "/api/v1/ill/iso18626_requesting_agencies/*",
            agency
        );

        cy.visit("/cgi-bin/koha/ill/iso18626_requesting_agencies");

        cy.get("#iso18626_requesting_agencys_list table tbody tr:first")
            .contains("Delete")
            .click();
        cy.get(".alert-warning.confirmation h1").contains(
            "remove this requesting agency"
        );
        cy.contains(agency.name);

        // Accept the confirmation, get 500
        cy.intercept("DELETE", "/api/v1/ill/iso18626_requesting_agencies/*", {
            statusCode: 500,
        });
        cy.contains("Yes, delete").click();
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong"
        );

        // Accept the confirmation, success
        cy.intercept("DELETE", "/api/v1/ill/iso18626_requesting_agencies/*", {
            statusCode: 204,
            body: null,
        });
        cy.get("#iso18626_requesting_agencys_list table tbody tr:first")
            .contains("Delete")
            .click();
        cy.get(".alert-warning.confirmation h1").contains(
            "remove this requesting agency"
        );
        cy.contains("Yes, delete").click();
        cy.get("main div[class='alert alert-info']")
            .contains("Requesting agency")
            .contains("deleted");
    });
});
