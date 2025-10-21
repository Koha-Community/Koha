import { mount } from "@cypress/vue";

function get_attributes() {
    return [
        {
            processing_attribute_id: 1,
            processing_id: 1,
            name: "Country",
            type: "authorised_value",
            option_source: "COUNTRY",
        },
        {
            processing_attribute_id: 2,
            processing_id: 1,
            name: "DB",
            type: "db_column",
            option_source: "biblio.title",
        },
        {
            processing_attribute_id: 3,
            processing_id: 1,
            name: "Height",
            type: "free_text",
            option_source: null,
        },
    ];
}
function get_other_attributes() {
    return [
        {
            processing_attribute_id: 4,
            processing_id: 2,
            name: "Country",
            type: "authorised_value",
            option_source: "COUNTRY",
        },
        {
            processing_attribute_id: 5,
            processing_id: 2,
            name: "Width",
            type: "free_text",
            option_source: null,
        },
    ];
}

function get_processings() {
    return [
        {
            name: "new processing",
            processing_id: 1,
            attributes: get_attributes(),
            letter_code: null,
        },
        {
            name: "an other processing",
            processing_id: 2,
            attributes: get_other_attributes(),
            letter_code: null,
        },
    ];
}

function get_items() {
    // This is not a full item but it contains the info we are using
    return [
        {
            biblio: {
                biblio_id: 1,
                title: "a biblio title",
                author: "an author",
            },
            external_id: "bc_1",
            item_id: 1,
            callnumber: "cn_1",
        },
        {
            biblio: {
                biblio_id: 2,
                title: "an other biblio title",
                author: "another author",
            },
            external_id: "bc_2",
            item_id: 2,
            callnumber: "cn_2",
        },
        {
            biblio: {
                biblio_id: 3,
                title: "yet an other biblio title",
                author: "yet another author",
            },
            external_id: "bc_3",
            item_id: 3,
            callnumber: "cn_3",
        },
    ];
}

function get_train_items() {
    let train_item_1 = get_items()[0];
    let processing_attributes = get_attributes();
    train_item_1.attributes = [
        {
            processing_attribute: processing_attributes[0],
            processing_attribute_id:
                processing_attributes[0].processing_attribute_id,
            value: "Argentina",
            _strings: { value: { str: "Argentina" } },
        },
        {
            processing_attribute: processing_attributes[0],
            processing_attribute_id:
                processing_attributes[0].processing_attribute_id,
            value: "Not a country",
            _strings: { value: { str: "Not a country" } },
        },
        {
            processing_attribute: processing_attributes[1],
            processing_attribute_id:
                processing_attributes[1].processing_attribute_id,
            value: "a biblio title modified",
            _strings: { value: { str: "a biblio title modified" } },
        },
        {
            processing_attribute: processing_attributes[2],
            processing_attribute_id:
                processing_attributes[2].processing_attribute_id,
            value: "12cm",
            _strings: { value: { str: "12cm" } },
        },
    ];
    train_item_1.added_on = "2023-03-31T12:23:34+00:00";
    train_item_1.processing_id = 1;
    train_item_1.processing = get_processings()[0];
    train_item_1.item_id = 1;
    train_item_1.train_item_id = 1;
    train_item_1.user_train_item_id = 1;

    let train_item_2 = get_items()[1];
    let processing_attributes = get_attributes();
    train_item_2.attributes = [
        {
            processing_attribute: processing_attributes[0],
            processing_attribute_id:
                processing_attributes[0].processing_attribute_id,
            value: "Uruguay",
            _strings: { value: { str: "Uruguay" } },
        },
        {
            processing_attribute: processing_attributes[1],
            processing_attribute_id:
                processing_attributes[1].processing_attribute_id,
            value: "an other modified title",
            _strings: { value: { str: "an other modified title" } },
        },
        {
            processing_attribute: processing_attributes[2],
            processing_attribute_id:
                processing_attributes[2].processing_attribute_id,
            value: "34cm",
            _strings: { value: { str: "34cm" } },
        },
    ];
    train_item_2.added_on = "2023-04-01T12:34:56+00:00";
    train_item_2.processing_id = 1;
    train_item_2.processing = get_processings()[0];
    train_item_2.item_id = 2;
    train_item_2.train_item_id = 2;
    train_item_2.user_train_item_id = 2;

    let train_item_3 = get_items()[0];
    let processing_attributes = get_other_attributes();
    train_item_3.attributes = [
        {
            processing_attribute: processing_attributes[0],
            processing_attribute_id:
                processing_attributes[0].processing_attribute_id,
            value: "Bolivia",
            _strings: { value: { str: "Bolivia" } },
        },
        {
            processing_attribute: processing_attributes[1],
            processing_attribute_id:
                processing_attributes[1].processing_attribute_id,
            value: "W 123cm",
            _strings: { value: { str: "W 123cm" } },
        },
    ];
    train_item_3.added_on = "2023-04-02T12:34:56+00:00";
    train_item_3.processing_id = 2;
    train_item_3.processing = get_processings()[1];
    train_item_3.item_id = 3;
    train_item_3.train_item_id = 3;
    train_item_3.user_train_item_id = 3;

    return [train_item_1, train_item_2, train_item_3];
}

function get_train() {
    let processings = get_processings();
    return {
        train_id: 1,
        name: "My train",
        description: "Just a train",
        default_processing_id: processings[0].processing_id,
        not_for_loan: "42",
        created_on: "2023-04-05T10:16:27+00:00",
        closed_on: null,
        sent_on: null,
        received_on: null,
        items: [],
        default_processing: processings[0],
    };
}

describe("Trains", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.intercept(
            "GET",
            "/api/v1/preservation/config",
            '{"permissions":{"manage_sysprefs":"1"},"settings":{"enabled":"1","not_for_loan_default_train_in":"42","not_for_loan_waiting_list_in": "24"}}'
        );

        cy.intercept("GET", "/api/v1/authorised_value_categories?q=*", [
            {
                authorised_values: [
                    {
                        category_name: "NOT_LOAN",
                        description: "Ordered",
                        value: "-1",
                    },
                    {
                        category_name: "NOT_LOAN",
                        description: "Not for loan",
                        value: "1",
                    },
                    {
                        category_name: "NOT_LOAN",
                        description: "Staff collection",
                        value: "2",
                    },
                    {
                        category_name: "NOT_LOAN",
                        description: "Added to bundle",
                        value: "3",
                    },
                    {
                        category_name: "NOT_LOAN",
                        description: "In preservation",
                        value: "24",
                    },
                    {
                        category_name: "NOT_LOAN",
                        description: "In preservation external",
                        value: "42",
                    },
                    {
                        category_name: "NOT_LOAN",
                        description: "In preservation other",
                        value: "43",
                    },
                ],
                category_name: "NOT_LOAN",
                is_integer_only: false,
                is_system: true,
            },
        ]);
    });

    it("List trains", () => {
        // GET trains returns 500
        cy.intercept("GET", "/api/v1/preservation/trains*", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.visit("/cgi-bin/koha/preservation/home.pl");
        cy.get(".sidebar_menu").contains("Trains").click();
        cy.get("main div[class='alert alert-warning']").contains(
            /Something went wrong/
        );

        // GET trains returns empty list
        cy.intercept("GET", "/api/v1/preservation/trains*", []);
        cy.visit("/cgi-bin/koha/preservation/trains");
        cy.get("#trains_list").contains("There are no trains defined");

        // GET trains returns something
        let train = get_train();
        let trains = [train];

        cy.intercept("GET", "/api/v1/preservation/trains*", {
            statusCode: 200,
            body: trains,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/preservation/trains/*", train);
        cy.visit("/cgi-bin/koha/preservation/trains");
        cy.get("#trains_list").contains("Showing 1 to 1 of 1 entries");
    });

    it("Add train", () => {
        cy.intercept("GET", "/api/v1/preservation/trains*", []);
        cy.intercept(
            "GET",
            "/api/v1/preservation/processings*",
            get_processings()
        );
        cy.visit("/cgi-bin/koha/preservation/trains");
        let train = get_train();
        cy.contains("New train").click();
        cy.get("#name").type(train.name);
        cy.get("#description").type(train.description);
        // Confirm that the default not_for_loan is selected
        cy.get("#not_for_loan .vs__selected").contains(
            "In preservation external"
        );
        // Change it
        cy.get("#not_for_loan .vs__search").type(
            "In preservation other{enter}"
        );
        cy.get("#default_processing_id .vs__search").type(
            "new processing{enter}"
        );

        // Submit the form, get 500
        cy.intercept("POST", "/api/v1/preservation/trains", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.get("#trains_add").contains("Save").click();
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Submit the form, success!
        cy.intercept("POST", "/api/v1/preservation/trains", {
            statusCode: 201,
            body: train,
        });
        cy.get("#trains_add").contains("Save").click();
        cy.get("main div[class='alert alert-info']").contains("Train created");
    });

    it("Edit train", () => {
        let train = get_train();
        let processings = get_processings();
        cy.intercept("GET", "/api/v1/preservation/trains/*", train);
        cy.intercept("GET", "/api/v1/preservation/trains*", {
            statusCode: 200,
            body: [train],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });

        cy.intercept("GET", "/api/v1/preservation/processings*", processings);
        cy.visit("/cgi-bin/koha/preservation/trains");
        cy.get("#trains_list table tbody tr:first").contains("Edit").click();
        cy.get("#name").should("have.value", train.name);
        cy.get("#description").should("have.value", train.description);
        cy.get("#not_for_loan .vs__selected").contains(
            "In preservation external"
        );
        cy.get("#default_processing_id .vs__selected").contains(
            train.default_processing.name
        );

        // Submit the form, get 500
        cy.intercept("PUT", "/api/v1/preservation/trains/*", {
            statusCode: 500,
        });
        cy.get("#trains_add").contains("Save").click();
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Submit the form, success!
        cy.intercept("PUT", "/api/v1/preservation/trains/*", {
            statusCode: 200,
            body: train,
        });
        cy.intercept("GET", "/api/v1/preservation/trains", {
            statusCode: 200,
            body: [train],
        });
        cy.get("#trains_add").contains("Save").click();
        cy.get("main div[class='alert alert-info']").contains("Train updated");
    });

    it("Simple show train", () => {
        let train = get_train();
        let trains = [train];

        cy.intercept("GET", "/api/v1/preservation/trains*", {
            statusCode: 200,
            body: trains,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/preservation/trains/*", train);
        cy.visit("/cgi-bin/koha/preservation/trains");
        let name_link = cy.get("#trains_list table tbody tr:first td:first a");
        name_link.should("have.text", train.train_id);
        name_link.click();
        cy.get("#trains_show h2").contains("Train #" + train.train_id);

        cy.contains("Name:" + train.name);
        cy.contains("Description:" + train.description);
        cy.contains(
            "Status for item added to this train:" + "In preservation external"
        );
        cy.contains("Default processing:" + train.default_processing.name);
    });

    it("Show train close, send, receive", () => {
        let train = get_train();
        cy.intercept("GET", "/api/v1/preservation/trains/" + train.train_id, {
            statusCode: 200,
            body: train,
        }).as("get-train");
        cy.visit("/cgi-bin/koha/preservation/trains/" + train.train_id);
        cy.wait("@get-train");
        cy.contains("Closed on:").should("not.exist");
        cy.contains("Sent on:").should("not.exist");
        cy.contains("Received on:").should("not.exist");

        let closed_train = Object.assign({}, train);
        closed_train.closed_on = "2022-10-27 12:34:56";
        cy.intercept("PUT", "/api/v1/preservation/trains/" + train.train_id, {
            statusCode: 201,
            body: closed_train,
        }).as("set-train");
        cy.intercept("GET", "/api/v1/preservation/trains/" + train.train_id, {
            statusCode: 200,
            body: closed_train,
        }).as("get-train");
        cy.get("#toolbar").contains("Close").click();
        cy.wait("@get-train");
        cy.contains("Closed on:").should("exist");
        cy.contains("Sent on:").should("not.exist");
        cy.contains("Received on:").should("not.exist");

        let sent_train = Object.assign({}, closed_train);
        sent_train.sent_on = "2022-10-28 12:34:56";
        cy.intercept("PUT", "/api/v1/preservation/trains/" + train.train_id, {
            statusCode: 201,
            body: sent_train,
        }).as("set-train");
        cy.intercept("GET", "/api/v1/preservation/trains/" + train.train_id, {
            statusCode: 200,
            body: sent_train,
        }).as("get-train");
        cy.get("#toolbar").contains("Send").click();
        cy.wait("@get-train");
        cy.contains("Closed on:").should("exist");
        cy.contains("Sent on:").should("exist");
        cy.contains("Received on:").should("not.exist");

        let received_train = Object.assign({}, sent_train);
        received_train.received_on = "2022-10-29 12:34:56";
        cy.intercept("PUT", "/api/v1/preservation/trains/" + train.train_id, {
            statusCode: 201,
            body: received_train,
        }).as("set-train");
        cy.intercept("GET", "/api/v1/preservation/trains/" + train.train_id, {
            statusCode: 200,
            body: received_train,
        }).as("get-train");
        cy.get("#toolbar").contains("Receive").click();
        cy.wait("@get-train");
        cy.contains("Closed on:").should("exist");
        cy.contains("Sent on:").should("exist");
        cy.contains("Received on:").should("exist");
    });

    it("Delete train", () => {
        let train = get_train();
        cy.intercept("GET", "/api/v1/preservation/trains*", {
            statusCode: 200,
            body: [train],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.visit("/cgi-bin/koha/preservation/trains");

        // Submit the form, get 500
        cy.intercept(
            "DELETE",
            "/api/v1/preservation/trains/" + train.train_id,
            {
                statusCode: 500,
                error: "Something went wrong",
            }
        );
        cy.get("#trains_list table tbody tr:first").contains("Delete").click();
        cy.contains("Yes, delete").click();
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Submit the form, success!
        cy.intercept(
            "DELETE",
            "/api/v1/preservation/trains/" + train.train_id,
            {
                statusCode: 201,
                body: null,
            }
        );
        cy.get("#trains_list table tbody tr:first").contains("Delete").click();
        cy.contains("Yes, delete").click();
        cy.get("main div[class='alert alert-info']").contains(
            `Train ${train.name} deleted`
        );
    });

    it("Add new item to a train", () => {
        let train = get_train();
        cy.intercept(
            "GET",
            "/api/v1/preservation/trains/" + train.train_id,
            train
        );
        let processings = get_processings();
        cy.intercept("GET", "/api/v1/preservation/processings*", processings);
        cy.intercept(
            "GET",
            "/api/v1/preservation/processings/" + processings[0].processing_id,
            processings[0]
        );
        cy.visit("/cgi-bin/koha/preservation/trains/" + train.train_id);
        cy.contains("Add items").click();
        cy.get("#barcode").type("bc_1");
        cy.intercept("GET", "/api/v1/preservation/waiting-list/items*", []);
        cy.contains("Submit").click();
        cy.get("#warning.modal").contains(
            "Cannot find item with this barcode. It must be in the waiting list."
        );
        cy.get("#close_modal").click();

        let item = get_items()[0];
        cy.intercept("GET", "/api/v1/preservation/waiting-list/items*", [item]);
        cy.contains("Submit").click();
        cy.intercept(
            "POST",
            `/api/v1/preservation/trains/${train.train_id}/items`,
            {
                statusCode: 201,
                body: item, // Not correct but not important
            }
        );
        cy.contains("Itemnumber:" + item.item_id);
        cy.get("#processing .vs__selected").contains(
            train.default_processing.name
        );
        cy.contains("Country:");
        cy.get("#attribute_0 .vs__search").type("Argentin{enter}");
        cy.contains("DB:");
        cy.get("#attribute_1").should("have.value", item.biblio.title);
        cy.get("#attribute_1").type(" modified");
        cy.contains("Height:");
        cy.get("#attribute_2").type("42cm");

        let train_items = get_train_items();
        let train_with_one_item = Object.assign({}, train);
        train_with_one_item.items = [train_items[0]];

        cy.intercept(
            "GET",
            "/api/v1/preservation/trains/" + train.train_id,
            train_with_one_item
        ).as("get-train");
        cy.contains("Submit").click();
        cy.wait("@get-train");
        cy.get("#trains_show").contains("Showing 1 to 1 of 1 entries");

        let train_with_2_items = Object.assign({}, train);
        train_with_2_items.items = [train_items[0], train_items[1]];
        cy.intercept(
            "GET",
            "/api/v1/preservation/trains/" + train.train_id,
            train_with_2_items
        );
        cy.visit("/cgi-bin/koha/preservation/trains/" + train.train_id);
        cy.get("#trains_show table").should("exist");
        cy.get("#trains_show").contains("Showing 1 to 2 of 2 entries");
        train_with_2_items.items.forEach(train_item => {
            train_item.attributes.forEach(attribute => {
                cy.get("td").contains(attribute.value);
            });
        });

        let train_with_3_items = Object.assign({}, train);
        train_with_3_items.items = [
            train_items[0],
            train_items[1],
            train_items[2],
        ];
        cy.intercept(
            "GET",
            "/api/v1/preservation/trains/" + train.train_id,
            train_with_3_items
        );
        cy.visit("/cgi-bin/koha/preservation/trains/" + train.train_id);
        cy.get("#trains_show table").should("not.exist");
        train_with_3_items.items.forEach((train_item, i) => {
            train_item.attributes.forEach(attribute => {
                let re = new RegExp(attribute.value);
                cy.get(`#item_${i}`).contains(re);
            });
        });
    });

    it("Add to waiting list then add to a train", () => {
        let train = get_train();
        let processing = get_processings()[0];
        cy.intercept("GET", "/api/v1/preservation/trains*", [train]);
        cy.intercept("GET", "/api/v1/preservation/trains/1", train);
        cy.intercept("GET", "/api/v1/preservation/processings/1", processing);
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
            { item_id: 2 },
        ]);

        cy.get("#items_list").contains("Add to waiting list").click();
        cy.get("#barcode_list").type("bc_1\nbc_2");
        cy.contains("Save").click();
        cy.wait("@get-items");
        cy.get("main div[class='alert alert-info']").contains(
            "2 new items added."
        );

        cy.get("#items_list").contains("Add to waiting list").click();
        cy.get("#barcode_list").type("bc_1\nbc_2\nbc_3");
        cy.contains("Save").click();
        cy.wait("@get-items");
        cy.get("#warning.modal").contains(
            "2 new items added. 1 items not found."
        );
        cy.get("#close_modal").click();
        cy.contains("Add last 2 items to a train").click();
        cy.get("#train_id_selected_for_add .vs__search").type(
            train.name + "{enter}"
        );
        cy.intercept("GET", "/api/v1/items*", {
            statusCode: 200,
            body: get_items().filter(
                item => item.item_id == 1 || item.item_id == 2
            ),
            headers: {
                "X-Base-Total-Count": "2",
                "X-Total-Count": "2",
            },
        });
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
        cy.intercept("GET", "/api/v1/authorised_value_categories?q=*", [
            {
                authorised_values: [],
                category_name: "COUNTRY",
                is_integer_only: false,
                is_system: false,
            },
        ]);
        cy.get("#confirmation").contains("Save").click();
        train.items = get_train_items().filter(
            train_item => train_item.item_id == 1 || train_item.item_id == 2
        );
        cy.intercept("GET", "/api/v1/preservation/trains/1", train);
        cy.contains("Submit").click(); // Submit add items form
        cy.get("main div[class='alert alert-info']").contains(
            `2 items have been added to train ${train.train_id}.`
        );
    });
});
