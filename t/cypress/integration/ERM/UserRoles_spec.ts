import { mount } from "@cypress/vue";

describe("Add/search user", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.intercept(
            "GET",
            "/api/v1/erm/config",
            '{"settings":{"ERMModule":"1","ERMProviders":["local"]}}'
        );
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

        //Intercept patrons request
        cy.intercept("GET", "/api/v1/erm/users*", {
            statusCode: 200,
            body: [
                {
                    patron_id: 1,
                    firstname: "foo",
                    surname: "bar",
                    preferred_name: "foo",
                    category_id: "S",
                    library: {
                        library_id: "CPL",
                        name: "Centerville",
                    },
                },
                {
                    patron_id: 2,
                    firstname: "foofoo",
                    surname: "barbar",
                    category_id: "S",
                    library: {
                        library_id: "CPL",
                        name: "Centerville",
                    },
                },
            ],
            headers: {
                "X-Base-Total-Count": "2",
                "X-Total-Count": "2",
            },
        });

        cy.intercept("GET", "/api/v1/patrons/1", {
            statusCode: 200,
            body: {
                patron_id: 1,
                firstname: "foo",
                surname: "bar",
                preferred_name: "foo",
                category_id: "S",
                library: {
                    library_id: "CPL",
                    name: "Centerville",
                },
            },
        });

        // Click the button in the toolbar
        cy.visit("/cgi-bin/koha/erm/agreements");
        cy.contains("New agreement").click();
        cy.get("#agreements_add h2").contains("New agreement");
        cy.left_menu_active_item_is("Agreements");

        cy.contains("Add new user").click();
        cy.contains("Select user").click();
        cy.get("#patron_search_modal fieldset.action")
            .contains("Search")
            .click();

        cy.get("#patron_search_modal table").contains("bar, foo");
        cy.get("#patron_search_modal td").contains("Select").click();

        cy.get("#user_roles li:first span.user").contains("foo bar");
    });
});
