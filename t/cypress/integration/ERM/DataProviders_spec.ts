import { mount } from "@cypress/vue";
import { data } from "cypress/types/jquery";

const dayjs = require("dayjs");

const dates = {
    today_iso: dayjs().format("YYYY-MM-DD"),
    today_us: dayjs().format("MM/DD/YYYY"),
    tomorrow_iso: dayjs().add(1, "day").format("YYYY-MM-DD"),
    tomorrow_us: dayjs().add(1, "day").format("MM/DD/YYYY"),
};

describe("Data provider CRUD operations", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.intercept(
            "GET",
            "/api/v1/erm/config",
            '{"settings":{"ERMModule":"1","ERMProviders":["local"]}}'
        );
    });

    it("Should list providers", () => {
        // GET usage_data_providers returns 500
        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.visit("/cgi-bin/koha/erm/erm.pl");
        cy.get(".sidebar_menu").contains("Data providers").click();
        cy.get("main div[class='alert alert-warning']").contains(
            /Something went wrong/
        );

        // GET usage_data_providers returns empty list
        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", []);
        cy.visit("/cgi-bin/koha/erm/eusage/usage_data_providers");
        cy.get("#usage_data_providers_list").contains(
            "There are no usage data providers defined"
        );

        const dataProvider = cy.get_usage_data_provider();
        const dataProviders = [dataProvider];

        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 200,
            body: dataProviders,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.visit("/cgi-bin/koha/erm/eusage/usage_data_providers");
        cy.get("#usage_data_providers_list").contains(
            "Showing 1 to 1 of 1 entries"
        );
    });

    it("Should add provider", () => {
        cy.visit("/cgi-bin/koha/erm/eusage/usage_data_providers");
        cy.contains("New data provider").click();
        cy.get("#data_providers_add h2").contains("New usage data provider");

        const dataProvider = cy.get_usage_data_provider();
        const registryProvider = cy.getCounterRegistryProvider();
        const sushiService = cy.getSushiService();

        cy.get("#data_providers_add").contains("Submit").click();
        cy.get("input:invalid,textarea:invalid,select:invalid").should(
            "have.length",
            1
        );

        cy.intercept(
            "GET",
            "api/v1/erm/counter_registry?*",
            registryProvider
        ).as("get-registry-provider");
        cy.intercept("GET", "api/v1/erm/sushi_service?*", sushiService).as(
            "get-sushi-service"
        );

        // Fill in text inputs

        cy.get("#usage_data_provider_name .vs__search").type(
            dataProvider.name + "{enter}",
            { force: true }
        );
        cy.wait("@get-registry-provider");
        cy.wait("@get-sushi-service");

        cy.get("#usage_data_provider_description").type(
            dataProvider.description
        );
        cy.get("#usage_data_provider_service_type").type(
            dataProvider.service_type
        );
        cy.get("#usage_data_provider_service_url").should(
            "have.value",
            "https://onlinelibrary.wiley.com/reports/"
        );
        cy.get("#usage_data_provider_report_release").should("have.value", "5");
        cy.get("#usage_data_provider_customer_id").type(
            dataProvider.customer_id
        );
        cy.get("#usage_data_provider_requestor_id").type(
            dataProvider.requestor_id
        );
        cy.get("#usage_data_provider_api_key").type(dataProvider.api_key);
        cy.get("#usage_data_provider_requestor_name").type(
            dataProvider.requestor_name
        );
        cy.get("#usage_data_provider_requestor_email").type(
            dataProvider.requestor_email
        );

        cy.get("#data_providers_add").contains("Submit").click();
        cy.get("input:invalid,textarea:invalid,select:invalid").should(
            "have.length",
            1
        );

        // Fill in status and report types
        cy.get("#harvester_status .vs__search").type(
            dataProvider.active + "{enter}",
            { force: true }
        );
        cy.get("#report_type .vs__search").type(
            dataProvider.report_types.slice(0, -1) + "{enter}",
            { force: true }
        );

        // // Submit the form, get 500
        // cy.intercept("POST", "/api/v1/erm/usage_data_providers", {
        //     statusCode: 500,
        //     error: "Something went wrong",
        // });
        // cy.get("#data_providers_add").contains("Submit").click();
        // cy.get("main div[class='alert alert-warning']").contains(
        //     "Something went wrong: Error: Internal Server Error"
        // );

        // Submit the form, success!
        cy.intercept("POST", "/api/v1/erm/usage_data_providers", {
            statusCode: 201,
            body: dataProvider,
        });
        cy.get("#data_providers_add").contains("Submit").click();
        cy.get("main div[class='alert alert-info']").contains(
            "Data provider created"
        );

        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 200,
            body: [dataProvider],
        });
    });

    it("Should edit provider", () => {
        const dataProvider = cy.get_usage_data_provider();
        const dataProviders = [dataProvider];

        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 200,
            body: dataProviders,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("get-data-providers");
        cy.intercept(
            "GET",
            "/api/v1/erm/usage_data_providers/*",
            dataProvider
        ).as("get-data-provider");

        const registryProvider = cy.getCounterRegistryProvider();
        const sushiService = cy.getSushiService();

        cy.intercept(
            "GET",
            "api/v1/erm/counter_registry?*",
            registryProvider
        ).as("get-registry-provider");
        cy.intercept("GET", "api/v1/erm/sushi_service?*", sushiService).as(
            "get-sushi-service"
        );

        cy.visit("/cgi-bin/koha/erm/eusage/usage_data_providers");
        cy.wait("@get-data-providers");
        cy.get("#usage_data_providers_list table tbody tr:first")
            .contains("Edit")
            .click();
        cy.wait("@get-data-provider");
        cy.get("#data_providers_add h2").contains("Edit usage data provider");

        // Form has been correctly filled in
        cy.get(
            "#usage_data_provider_name.v-select.vs--single.vs--searchable"
        ).contains("Wiley Online Library");
        cy.get("#usage_data_provider_description").should(
            "have.value",
            dataProvider.description
        );
        cy.get("#usage_data_provider_service_type").should(
            "have.value",
            dataProvider.service_type
        );
        cy.get("#usage_data_provider_service_url").should(
            "have.value",
            dataProvider.service_url
        );
        cy.get("#usage_data_provider_report_release").should(
            "have.value",
            dataProvider.report_release
        );
        cy.get("#usage_data_provider_customer_id").should(
            "have.value",
            dataProvider.customer_id
        );
        cy.get("#usage_data_provider_requestor_id").should(
            "have.value",
            dataProvider.requestor_id
        );
        cy.get("#usage_data_provider_api_key").should(
            "have.value",
            dataProvider.api_key
        );
        cy.get("#usage_data_provider_requestor_name").should(
            "have.value",
            dataProvider.requestor_name
        );
        cy.get("#usage_data_provider_requestor_email").should(
            "have.value",
            dataProvider.requestor_email
        );

        cy.get("#harvester_status .vs__selected").contains("Active");
        cy.get("#report_type .vs__selected").contains("TR_J1");

        // // Submit the form, get 500
        // cy.intercept("PUT", "/api/v1/erm/usage_data_providers/*", {
        //     statusCode: 500,
        //     error: "Something went wrong",
        // });
        // cy.get("#data_providers_add").contains("Submit").click();
        // cy.get("main div[class='alert alert-warning']").contains(
        //     "Something went wrong: Error: Internal Server Error"
        // );
        // Submit the form, success!
        cy.intercept("PUT", "/api/v1/erm/usage_data_providers/*", {
            statusCode: 200,
            body: dataProvider,
        });
        cy.get("#data_providers_add").contains("Submit").click();
        cy.get("main div[class='alert alert-info']").contains(
            "Data provider updated"
        );
    });

    it("Should show provider", () => {
        const dataProvider = cy.get_usage_data_provider();
        const dataProviders = [dataProvider];

        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 200,
            body: dataProviders,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("get-providers");
        cy.intercept(
            "GET",
            "/api/v1/erm/usage_data_providers/*",
            dataProvider
        ).as("get-data-provider");
        cy.visit("/cgi-bin/koha/erm/eusage/usage_data_providers");
        cy.wait("@get-providers");
        let name_link = cy.get(
            "#usage_data_providers_list table tbody tr:first td:first a"
        );
        name_link.should(
            "have.text",
            dataProvider.name +
                " (#" +
                dataProvider.erm_usage_data_provider_id +
                ")"
        );
        name_link.click();
        cy.wait("@get-data-provider");
        cy.get("#usage_data_providers_show h2").contains(
            "Data provider #" + dataProvider.erm_usage_data_provider_id
        );
    });

    it("Should delete provider", () => {
        const dataProvider = cy.get_usage_data_provider();
        const dataProviders = [dataProvider];

        // Click the 'Delete' button from the list
        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 200,
            body: dataProviders,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept(
            "GET",
            "/api/v1/erm/usage_data_providers/*",
            dataProvider
        ).as("get-data-provider");
        cy.visit("/cgi-bin/koha/erm/eusage/usage_data_providers");

        cy.get("#usage_data_providers_list table tbody tr:first")
            .contains("Delete")
            .click();
        cy.get(".alert-warning.confirmation h1").contains(
            "remove this data provider"
        );
        cy.contains(dataProvider.name);

        // // Accept the confirmation dialog, get 500
        // cy.intercept("DELETE", "/api/v1/erm/usage_data_providers/*", {
        //     statusCode: 500,
        //     error: "Something went wrong",
        // });
        // cy.contains("Yes, delete").click();
        // cy.get("main div[class='alert alert-warning']").contains(
        //     "Something went wrong: Error: Internal Server Error"
        // );

        // // Accept the confirmation dialog, success!
        cy.intercept("DELETE", "/api/v1/erm/usage_data_providers/*", {
            statusCode: 204,
            body: null,
        });
        // cy.get("#usage_data_providers_list table tbody tr:first")
        //     .contains("Delete")
        //     .click();
        // cy.get(".alert-warning.confirmation h1").contains(
        //     "remove this data provider"
        // );
        cy.contains("Yes, delete").click();
        cy.get("main div[class='alert alert-info']")
            .contains("Data provider")
            .contains("deleted");

        // Delete from show
        // Click the "name" link from the list
        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 200,
            body: dataProviders,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("get-data-providers");
        cy.intercept(
            "GET",
            "/api/v1/erm/usage_data_providers/*",
            dataProvider
        ).as("get-data-provider");
        cy.visit("/cgi-bin/koha/erm/eusage/usage_data_providers");
        cy.wait("@get-data-providers");
        let name_link = cy.get(
            "#usage_data_providers_list table tbody tr:first td:first a"
        );
        name_link.should(
            "have.text",
            dataProvider.name +
                " (#" +
                dataProvider.erm_usage_data_provider_id +
                ")"
        );
        name_link.click();
        cy.wait("@get-data-provider");
        cy.get("#usage_data_providers_show h2").contains(
            "Data provider #" + dataProvider.erm_usage_data_provider_id
        );

        cy.get("#usage_data_providers_show #toolbar")
            .contains("Delete")
            .click();
        cy.get(".alert-warning.confirmation h1").contains(
            "remove this data provider"
        );
        cy.contains("Yes, delete").click();

        //Make sure we return to list after deleting from show
        cy.get("#usage_data_providers_list");
    });
});

describe("Data providers summary", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.intercept(
            "GET",
            "/api/v1/erm/config",
            '{"settings":{"ERMModule":"1","ERMProviders":["local"]}}'
        );
    });

    it("Should navigate to the summary page and back to providers list", () => {
        const dataProvider = cy.get_usage_data_provider();
        const dataProviders = [dataProvider];

        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 200,
            body: dataProviders,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.visit("/cgi-bin/koha/erm/eusage/usage_data_providers");

        cy.contains("Data providers summary").click();
        cy.get("#usage_data_providers_summary").contains(
            "Showing 1 to 1 of 1 entries"
        );

        cy.contains("Data providers list").click();
        cy.get("#usage_data_providers_list").contains(
            "Showing 1 to 1 of 1 entries"
        );
    });

    it("Should correctly display dates", () => {
        const dataProvider = cy.get_usage_data_provider();
        const dataProviders = [dataProvider];

        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 200,
            body: dataProviders,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.visit("/cgi-bin/koha/erm/eusage/usage_data_providers");

        cy.contains("Data providers summary").click();

        // Check provider name
        cy.get(
            "#usage_data_providers_summary table tbody tr:first td:first"
        ).should("have.text", dataProvider.name);

        // Check start and end dates
        cy.get(
            "#usage_data_providers_summary table tbody tr:first td:nth-child(2)"
        ).should("have.text", "2023-01-01");
        cy.get(
            "#usage_data_providers_summary table tbody tr:first td:nth-child(3)"
        ).should("have.text", "2023-01-01");
        cy.get(
            "#usage_data_providers_summary table tbody tr:first td:nth-child(4)"
        ).should("have.text", "2023-01-01");
        cy.get(
            "#usage_data_providers_summary table tbody tr:first td:nth-child(5)"
        ).should("have.text", "2023-01-01");
        cy.get(
            "#usage_data_providers_summary table tbody tr:first td:nth-child(6)"
        ).should("have.text", "N/A");
        cy.get(
            "#usage_data_providers_summary table tbody tr:first td:nth-child(7)"
        ).should("have.text", "N/A");
        cy.get(
            "#usage_data_providers_summary table tbody tr:first td:nth-child(8)"
        ).should("have.text", "N/A");
        cy.get(
            "#usage_data_providers_summary table tbody tr:first td:nth-child(9)"
        ).should("have.text", "N/A");
    });
});

describe("Data provider tab options", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.intercept(
            "GET",
            "/api/v1/erm/config",
            '{"settings":{"ERMModule":"1","ERMProviders":["local"]}}'
        );

        const dataProvider = cy.get_usage_data_provider();
        const dataProviders = [dataProvider];

        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 200,
            body: dataProviders,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("get-data-providers");
        cy.intercept(
            "GET",
            "/api/v1/erm/usage_data_providers/*",
            dataProvider
        ).as("get-data-provider");
        cy.visit("/cgi-bin/koha/erm/eusage/usage_data_providers");
        cy.wait("@get-data-providers");
        let name_link = cy.get(
            "#usage_data_providers_list table tbody tr:first td:first a"
        );
        name_link.should(
            "have.text",
            dataProvider.name +
                " (#" +
                dataProvider.erm_usage_data_provider_id +
                ")"
        );
        name_link.click();
        cy.wait("@get-data-provider");
    });

    it("Should display provider details", () => {
        const dataProvider = cy.get_usage_data_provider();
        const dataProviders = [dataProvider];

        cy.get(
            "#usage_data_providers_show > div.tab-content > div > legend:nth-child(1)"
        ).should("have.text", "Data provider");

        //Page should be populated correctly
        cy.get("#usage_data_provider_name").should(
            "have.text",
            dataProvider.name
        );
        cy.get("#usage_data_provider_description").should(
            "have.text",
            dataProvider.description
        );
        cy.get("#usage_data_provider_service_type").should(
            "have.text",
            dataProvider.service_type
        );
        cy.get("#usage_data_provider_service_url").should(
            "have.text",
            dataProvider.service_url
        );
        cy.get("#usage_data_provider_report_release").should(
            "have.text",
            dataProvider.report_release
        );
        cy.get("#usage_data_provider_customer_id").should(
            "have.text",
            dataProvider.customer_id
        );
        cy.get("#usage_data_provider_requestor_id").should(
            "have.text",
            dataProvider.requestor_id
        );
        cy.get("#usage_data_provider_api_key").should(
            "have.text",
            dataProvider.api_key
        );
        cy.get("#usage_data_provider_requestor_name").should(
            "have.text",
            dataProvider.requestor_name
        );
        cy.get("#usage_data_provider_requestor_email").should(
            "have.text",
            dataProvider.requestor_email
        );
        cy.get("#harvester_status").should(
            "have.text",
            dataProvider.active ? "Active" : "Inactive"
        );
        cy.get("#report_type").should("have.text", dataProvider.report_types);
    });

    it("Should display data on the data tabs", () => {
        cy.intercept("GET", "/api/v1/erm/usage_titles*", {
            statusCode: 200,
            body: [],
            headers: {
                "X-Base-Total-Count": "0",
                "X-Total-Count": "0",
            },
        }).as("no-titles");

        // We'll test using titles but the component is the same for all four data types
        cy.get("#usage_data_providerstabs").contains("Titles").click();
        cy.wait("@no-titles");
        cy.get("main div[class='alert alert-info']").should(
            "have.text",
            "No title data has been harvested for this provider"
        );

        cy.get("#usage_data_providerstabs").contains("Detail").click();

        const title = cy.get_usage_title();
        const titles = [title];
        cy.intercept("GET", "/api/v1/erm/usage_titles?*", {
            statusCode: 200,
            body: titles,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("provider-titles");

        cy.get("#usage_data_providerstabs").contains("Titles").click();
        cy.wait(["@provider-titles", "@provider-titles"]);
        cy.get("#data_list").contains("Showing 1 to 1 of 1 entries");
    });

    it("Should allow manual file upload", () => {
        cy.get("#usage_data_providerstabs").contains("Manual upload").click();
        cy.get("#files h2").should("have.text", "Manual upload:");

        cy.get("#import_file").click();
        cy.get("#import_file").selectFile("t/cypress/fixtures/file.json");
        cy.get("#files .file_information span").contains("file.json");

        cy.intercept(
            "POST",
            "/api/v1/erm/usage_data_providers/1/process_COUNTER_file*",
            {
                statusCode: 200,
                body: {
                    jobs: [
                        {
                            job_id: 1,
                        },
                    ],
                },
            }
        );

        cy.get("#files > form > fieldset > button").click();

        cy.get("main div[class='alert alert-info']").should(
            "have.text",
            "Job for uploaded file has been queued. Check job progress."
        );
    });

    it("Should display import logs", () => {
        cy.intercept("GET", "/api/v1/erm/counter_files*", {
            statusCode: 200,
            body: [],
            headers: {
                "X-Base-Total-Count": "0",
                "X-Total-Count": "0",
            },
        });
        cy.get("#usage_data_providerstabs").contains("Import logs").click();
        cy.get("main div[class='alert alert-info']").should(
            "have.text",
            "There are no import logs defined"
        );

        cy.get("#usage_data_providerstabs").contains("Detail").click();

        const counter_file = cy.get_counter_file();
        const counter_files = [counter_file];
        cy.intercept("GET", "/api/v1/erm/counter_files*", {
            statusCode: 200,
            body: counter_files,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/erm/counter_logs*", {
            statusCode: 200,
            body: counter_file.counter_logs,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });

        cy.get("#usage_data_providerstabs").contains("Import logs").click();
        cy.get("#counter_logs_list").contains("Showing 1 to 1 of 1 entries");

        // Check 'Imported by' name
        cy.get("#counter_logs_list table tbody tr:first td")
            .eq(2)
            .contains("koha");
    });
});

describe("Data providers action buttons", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.intercept(
            "GET",
            "/api/v1/erm/config",
            '{"settings":{"ERMModule":"1","ERMProviders":["local"]}}'
        );
    });

    it("Should queue a harvest background job", () => {
        const dataProvider = cy.get_usage_data_provider();
        const dataProviders = [dataProvider];

        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 200,
            body: dataProviders,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/erm/usage_data_providers/*", dataProvider);
        cy.visit("/cgi-bin/koha/erm/eusage/usage_data_providers");

        cy.get("#usage_data_providers_list table tbody tr:first")
            .contains("Run now")
            .click();
        cy.get(".modal.confirmation p").contains(dataProvider.name);
        cy.get("body").click(0, 0);

        cy.get("#usage_data_providers_list table tbody tr:first")
            .contains("Run now")
            .click();

        cy.intercept(
            "POST",
            "/api/v1/erm/usage_data_providers/1/process_SUSHI_response*",
            {
                statusCode: 200,
                body: {
                    jobs: [
                        {
                            report_type: "TR_J1",
                            job_id: 1,
                        },
                    ],
                },
                headers: {
                    "X-Base-Total-Count": "1",
                    "X-Total-Count": "1",
                },
            }
        );
        cy.get("#begin_date+input").click();
        cy.get(".flatpickr-current-month select")
            .invoke("val")
            .then(month => {
                cy.get(".flatpickr-current-month > select > option").eq(0);
                cy.get(".dayContainer").contains(new RegExp("^1$")).click();
            });
        cy.get("#accept_modal").click();
        cy.get("main div[class='alert alert-info']").should(
            "have.text",
            "Job for report type TR_J1 has been queued. Check job progress."
        );
    });

    it("Should test a provider's SUSHI connection", () => {
        const dataProvider = cy.get_usage_data_provider();
        const dataProviders = [dataProvider];

        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 200,
            body: dataProviders,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/erm/usage_data_providers/*", dataProvider);
        cy.visit("/cgi-bin/koha/erm/eusage/usage_data_providers");

        cy.intercept(
            "GET",
            "/api/v1/erm/usage_data_providers/1/test_connection",
            {
                statusCode: 200,
                body: 1,
                headers: {
                    "X-Base-Total-Count": "1",
                    "X-Total-Count": "1",
                },
            }
        ).as("test-connection");
        cy.get("#usage_data_providers_list table tbody tr:first")
            .contains("Test")
            .click();
        cy.wait("@test-connection");
        cy.get("main div[class='alert alert-info']").should(
            "have.text",
            "Harvester connection was successful for usage data provider " +
                dataProvider.name
        );
    });
});
