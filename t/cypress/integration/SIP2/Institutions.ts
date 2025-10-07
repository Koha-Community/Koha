import { mount } from "@cypress/vue";

describe("Institutions", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    it("List institutions", () => {
        // GET institutions returns 500
        cy.intercept("GET", "/api/v1/sip2/institutions*", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.visit("/cgi-bin/koha/sip2/sip2.pl");
        cy.get(".sidebar_menu").contains("Institutions").click();
        cy.get("main div[class='alert alert-warning']").contains(
            /Something went wrong/
        );

        // GET institutions returns empty list
        cy.intercept("GET", "/api/v1/sip2/institutions*", []);
        cy.visit("/cgi-bin/koha/sip2/institutions");
        cy.get("#institutions_list").contains(
            "There are no institutions defined"
        );

        // GET institutions returns something
        let institution = cy.getSIP2Institution();
        let institutions = [institution];

        cy.intercept("GET", "/api/v1/sip2/institutions*", {
            statusCode: 200,
            body: institutions,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/sip2/institutions/*", institution);
        cy.visit("/cgi-bin/koha/sip2/institutions/");
        cy.get("#institutions_list").contains("Showing 1 to 1 of 1 entries");
    });

    it("Add institution", () => {
        let institution = cy.getSIP2Institution();
        // No institution
        cy.intercept("GET", "/api/v1/sip2/institutions**", {
            statusCode: 200,
            body: [],
        });

        // Click the button in the toolbar
        cy.visit("/cgi-bin/koha/sip2/institutions");
        cy.contains("New institution").click();
        cy.get("#institutions_add h2").contains("New institution");
        cy.left_menu_active_item_is("Institutions");

        // Fill in the form for normal attributes
        cy.get("#institutions_add").contains("Submit").click();
        cy.get("input:invalid,textarea:invalid,select:invalid").should(
            "have.length",
            1
        );
        cy.get("#name").type(institution.name);
        cy.get("#implementation").type(institution.implementation);
        cy.get("#checkin_no").should("be.checked");
        cy.get("#checkin_yes").click();
        cy.get("#checkin_no").should("not.be.checked");
        cy.get("#checkin_yes").should("be.checked");
        cy.get("#checkout_no").should("be.checked");
        cy.get("#checkout_yes").click();
        cy.get("#checkout_no").should("not.be.checked");
        cy.get("#checkout_yes").should("be.checked");
        cy.get("#offline_no").should("be.checked");
        cy.get("#renewal_no").should("be.checked");
        cy.get("#retries").type(institution.retries);
        cy.get("#timeout").type(institution.timeout);

        // Submit the form, get 500
        cy.intercept("POST", "/api/v1/sip2/institutions", {
            statusCode: 500,
        });
        cy.get("#institutions_add").contains("Submit").click();

        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Submit the form, success!
        cy.intercept("POST", "/api/v1/sip2/institutions", {
            statusCode: 201,
            body: institution,
        });
        cy.get("#institutions_add").contains("Submit").click();
        cy.get("main div[class='alert alert-info']").contains(
            "Institution created"
        );
    });

    it("Edit institution", () => {
        let institution = cy.getSIP2Institution();
        let institutions = [institution];

        // Intercept follow-up 'search' request after entering /institutions
        cy.intercept("GET", "/api/v1/sip2/institutions?_page*", {
            statusCode: 200,
            body: institutions,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("get-single-institution-search-result");
        cy.visit("/cgi-bin/koha/sip2/institutions");
        cy.wait("@get-single-institution-search-result");

        // Intercept request after edit click
        cy.intercept("GET", "/api/v1/sip2/institutions/*", institution).as(
            "get-institution"
        );

        // Click the 'Edit' button from the list
        cy.get("#institutions_list table tbody tr:first")
            .contains("Edit")
            .click();
        cy.wait("@get-institution");
        cy.get("#institutions_add h2").contains("Edit institution");
        cy.left_menu_active_item_is("Institutions");

        // Form has been correctly filled in
        cy.get("#name").should("have.value", institutions[0].name);
        cy.get("#implementation").should(
            "have.value",
            institutions[0].implementation
        );

        cy.get("#checkin_yes").should("be.checked");
        cy.get("#checkout_yes").should("be.checked");
        cy.get("#offline_no").should("be.checked");
        cy.get("#renewal_no").should("be.checked");

        cy.get("#retries").should("have.value", institutions[0].retries);
        cy.get("#status_update_no").should("be.checked");
        cy.get("#timeout").should("have.value", institutions[0].timeout);

        // Submit the form, get 500
        cy.intercept("PUT", "/api/v1/sip2/institutions/*", req => {
            req.reply({
                statusCode: 500,
                delay: 1000,
            });
        });
        cy.get("#institutions_add").contains("Submit").click();

        cy.get("main div[class='modal_centered']").contains("Submitting...");
        cy.wait(1000);
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Submit the form, success!
        cy.intercept("PUT", "/api/v1/sip2/institutions/*", {
            statusCode: 200,
            body: institution,
        });
        cy.get("#institutions_add").contains("Submit").click();
        cy.get("main div[class='alert alert-info']").contains(
            "Institution updated"
        );
    });

    it("Show institution", () => {
        let institution = cy.getSIP2Institution();
        let institutions = [institution];
        // Click the "name" link from the list
        cy.intercept("GET", "/api/v1/sip2/institutions*", {
            statusCode: 200,
            body: institutions,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/sip2/institutions/*", institution).as(
            "get-institution"
        );
        cy.visit("/cgi-bin/koha/sip2/institutions");
        let name_link = cy.get(
            "#institutions_list table tbody tr:first td:first a"
        );
        name_link.should("have.text", institution.name);
        name_link.click();
        cy.wait("@get-institution");
        cy.get("#institutions_show h2").contains(
            "Institution #" + institution.sip_institution_id
        );
        cy.left_menu_active_item_is("Institutions");
    });

    it("Delete institution", () => {
        let institution = cy.getSIP2Institution();
        let institutions = [institution];

        // Delete from list
        // Click the 'Delete' button from the list
        cy.intercept("GET", "/api/v1/sip2/institutions*", {
            statusCode: 200,
            body: institutions,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/sip2/institutions/*", institution);
        cy.visit("/cgi-bin/koha/sip2/institutions");

        cy.get("#institutions_list table tbody tr:first")
            .contains("Delete")
            .click();
        cy.get(".alert-warning.confirmation h1").contains(
            "remove this institution"
        );
        cy.contains(institution.name);

        // Accept the confirmation dialog, get 500
        cy.intercept("DELETE", "/api/v1/sip2/institutions/*", {
            statusCode: 500,
        });
        cy.contains("Yes, delete").click();
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Accept the confirmation dialog, success!
        cy.intercept("DELETE", "/api/v1/sip2/institutions/*", {
            statusCode: 204,
            body: null,
        });
        cy.get("#institutions_list table tbody tr:first")
            .contains("Delete")
            .click();
        cy.get(".alert-warning.confirmation h1").contains(
            "remove this institution"
        );
        cy.contains("Yes, delete").click();
        cy.get("main div[class='alert alert-info']")
            .contains("Institution")
            .contains("deleted");

        // Delete from show
        // Click the "name" link from the list
        cy.intercept("GET", "/api/v1/sip2/institutions*", {
            statusCode: 200,
            body: institutions,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/sip2/institutions/*", institution).as(
            "get-institution"
        );
        cy.visit("/cgi-bin/koha/sip2/institutions");
        let name_link = cy.get(
            "#institutions_list table tbody tr:first td:first a"
        );
        name_link.should("have.text", institution.name);
        name_link.click();
        cy.wait("@get-institution");
        cy.get("#institutions_show h2").contains(
            "Institution #" + institution.sip_institution_id
        );

        cy.get("#institutions_show #toolbar").contains("Delete").click();
        cy.get(".alert-warning.confirmation h1").contains(
            "remove this institution"
        );
        cy.contains("Yes, delete").click();

        //Make sure we return to list after deleting from show
        cy.get("#institutions_list table tbody tr:first");
    });
});
