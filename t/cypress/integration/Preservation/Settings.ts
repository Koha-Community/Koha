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
            processing_attribute_id: 1,
            processing_id: 1,
            name: "DB",
            type: "db_column",
            option_source: "biblio.title",
        },
        {
            processing_attribute_id: 1,
            processing_id: 1,
            name: "Height",
            type: "free_text",
            option_source: null,
        },
    ];
}
function get_processing() {
    return {
        name: "test processing",
        processing_id: 1,
        attributes: get_attributes(),
    };
}
describe("Processings", () => {
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
                ],
                category_name: "NOT_LOAN",
                is_integer_only: false,
                is_system: true,
            },
        ]);
    });

    it("Settings", () => {
        cy.visit("/cgi-bin/koha/preservation/home.pl");
        cy.get(".sidebar_menu").contains("Settings").click();
        cy.get("#not_for_loan_waiting_list_in .vs__selected").contains(
            "In preservation"
        );
        cy.get("#not_for_loan_default_train_in .vs__selected").contains(
            "In preservation external"
        );
    });
    it("List processing", () => {
        cy.intercept("GET", "/api/v1/preservation/processings*", []);
        cy.visit("/cgi-bin/koha/preservation/settings");
        cy.get("#processing_0").should("not.exist");
        cy.intercept("GET", "/api/v1/preservation/processings*", [
            get_processing(),
        ]);
        cy.visit("/cgi-bin/koha/preservation/settings");
        cy.get("#processing_0").should("exist");
    });

    it("Add processing", () => {
        cy.intercept("GET", "/api/v1/preservation/processings*", []);
        cy.visit("/cgi-bin/koha/preservation/settings");
        let processing = get_processing();
        cy.contains("Add new processing").click();
        cy.get("#processing_name").type(processing.name);
        cy.contains("Add new attribute").click();
        let attribute = processing.attributes[0];
        cy.get("#attribute_name_0").type(attribute.name);
        cy.get("#attribute_type_0 .vs__search").type("Authorized{enter}", {
            force: true,
        });
        cy.get("#attribute_option_0 .vs__search").type(
            attribute.option_source + "{enter}",
            { force: true }
        );
        cy.contains("Add new attribute").click();
        attribute = processing.attributes[1];
        cy.get("#attribute_name_1").type(attribute.name);
        cy.get("#attribute_type_1 .vs__search").type("Database{enter}", {
            force: true,
        });
        cy.get("#attribute_option_1 .vs__search").type(
            attribute.option_source + "{enter}",
            { force: true }
        );
        cy.contains("Add new attribute").click();
        attribute = processing.attributes[2];
        cy.get("#attribute_name_2").type(attribute.name);
        cy.get("#attribute_type_2 .vs__search").type("Free{enter}", {
            force: true,
        });

        // Submit the form, get 500
        cy.intercept("POST", "/api/v1/preservation/processings", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.get("#processings_add").contains("Submit").click();
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Submit the form, success!
        cy.intercept("POST", "/api/v1/preservation/processings", {
            statusCode: 201,
            body: processing,
        });
        cy.intercept("GET", "/api/v1/preservation/processings*", {
            statusCode: 200,
            body: [processing],
        });
        cy.get("#processings_add").contains("Submit").click();
        cy.get("main div[class='alert alert-info']").contains(
            "Processing created"
        );
        cy.get("#processing_0").contains(processing.name);
    });

    it("Edit processing", () => {
        let processing = get_processing();
        cy.intercept("GET", "/api/v1/preservation/processings/*", {
            statusCode: 200,
            body: processing,
        });
        cy.intercept("GET", "/api/v1/preservation/processings*", {
            statusCode: 200,
            body: [processing],
        });
        cy.visit("/cgi-bin/koha/preservation/settings");
        cy.get("#processing_0").contains(processing.name);
        cy.get("#processing_0").contains("Edit this processing").click();
        cy.get("#processing_name").should("have.value", processing.name);
        let attribute = processing.attributes[0];
        cy.get("#attribute_name_0").should("have.value", attribute.name);
        cy.get("#attribute_type_0 .vs__selected").contains("Authorized value");
        cy.get("#attribute_option_0 .vs__selected").contains(
            attribute.option_source
        );
        attribute = processing.attributes[1];
        cy.get("#attribute_name_1").should("have.value", attribute.name);
        cy.get("#attribute_type_1 .vs__selected").contains("Database column");
        cy.get("#attribute_option_1 .vs__selected").contains(
            attribute.option_source
        );
        attribute = processing.attributes[2];
        cy.get("#attribute_name_2").should("have.value", attribute.name);
        cy.get("#attribute_type_2 .vs__selected").contains("Free text");
        cy.get("#attribute_option_2").should("not.exist");

        // Submit the form, get 500
        cy.intercept("PUT", "/api/v1/preservation/processings/*", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.get("#processings_add").contains("Submit").click();
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Submit the form, success!
        cy.intercept("PUT", "/api/v1/preservation/processings/*", {
            statusCode: 200,
            body: processing,
        });
        cy.get("#processings_add").contains("Submit").click();
        cy.get("main div[class='alert alert-info']").contains(
            "Processing updated"
        );
    });

    it("Delete processing", () => {
        let processing = get_processing();
        cy.intercept("GET", "/api/v1/preservation/processings*", {
            statusCode: 200,
            body: [processing],
        });

        // Submit the form, get 500
        cy.intercept("DELETE", "/api/v1/preservation/processings/*", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.visit("/cgi-bin/koha/preservation/settings");
        cy.get("#processing_0").contains("Remove this processing").click();
        cy.contains("Yes, delete").click();
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Submit the form, success!
        cy.intercept("DELETE", "/api/v1/preservation/processings/*", {
            statusCode: 204,
            body: null,
        });
        cy.get("#processing_0").contains("Remove this processing").click();
        cy.contains("Yes, delete").click();
        cy.get("main div[class='alert alert-info']").contains(
            `Processing ${processing.name} deleted`
        );
    });
});
