import { mount } from "@cypress/vue";

function get_listener() {
    return {
        client_timeout: 600,
        port: "127.0.0.1:8023/tcp/IPv4",
        protocol: "SIP/2.00",
        sip_listener_id: 1,
        timeout: 60,
        transport: "RAW",
    };
}

describe("Listeners", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    it("List listeners", () => {
        // GET listeners returns 500
        cy.intercept("GET", "/api/v1/sip2/listeners*", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.visit("/cgi-bin/koha/sip2/sip2.pl");
        cy.get("#navmenulist").contains("Listeners").click();
        cy.get("main div[class='alert alert-warning']").contains(
            /Something went wrong/
        );

        // GET listeners returns empty list
        cy.intercept("GET", "/api/v1/sip2/listeners*", []);
        cy.visit("/cgi-bin/koha/sip2/listeners");
        cy.get("#listener_list").contains("There are no listeners defined");

        // GET listeners returns something
        let listener = get_listener();
        let listeners = [listener];

        cy.intercept("GET", "/api/v1/sip2/listeners*", {
            statusCode: 200,
            body: listeners,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/sip2/listeners/*", listeners);
        cy.visit("/cgi-bin/koha/sip2/listeners/");
        cy.get("#listener_list").contains("Showing 1 to 1 of 1 entries");
    });

    it("Add listeners", () => {
        let listener = get_listener();
        // No listeners
        cy.intercept("GET", "/api/v1/sip2/listeners**", {
            statusCode: 200,
            body: [],
        });

        // Click the button in the toolbar
        cy.visit("/cgi-bin/koha/sip2/listeners");
        cy.contains("New listener").click();
        cy.get("#listener_add h2").contains("New listener");
        cy.left_menu_active_item_is("Listeners");

        // Fill in the form for normal attributes
        cy.get("#listener_add").contains("Submit").click();
        cy.get("input:invalid,textarea:invalid,select:invalid").should(
            "have.length",
            1
        );
        cy.get("#port").type(listener.port);
        cy.get("#client_timeout").type(listener.client_timeout);
        cy.get("#protocol").type(listener.protocol);
        cy.get("#timeout").type(listener.timeout);
        cy.get("#transport").type(listener.transport);

        // Submit the form, get 500
        cy.intercept("POST", "/api/v1/sip2/listeners", {
            statusCode: 500,
        });
        cy.get("#listener_add").contains("Submit").click();

        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Submit the form, success!
        cy.intercept("POST", "/api/v1/sip2/listeners", {
            statusCode: 201,
            body: listener,
        });
        cy.get("#listener_add").contains("Submit").click();
    });

    it("Edit listeners", () => {
        let listener = get_listener();
        let listeners = [listener];

        // Intercept follow-up 'search' request after entering /listeners
        cy.intercept("GET", "/api/v1/sip2/listeners?_page*", {
            statusCode: 200,
            body: listeners,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("get-single-listeners-search-result");
        cy.visit("/cgi-bin/koha/sip2/listeners");
        cy.wait("@get-single-listeners-search-result");

        // Intercept request after edit click
        cy.intercept("GET", "/api/v1/sip2/listeners/*", listener).as(
            "get-listeners"
        );

        // Click the 'Edit' button from the list
        cy.get("#listener_list table tbody tr:first").contains("Edit").click();
        cy.wait("@get-listeners");
        cy.wait(500); // Cypress is too fast! Vue hasn't populated the form yet!
        cy.get("#listener_add h2").contains("Edit listener");
        cy.left_menu_active_item_is("Listeners");

        // Form has been correctly filled in
        cy.get("#port").should("have.value", listeners[0].port);
        cy.get("#client_timeout").should(
            "have.value",
            listeners[0].client_timeout
        );
        cy.get("#protocol").should("have.value", listeners[0].protocol);
        cy.get("#timeout").should("have.value", listeners[0].timeout);
        cy.get("#transport .vs__selected-options").contains(
            listeners[0].transport
        );

        // Submit the form, get 500
        cy.intercept("PUT", "/api/v1/sip2/listeners/*", req => {
            req.reply({
                statusCode: 500,
                delay: 1000,
            });
        });
        cy.get("#listener_add").contains("Submit").click();

        cy.get("main div[class='modal_centered']").contains("Submitting...");
        cy.wait(1000);
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Submit the form, success!
        cy.intercept("PUT", "/api/v1/sip2/listeners/*", {
            statusCode: 200,
            body: listeners,
        });
        cy.get("#listener_add").contains("Submit").click();
    });

    it("Show listeners", () => {
        let listener = get_listener();
        let listeners = [listener];
        // Click the "name" link from the list
        cy.intercept("GET", "/api/v1/sip2/listeners*", {
            statusCode: 200,
            body: listeners,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/sip2/listeners/*", listener).as(
            "get-listeners"
        );
        cy.visit("/cgi-bin/koha/sip2/listeners");
        let name_link = cy.get(
            "#listener_list table tbody tr:first td:first a"
        );
        name_link.should("have.text", listener.port);
        name_link.click();
        cy.wait("@get-listeners");
        cy.wait(500); // Cypress is too fast! Vue hasn't populated the form yet!
        cy.get("#listener_show h2").contains(
            "Listener #" + listener.sip_listener_id
        );
        cy.left_menu_active_item_is("Listeners");
    });

    it("Delete listeners", () => {
        let listener = get_listener();
        let listeners = [listener];

        // Delete from list
        // Click the 'Delete' button from the list
        cy.intercept("GET", "/api/v1/sip2/listeners*", {
            statusCode: 200,
            body: listeners,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/sip2/listeners/*", listener);
        cy.visit("/cgi-bin/koha/sip2/listeners");

        cy.get("#listener_list table tbody tr:first")
            .contains("Delete")
            .click();
        cy.get(".alert-warning.confirmation h1").contains(
            "remove this listener"
        );
        cy.contains(listener.port);

        // Accept the confirmation dialog, get 500
        cy.intercept("DELETE", "/api/v1/sip2/listeners/*", {
            statusCode: 500,
        });
        cy.contains("Yes, delete").click();
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Accept the confirmation dialog, success!
        cy.intercept("DELETE", "/api/v1/sip2/listeners/*", {
            statusCode: 204,
            body: null,
        });
        cy.get("#listener_list table tbody tr:first")
            .contains("Delete")
            .click();
        cy.get(".alert-warning.confirmation h1").contains(
            "remove this listener"
        );
        cy.contains("Yes, delete").click();
        cy.get("main div[class='alert alert-info']")
            .contains("Listener")
            .contains("deleted");

        // Delete from show
        // Click the "name" link from the list
        cy.intercept("GET", "/api/v1/sip2/listeners*", {
            statusCode: 200,
            body: listeners,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/sip2/listeners/*", listener).as(
            "get-listener"
        );
        cy.visit("/cgi-bin/koha/sip2/listeners");
        let name_link = cy.get(
            "#listener_list table tbody tr:first td:first a"
        );
        name_link.should("have.text", listener.port);
        name_link.click();
        cy.wait("@get-listener");
        cy.wait(500); // Cypress is too fast! Vue hasn't populated the form yet!
        cy.get("#listener_show h2").contains(
            "Listener #" + listener.sip_listener_id
        );

        cy.get("#listener_show #toolbar").contains("Delete").click();
        cy.get(".alert-warning.confirmation h1").contains(
            "remove this listener"
        );
        cy.contains("Yes, delete").click();

        //Make sure we return to list after deleting from show
        cy.get("#listener_list table tbody tr:first");
    });
});
