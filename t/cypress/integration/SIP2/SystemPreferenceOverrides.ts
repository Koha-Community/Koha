import { mount } from "@cypress/vue";

function get_system_preference_override() {
    return {
        sip_system_preference_override_id: 1,
        value: "567",
        variable: "234",
    };
}

describe("SystemPreferenceOverrides", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    it("List system preference overrides", () => {
        // GET system preference overrides returns 500
        cy.intercept("GET", "/api/v1/sip2/system_preference_overrides*", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.visit("/cgi-bin/koha/sip2/sip2.pl");
        cy.get(".sidebar_menu").contains("System preference overrides").click();
        cy.get("main div[class='alert alert-warning']").contains(
            /Something went wrong/
        );

        // GET system_preference_overrides returns empty list
        cy.intercept("GET", "/api/v1/sip2/system_preference_overrides*", []);
        cy.visit("/cgi-bin/koha/sip2/system_preference_overrides");
        cy.get("#system_preference_overrides_list").contains(
            "There are no system preference overrides defined"
        );

        // GET system_preference_overrides returns something
        let system_preference_override = get_system_preference_override();
        let system_preference_overrides = [system_preference_override];

        cy.intercept("GET", "/api/v1/sip2/system_preference_overrides*", {
            statusCode: 200,
            body: system_preference_overrides,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept(
            "GET",
            "/api/v1/sip2/system_preference_overrides/*",
            system_preference_overrides
        );
        cy.visit("/cgi-bin/koha/sip2/system_preference_overrides/");
        cy.get("#system_preference_overrides_list").contains(
            "Showing 1 to 1 of 1 entries"
        );
    });

    it("Add system preference overrides", () => {
        let system_preference_override = get_system_preference_override();
        // No system preference overrides
        cy.intercept("GET", "/api/v1/sip2/system_preference_overrides**", {
            statusCode: 200,
            body: [],
        });

        // Click the button in the toolbar
        cy.visit("/cgi-bin/koha/sip2/system_preference_overrides");
        cy.contains("New system preference override").click();
        cy.get("#system_preference_overrides_add h2").contains(
            "New system preference override"
        );
        cy.left_menu_active_item_is("System preference overrides");

        // Fill in the form for normal attributes
        cy.get("#system_preference_overrides_add").contains("Submit").click();
        cy.get("input:invalid,textarea:invalid,select:invalid").should(
            "have.length",
            2
        );
        cy.get("#variable").type(system_preference_override.variable);
        cy.get("#value").type(system_preference_override.value);

        // Submit the form, get 500
        cy.intercept("POST", "/api/v1/sip2/system_preference_overrides", {
            statusCode: 500,
        });
        cy.get("#system_preference_overrides_add").contains("Submit").click();

        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Submit the form, success!
        cy.intercept("POST", "/api/v1/sip2/system_preference_overrides", {
            statusCode: 201,
            body: system_preference_override,
        });
        cy.get("#system_preference_overrides_add").contains("Submit").click();
        cy.get("main div[class='alert alert-info']").contains(
            "System preference override created"
        );
    });

    it("Edit system preference overrides", () => {
        let system_preference_override = get_system_preference_override();
        let system_preference_overrides = [system_preference_override];

        // Intercept follow-up 'search' request after entering /system_preference_overrides
        cy.intercept("GET", "/api/v1/sip2/system_preference_overrides?_page*", {
            statusCode: 200,
            body: system_preference_overrides,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("get-single-system_preference_overrides-search-result");
        cy.visit("/cgi-bin/koha/sip2/system_preference_overrides");
        cy.wait("@get-single-system_preference_overrides-search-result");

        // Intercept request after edit click
        cy.intercept(
            "GET",
            "/api/v1/sip2/system_preference_overrides/*",
            system_preference_override
        ).as("get-system_preference_overrides");

        // Click the 'Edit' button from the list
        cy.get("#system_preference_overrides_list table tbody tr:first")
            .contains("Edit")
            .click();
        cy.wait("@get-system_preference_overrides");
        cy.wait(500); // Cypress is too fast! Vue hasn't populated the form yet!
        cy.get("#system_preference_overrides_add h2").contains(
            "Edit system preference override"
        );
        cy.left_menu_active_item_is("System preference overrides");

        // Form has been correctly filled in
        cy.get("#variable").should(
            "have.value",
            system_preference_overrides[0].variable
        );
        cy.get("#value").should(
            "have.value",
            system_preference_overrides[0].value
        );

        // Submit the form, get 500
        cy.intercept(
            "PUT",
            "/api/v1/sip2/system_preference_overrides/*",
            req => {
                req.reply({
                    statusCode: 500,
                    delay: 1000,
                });
            }
        );
        cy.get("#system_preference_overrides_add").contains("Submit").click();

        cy.get("main div[class='modal_centered']").contains("Submitting...");
        cy.wait(1000);
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Submit the form, success!
        cy.intercept("PUT", "/api/v1/sip2/system_preference_overrides/*", {
            statusCode: 200,
            body: system_preference_overrides,
        });
        cy.get("#system_preference_overrides_add").contains("Submit").click();
        cy.get("main div[class='alert alert-info']").contains(
            "System preference override updated"
        );
    });

    it("Delete system preference overrides", () => {
        let system_preference_override = get_system_preference_override();
        let system_preference_overrides = [system_preference_override];

        // Delete from list
        // Click the 'Delete' button from the list
        cy.intercept("GET", "/api/v1/sip2/system_preference_overrides*", {
            statusCode: 200,
            body: system_preference_overrides,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept(
            "GET",
            "/api/v1/sip2/system_preference_overrides/*",
            system_preference_override
        );
        cy.visit("/cgi-bin/koha/sip2/system_preference_overrides");

        cy.get("#system_preference_overrides_list table tbody tr:first")
            .contains("Delete")
            .click();
        cy.get(".alert-warning.confirmation h1").contains(
            "remove this system preference override"
        );
        cy.contains(system_preference_override.variable);

        // Accept the confirmation dialog, get 500
        cy.intercept("DELETE", "/api/v1/sip2/system_preference_overrides/*", {
            statusCode: 500,
        });
        cy.contains("Yes, delete").click();
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Accept the confirmation dialog, success!
        cy.intercept("DELETE", "/api/v1/sip2/system_preference_overrides/*", {
            statusCode: 204,
            body: null,
        });
        cy.get("#system_preference_overrides_list table tbody tr:first")
            .contains("Delete")
            .click();
        cy.get(".alert-warning.confirmation h1").contains(
            "remove this system preference override"
        );
        cy.contains("Yes, delete").click();
        cy.get("main div[class='alert alert-info']")
            .contains("System preference override")
            .contains("deleted");
    });
});
