import { mount } from "@cypress/vue";

function get_items() {
    // This is not a full item but it contains the info we are using
    return [
        {
            biblio: {
                biblio_id: 1,
                title: "a biblio title",
            },
            external_id: "bc_1",
            item_id: 1,
        },
        {
            biblio: {
                biblio_id: 2,
                title: "yet another biblio title",
            },
            external_id: "bc_3",
            item_id: 3,
        },
    ];
}
let config = {
    permissions: { manage_sysprefs: "1" },
    settings: {
        enabled: "1",
        not_for_loan_default_train_in: "42",
        not_for_loan_waiting_list_in: "24",
    },
};
describe("WaitingList", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.intercept(
            "GET",
            "/api/v1/preservation/config",
            JSON.stringify(config)
        );
    });

    it("List", () => {
        config.settings.not_for_loan_waiting_list_in = "";
        cy.intercept(
            "GET",
            "/api/v1/preservation/config",
            JSON.stringify(config)
        );
        cy.visit("/cgi-bin/koha/preservation/home.pl");
        cy.intercept("GET", "/api/v1/preservation/waiting-list/items*", []);
        cy.get(".sidebar_menu").contains("Waiting list").click();
        cy.get("#waiting-list").contains(
            "You need to configure this module first."
        );

        config.settings.not_for_loan_waiting_list_in = "42";
        cy.intercept(
            "GET",
            "/api/v1/preservation/config",
            JSON.stringify(config)
        );
        cy.visit("/cgi-bin/koha/preservation/home.pl");
        cy.intercept("GET", "/api/v1/preservation/waiting-list/items*", []);
        cy.get(".sidebar_menu").contains("Waiting list").click();
        cy.get("#waiting-list").contains(
            "There are no items in the waiting list"
        );
    });

    it("Add to waiting list", () => {
        cy.intercept("GET", "/api/v1/preservation/waiting-list/items*", []);
        cy.visit("/cgi-bin/koha/preservation/waiting-list");
        cy.intercept("POST", "/api/v1/preservation/waiting-list/items", {
            statusCode: 500,
        });
        cy.get("#waiting-list").contains("Add to waiting list").click();
        cy.get("#barcode_list").type("bc_1\nbc_2\nbc_3");
        cy.get("#add_to_waiting_list .approve").click();
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        cy.intercept("GET", "/api/v1/preservation/waiting-list/items*", {
            statusCode: 200,
            body: get_items(),
            headers: {
                "X-Base-Total-Count": "2",
                "X-Total-Count": "2",
            },
        }).as("get-items");
        cy.intercept("POST", "/api/v1/preservation/waiting-list/items", [
            { item_id: 1 },
            { item_id: 3 },
        ]);
        cy.get("#waiting-list").contains("Add to waiting list").click();
        cy.get("#barcode_list").type("bc_1\nbc_2\nbc_3");
        cy.get("#add_to_waiting_list .approve").click();
        cy.wait("@get-items");
        cy.get("#warning.modal").contains(
            "2 new items added. 1 items not found."
        );
    });

    it("Remove item from waiting list", () => {
        cy.intercept("GET", "/api/v1/preservation/waiting-list/items*", {
            statusCode: 200,
            body: get_items(),
            headers: {
                "X-Base-Total-Count": "2",
                "X-Total-Count": "2",
            },
        }); //.as("get-items")
        cy.visit("/cgi-bin/koha/preservation/waiting-list");

        // Submit the form, get 500
        cy.intercept("DELETE", "/api/v1/preservation/waiting-list/items/*", {
            statusCode: 500,
        });
        cy.get("#waiting-list table tbody tr:first").contains("Remove").click();
        cy.contains("Yes, remove").click();
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Submit the form, success!
        cy.intercept("DELETE", "/api/v1/preservation/waiting-list/items/*", {
            statusCode: 204,
            body: null,
        });
        cy.get("#waiting-list table tbody tr:first").contains("Remove").click();
        cy.contains("Yes, remove").click();
        cy.get("main div[class='alert alert-info']").contains(
            `Item removed from the waiting list`
        );
    });
});
