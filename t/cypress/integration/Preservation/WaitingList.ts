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
describe("WaitingList", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.intercept(
            "GET",
            "/cgi-bin/koha/svc/config/systempreferences/?pref=PreservationModule",
            '{"value":"1"}'
        );
        cy.intercept(
            "GET",
            "/cgi-bin/koha/svc/config/systempreferences/?pref=PreservationNotForLoanWaitingListIn",
            '{"value":"24"}'
        );
        cy.intercept(
            "GET",
            "/cgi-bin/koha/svc/config/systempreferences/?pref=PreservationNotForLoanDefaultTrainIn",
            '{"value":"42"}'
        );
    });

    it("List", () => {
        cy.intercept(
            "GET",
            "/cgi-bin/koha/svc/config/systempreferences/?pref=PreservationNotForLoanWaitingListIn",
            '{"value":""}'
        );
        cy.visit("/cgi-bin/koha/preservation/home.pl");
        cy.intercept("GET", "/api/v1/preservation/waiting-list/items*", []);
        cy.get("#navmenulist").contains("Waiting list").click();
        cy.get("#waiting-list").contains(
            "You need to configure this module first."
        );

        cy.intercept(
            "GET",
            "/cgi-bin/koha/svc/config/systempreferences/?pref=PreservationNotForLoanWaitingListIn",
            '{"value":"42"}'
        );
        cy.visit("/cgi-bin/koha/preservation/home.pl");
        cy.intercept("GET", "/api/v1/preservation/waiting-list/items*", []);
        cy.get("#navmenulist").contains("Waiting list").click();
        cy.get("#waiting-list").contains(
            "There are no items in the waiting list"
        );
    });

    it("Add to waiting list", () => {
        cy.intercept("GET", "/api/v1/preservation/waiting-list/items*", []);
        cy.visit("/cgi-bin/koha/preservation/waiting-list");
        cy.intercept("POST", "/api/v1/preservation/waiting-list/items", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.get("#waiting-list").contains("Add to waiting list").click();
        cy.get("#barcode_list").type("bc_1\nbc_2\nbc_3");
        cy.contains("Submit").click();
        cy.get("main div[class='dialog alert']").contains(
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
        cy.contains("Submit").click();
        cy.wait("@get-items");
        cy.get("main div[class='dialog message']").contains(
            "2 new items added."
        );
    });

    it("Add to waiting list then add to a train", () => {
        let train = {
            description: "yet another train",
            name: "a train",
            train_id: 1,
        };
        cy.intercept("GET", "/api/v1/preservation/trains*", [train]);
        cy.visit("/cgi-bin/koha/preservation/waiting-list");

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
        cy.contains("Submit").click();
        cy.wait("@get-items");
        cy.get("main div[class='dialog message']").contains(
            "2 new items added."
        );
        cy.contains("Add last 2 items to a train").click();
        cy.get("#train_id .vs__search").type(train.name + "{enter}");
        cy.intercept(
            "POST",
            "/api/v1/preservation/trains/" + train.train_id + "/items/batch",
            req => {
                req.reply({
                    statusCode: 201,
                    body: req.body,
                });
            }
        );
        cy.contains("Submit").click();
        cy.get("main div[class='dialog message']").contains(
            `2 items have been added to train ${train.train_id}.`
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
            error: "Something went wrong",
        });
        cy.get("#waiting-list table tbody tr:first").contains("Remove").click();
        cy.contains("Yes, remove").click();
        cy.get("main div[class='dialog alert']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Submit the form, success!
        cy.intercept("DELETE", "/api/v1/preservation/waiting-list/items/*", {
            statusCode: 204,
            body: null,
        });
        cy.get("#waiting-list table tbody tr:first").contains("Remove").click();
        cy.contains("Yes, remove").click();
        cy.get("main div[class='dialog message']").contains(
            `Item removed from the waiting list`
        );
    });
});
