describe("Item List CRUD operations", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    it("should list item lists", () => {
        cy.intercept("GET", "/api/v1/item-lists*", []);
        cy.visit("/cgi-bin/koha/lists/items");
        cy.get("#item_lists_list").contains("There are no item lists defined");

        const item_list = cy.getItemList();
        cy.intercept("GET", "/api/v1/item-lists*", {
            statusCode: 200,
            body: [item_list],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.visit("/cgi-bin/koha/lists/items");
        cy.get("#item_lists_list").contains("Showing 1 to 1 of 1 entries");
    });

    it("should add an item list", () => {
        const item_list = cy.getItemList();

        cy.intercept("GET", "/api/v1/item-lists*", []);

        cy.visit("/cgi-bin/koha/lists/items");
        cy.contains("New item list").click();
        cy.get("h2").contains("New item list");

        cy.get("#name").type(item_list.name);

        cy.get("#visibility .vs__search").type("private{enter}");

        cy.intercept("POST", "/api/v1/item-lists*", {
            statusCode: 201,
            body: item_list,
        });

        cy.get("#item_lists_add").contains("Save").click();

        cy.get("main div[class='alert alert-info']").contains(
            "Item list created"
        );
    });

    it("should edit an item list", () => {
        const item_list = cy.getItemList();

        cy.intercept("GET", "/api/v1/item-lists*", {
            statusCode: 200,
            body: [item_list],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.visit("/cgi-bin/koha/lists/items");

        cy.intercept("GET", "/api/v1/item-lists/*", item_list).as(
            "getItemList"
        );

        // For patronAutoComplete
        cy.intercept("GET", "/api/v1/patrons/1", {
            patron_id: 1,
            firstname: "Alex",
            preferred_name: "Al",
            surname: "Doe",
            library: { name: "A Library" },
        }).as("getPatrons");

        // Click the 'Edit' button from the list
        cy.get("#item_lists_list table tbody tr:first")
            .contains("Edit")
            .click();
        cy.wait("@getItemList");
        cy.wait("@getPatrons");
        cy.get("h2").contains("Edit item list");

        // Form has been correctly filled in
        cy.get("#name").should("have.value", item_list.name);
        cy.get("input[name=owner]").should("have.value", item_list.owner);
        cy.get("#visibility .vs__selected").contains("Private");

        cy.intercept("PUT", "/api/v1/item-lists/*", {
            statusCode: 200,
            body: item_list,
        });
        cy.get("#item_lists_add").contains("Save").click();
        cy.get("main div[class='alert alert-info']").contains(
            "Item list updated"
        );
    });

    it("should delete an item list", () => {
        const item_list = cy.getItemList();

        cy.intercept("GET", "/api/v1/item-lists*", {
            statusCode: 200,
            body: [item_list],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.visit("/cgi-bin/koha/lists/items");

        cy.get(
            "#item_lists_list table tbody tr:first .dropdown-toggle"
        ).click();

        cy.get("#item_lists_list table tbody tr:first")
            .contains("Delete")
            .click();
        cy.get(".alert-warning.confirmation h1").contains(
            "remove this item list"
        );
        cy.contains(item_list.name);

        // Accept the confirmation dialog, get 500
        cy.intercept("DELETE", "/api/v1/item-lists/*", {
            statusCode: 500,
        });
        cy.contains("Yes, delete").click();
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Accept the confirmation dialog, success!
        cy.intercept("DELETE", "/api/v1/item-lists/*", {
            statusCode: 204,
            body: null,
        });

        cy.get(
            "#item_lists_list table tbody tr:first .dropdown-toggle"
        ).click();
        cy.get("#item_lists_list table tbody tr:first")
            .contains("Delete")
            .click();
        cy.get(".alert-warning.confirmation h1").contains(
            "remove this item list"
        );
        cy.contains("Yes, delete").click();
        cy.get("main div[class='alert alert-info']")
            .contains("Item list")
            .contains("deleted");
    });
});

describe("Item List contents CRUD operations", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    it("should list items", () => {
        const item_list = cy.getItemList();
        cy.intercept("GET", "/api/v1/item-lists/" + item_list.id, item_list);
        cy.intercept(
            "GET",
            "/api/v1/item-lists/" + item_list.id + "/items*",
            []
        );
        cy.visit("/cgi-bin/koha/lists/items/" + item_list.id);
        cy.get("#items_list").contains("There are no items defined");

        const item = cy.getItem();
        cy.intercept("GET", "/api/v1/item-lists/" + item_list.id + "/items*", {
            statusCode: 200,
            body: [item],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.visit("/cgi-bin/koha/lists/items/" + item_list.id);
        cy.get("#items_list").contains("Showing 1 to 1 of 1 entries");
    });

    it("should add an item", () => {
        const item_list = cy.getItemList();
        cy.intercept("GET", "/api/v1/item-lists/" + item_list.id, item_list);
        cy.intercept(
            "GET",
            "/api/v1/item-lists/" + item_list.id + "/items*",
            []
        );
        cy.visit("/cgi-bin/koha/lists/items/" + item_list.id);

        cy.contains("Add items").click();
        cy.get("h2").contains("Add items");

        const item = cy.getItem();
        cy.get("#external_ids").type(item.external_id);

        cy.intercept("POST", "/api/v1/item-lists/" + item_list.id + "/items", {
            statusCode: 201,
            body: [item],
        });

        cy.get("#items_add").contains("Save").click();

        cy.get("main div[class='alert alert-info']").contains("Items added");
    });

    it("should remove an item", () => {
        const item_list = cy.getItemList();
        const item = cy.getItem();
        cy.intercept("GET", "/api/v1/item-lists/" + item_list.id, item_list);
        cy.intercept("GET", "/api/v1/item-lists/" + item_list.id + "/items*", {
            statusCode: 200,
            body: [item],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });

        cy.visit("/cgi-bin/koha/lists/items/" + item_list.id);

        cy.get("#items_list table tbody tr:first").contains("Remove").click();
        cy.get(".alert-warning.confirmation h1").contains(
            "remove this item from the list"
        );
        cy.contains(item.external_id);

        // Accept the confirmation dialog, get 500
        cy.intercept(
            "DELETE",
            "/api/v1/item-lists/" + item_list.id + "/items",
            {
                statusCode: 500,
            }
        );
        cy.contains("Yes, remove").click();
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Accept the confirmation dialog, success!
        cy.intercept(
            "DELETE",
            "/api/v1/item-lists/" + item_list.id + "/items",
            {
                statusCode: 204,
                body: null,
            }
        );
        cy.get("#items_list table tbody tr:first").contains("Remove").click();
        cy.get(".alert-warning.confirmation h1").contains(
            "remove this item from the list"
        );
        cy.contains("Yes, remove").click();
        cy.get("main div[class='alert alert-info']").contains("Item");
        cy.get("main div[class='alert alert-info']").contains("removed");
    });
});

describe("Item List shares CRUD operations", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    // Unlikely to need to be reused elsewhere
    const getShare = () => {
        return {
            borrowernumber: 1,
            created_date: "2013-06-04T00:00:00+00:00",
            item_list_id: 1,
            permission: "view",
        };
    };

    it("should list shares", () => {
        const item_list = cy.getItemList();
        cy.intercept("GET", "/api/v1/item-lists/" + item_list.id, item_list);
        cy.intercept(
            "GET",
            "/api/v1/item-lists/" + item_list.id + "/shares*",
            []
        );
        cy.visit("/cgi-bin/koha/lists/items/" + item_list.id + "/shares");
        cy.get("#item_list_shares_list").contains(
            "There are no shares defined"
        );

        const share = getShare();
        cy.intercept("GET", "/api/v1/item-lists/" + item_list.id + "/shares*", {
            statusCode: 200,
            body: [share],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.visit("/cgi-bin/koha/lists/items/" + item_list.id + "/shares");
        cy.get("#item_list_shares_list").contains(
            "Showing 1 to 1 of 1 entries"
        );
    });

    it("should add a share", () => {
        const item_list = cy.getItemList();
        cy.intercept("GET", "/api/v1/item-lists/" + item_list.id, item_list);
        cy.intercept(
            "GET",
            "/api/v1/item-lists/" + item_list.id + "/shares*",
            []
        );
        cy.visit("/cgi-bin/koha/lists/items/" + item_list.id + "/shares");

        cy.contains("Add share").click();
        cy.get("h2").contains("Add share");

        // For patronAutoComplete
        cy.intercept("GET", "/api/v1/patrons*", {
            statusCode: 200,
            body: [
                {
                    patron_id: 1,
                    firstname: "Alex",
                    preferred_name: "Al",
                    surname: "Doe",
                    library: { name: "A Library" },
                },
            ],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("getPatrons");

        cy.get("label[for=patron_id]+input").type("Alex Doe");
        cy.wait("@getPatrons");
        cy.get("label[for=patron_id]+input").type("{downarrow}{enter}");

        cy.get("#permission .vs__search").type("view{enter}");

        const share = getShare();

        cy.intercept("PUT", "/api/v1/item-lists/" + item_list.id + "/shares", {
            statusCode: 201,
            body: [share],
        });

        cy.get("#item_list_shares_add").contains("Save").click();

        cy.get("main div[class='alert alert-info']").contains("Shared");
    });

    it("should remove a share", () => {
        const item_list = cy.getItemList();
        const share = getShare();
        cy.intercept("GET", "/api/v1/item-lists/" + item_list.id, item_list);
        cy.intercept("GET", "/api/v1/item-lists/" + item_list.id + "/shares*", {
            statusCode: 200,
            body: [share],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });

        cy.visit("/cgi-bin/koha/lists/items/" + item_list.id + "/shares");

        cy.get("#item_list_shares_list table tbody tr:first")
            .contains("Remove")
            .click();
        cy.get(".alert-warning.confirmation h1").contains(
            "remove this share from the list"
        );

        // Accept the confirmation dialog, get 500
        cy.intercept(
            "DELETE",
            "/api/v1/item-lists/" + item_list.id + "/shares/*",
            {
                statusCode: 500,
            }
        );
        cy.contains("Yes, remove").click();
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Accept the confirmation dialog, success!
        cy.intercept(
            "DELETE",
            "/api/v1/item-lists/" + item_list.id + "/shares/*",
            {
                statusCode: 204,
                body: null,
            }
        );
        cy.get("#item_list_shares_list table tbody tr:first")
            .contains("Remove")
            .click();
        cy.get(".alert-warning.confirmation h1").contains(
            "remove this share from the list"
        );
        cy.contains("Yes, remove").click();
        cy.get("main div[class='alert alert-info']")
            .contains("Share")
            .contains("removed");
    });
});
