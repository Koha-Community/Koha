import { mount } from "@cypress/vue";

describe("Table search", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.intercept(
            "GET",
            "/api/v1/erm/config",
            '{"settings":{"ERMModule":"1","ERMProviders":["local"]}}'
        );
    });

    it("Input search bar and clear filter ", () => {
        let erm_title = cy.get_title();
        let titles = [erm_title];

        cy.intercept("GET", "/api/v1/erm/eholdings/local/titles*", {
            statusCode: 200,
            body: titles,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("get_titles");

        cy.visit("/cgi-bin/koha/erm/eholdings/local/titles");
        cy.get("#titles_list").contains("Showing 1 to 1 of 1 entries");

        // Should be disabled by default - empty search bar
        cy.get(".datatable button.dt_button_clear_filter").should(
            "have.class",
            "disabled"
        );

        // Type something in the input search bar
        cy.get(".datatable input[type='search']").type(
            erm_title.publication_title
        );
        cy.get(".datatable input[type='search']").should(
            "have.value",
            erm_title.publication_title
        );

        // Should no longer be disabled
        cy.get(".datatable button.dt_button_clear_filter").should(
            "not.have.class",
            "disabled"
        );

        // Click the clear_filter button
        cy.get(".datatable button.dt_button_clear_filter").click();
        cy.get(".datatable input[type='search']").should("have.value", "");

        // TODO: Some actual live API with data requests to test the search actually works
        // and returns results accordingly (or not)
    });
});
