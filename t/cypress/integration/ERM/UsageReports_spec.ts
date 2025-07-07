import { mount } from "@cypress/vue";

describe("Reports home tabs", () => {
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
        const defaultReport = cy.get_default_report();
        const defaulReports = [defaultReport];

        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 200,
            body: dataProviders,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/erm/default_usage_reports*", {
            statusCode: 200,
            body: defaulReports,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });

        cy.visit("/cgi-bin/koha/erm/eusage/reports");
    });

    it("Should display the saved reports page", () => {
        cy.get("#report_builder .default-report h2").should(
            "have.text",
            "Select saved report"
        );
    });

    it("Should display the custom report builder", () => {
        cy.get("#usage_data_providerstabs").contains("Create report").click();

        cy.get("#report-builder h2").should(
            "have.text",
            "Build a custom report"
        );
    });
});

describe("Saved reports", () => {
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
        const defaultReport = cy.get_default_report();
        const defaulReports = [defaultReport];

        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 200,
            body: dataProviders,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/erm/default_usage_reports*", {
            statusCode: 200,
            body: defaulReports,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });

        cy.visit("/cgi-bin/koha/erm/eusage/reports");
    });

    it("Should correctly populate the dropdown menu", () => {
        const defaultReport = cy.get_default_report();

        cy.get("#default_usage_reports .vs__open-indicator").click();
        cy.get("#default_usage_reports .vs__dropdown-menu li:first").should(
            "have.text",
            defaultReport.report_name
        );
    });

    it("Should redirect to the reports viewer with the correct url params", () => {
        const defaultReport = cy.get_default_report();

        cy.get("#default_usage_reports .vs__search").type(
            defaultReport.report_name + "{enter}",
            { force: true }
        );

        cy.get("#report_builder .default-report .action button")
            .contains("Submit")
            .click();

        cy.url({ decode: true }).then(url => {
            const urlParams = url.split("viewer?")[1].split("data=")[1];
            const reportParams = defaultReport.report_url_params;

            expect(urlParams).to.eq(reportParams);
        });
    });
});

describe("Custom reports", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.intercept(
            "GET",
            "/api/v1/erm/config",
            '{"settings":{"ERMModule":"1","ERMProviders":["local"]}}'
        );

        const dataProviders = cy.get_multiple_providers();
        const defaultReport = cy.get_default_report();
        const defaultReports = [defaultReport];

        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 200,
            body: dataProviders,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/erm/default_usage_reports*", {
            statusCode: 200,
            body: defaultReports,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });

        cy.visit("/cgi-bin/koha/erm/eusage/reports");
        cy.get("#usage_data_providerstabs").contains("Create report").click();
    });

    it("Should limit report types based on the provider(s) selected", () => {
        const dataProviders = cy.get_multiple_providers();
        cy.get("#report_type").find(".vs__actions").click();
        cy.get("#report_type").find("li").as("options");
        cy.get("@options").should("have.length", 16);

        cy.get("#usage_data_provider .vs__search").type(
            dataProviders[0].name + "{enter}",
            { force: true }
        );
        cy.get("#report_type").find(".vs__actions").click();
        cy.get("#report_type").find("li").as("options");
        cy.get("@options").should("have.length", 1);

        cy.get("#usage_data_provider .vs__search").type(
            dataProviders[1].name + "{enter}",
            { force: true }
        );
        cy.get("#report_type").find(".vs__actions").click();
        cy.get("#report_type").find("li").as("options");
        cy.get("@options").should("have.length", 3);
    });

    it("Should limit data providers based on the report type(s) selected", () => {
        cy.get("#usage_data_provider").find(".vs__actions").click();
        cy.get("#usage_data_provider").find("li").as("options");
        cy.get("@options").should("have.length", 2);

        cy.get("#report_type .vs__search").type("TR_J2" + "{enter}", {
            force: true,
        });
        cy.get("#usage_data_provider").find(".vs__actions").click();
        cy.get("#usage_data_provider").find("li").as("options");
        cy.get("@options").should("have.length", 1);

        cy.get("#report_type .vs__search").type("TR_J1" + "{enter}", {
            force: true,
        });
        cy.get("#usage_data_provider").find(".vs__actions").click();
        cy.get("#usage_data_provider").find("li").as("options");
        cy.get("@options").should("have.length", 2);
    });

    it("Should limit metric types based on the report type(s) selected", () => {
        cy.get("#metric_types .vs__search").should("be.disabled");

        cy.get("#report_type .vs__search").type("TR_J1" + "{enter}", {
            force: true,
        });
        cy.get("#metric_types").find(".vs__actions").click();
        cy.get("#metric_types").find("li").as("options");
        cy.get("@options").should("have.length", 2);

        cy.get("#report_type .vs__search").type("PR" + "{enter}", {
            force: true,
        });
        cy.get("#metric_types").find(".vs__actions").click();
        cy.get("#metric_types").find("li").as("options");
        cy.get("@options").should("have.length", 7);
    });

    it("Should allow access_type for certain report types", () => {
        cy.get("#access_types .vs__search").should("be.disabled");

        cy.get("#report_type .vs__search").type("TR_J1" + "{enter}", {
            force: true,
        });
        cy.get("#access_types").find(".vs__actions").click();
        cy.get("#access_types .vs__search").should("be.disabled");

        cy.get("#report_type .vs__search").type("TR_J3" + "{enter}", {
            force: true,
        });
        cy.get("#access_types").find(".vs__actions").click();
        cy.get("#access_types").find("li").as("options");
        cy.get("@options").should("have.length", 2);
    });

    it("Should disable the month selectors when a yearly report is selected", () => {
        cy.get("#interval .vs__search").type("By year" + "{enter}", {
            force: true,
        });

        cy.get("#start-month .vs__search").should("be.disabled");
        cy.get("#end_month .vs__search").should("be.disabled");
    });

    it("Should correctly allow columns to be selected depending on the report type", () => {
        // Only the Platform columns should be disabled for TR reports
        cy.get("#report_type .vs__search").type("TR_J1" + "{enter}", {
            force: true,
        });
        cy.get(".checkbox_options input:disabled").should("have.length", 1);

        // Only the Provider name and Platform columns should be enabled for PR reports
        cy.get("#report_type .vs__search").type("PR" + "{enter}", {
            force: true,
        });
        cy.get(".checkbox_options input:disabled").should("have.length", 6);

        // Only the Provider name, Publisher, Platform, Publisher ID columns should be enabled for DR reports
        cy.get("#report_type .vs__search").type("DR" + "{enter}", {
            force: true,
        });
        cy.get(".checkbox_options input:disabled").should("have.length", 4);

        // Only the Provider name, Publisher, Platform columns should be enabled for DR reports
        cy.get("#report_type .vs__search").type("IR" + "{enter}", {
            force: true,
        });
        cy.get(".checkbox_options input:disabled").should("have.length", 5);
    });

    it("Should correctly identify the months selected", () => {
        cy.get("#start_year").type("2022");
        cy.get("#start-month .vs__search").type("June" + "{enter}", {
            force: true,
        });
        cy.get("#end_year").type("2023");
        cy.get("#end_month .vs__search").type("April" + "{enter}", {
            force: true,
        });
        cy.get("#yearly_filter_required_no").click();
        cy.get(".month_labels").should("have.length", 11);
        cy.get("#yearly_filter_required_yes").click();
        cy.get(".month_labels").should("have.length", 0);
    });

    it("Should correctly produce URL parameters based on selected inputs", () => {
        cy.get("#start_year").type("2022");
        cy.get("#start-month .vs__search").type("June" + "{enter}", {
            force: true,
        });
        cy.get("#end_year").type("2023");
        cy.get("#end_month .vs__search").type("April" + "{enter}", {
            force: true,
        });

        cy.get("#report_type .vs__search").type("PR" + "{enter}", {
            force: true,
        });
        cy.get("#report_builder").contains("Submit").click();
        cy.url().should(
            "include",
            "data={%22url%22:%22/api/v1/erm/eUsage/monthly_report/platform?q=[{%5C%22erm_usage_muses.year%5C%22:2022,%5C%22erm_usage_muses.report_type%5C%22:%5C%22PR%5C%22,%5C%22erm_usage_muses.month%5C%22:[6,7,8,9,10,11,12],%5C%22erm_usage_muses.metric_type%5C%22:[%5C%22Searches_Platform%5C%22,%5C%22Total_Item_Investigations%5C%22,%5C%22Total_Item_Requests%5C%22,%5C%22Unique_Item_Investigations%5C%22,%5C%22Unique_Item_Requests%5C%22,%5C%22Unique_Title_Investigations%5C%22,%5C%22Unique_Title_Requests%5C%22]},{%5C%22erm_usage_muses.year%5C%22:2023,%5C%22erm_usage_muses.report_type%5C%22:%5C%22PR%5C%22,%5C%22erm_usage_muses.month%5C%22:[1,2,3,4],%5C%22erm_usage_muses.metric_type%5C%22:[%5C%22Searches_Platform%5C%22,%5C%22Total_Item_Investigations%5C%22,%5C%22Total_Item_Requests%5C%22,%5C%22Unique_Item_Investigations%5C%22,%5C%22Unique_Item_Requests%5C%22,%5C%22Unique_Title_Investigations%5C%22,%5C%22Unique_Title_Requests%5C%22]}]%22,%22columns%22:[1],%22queryObject%22:{%22data_display%22:%22monthly%22,%22report_type%22:%22PR%22,%22metric_types%22:[%22Searches_Platform%22,%22Total_Item_Investigations%22,%22Total_Item_Requests%22,%22Unique_Item_Investigations%22,%22Unique_Item_Requests%22,%22Unique_Title_Investigations%22,%22Unique_Title_Requests%22],%22access_types%22:null,%22usage_data_providers%22:null,%22keywords%22:null,%22start_month%22:6,%22start_year%22:%222022%22,%22end_month%22:4,%22end_year%22:%222023%22},%22yearly_filter%22:true,%22type%22:%22monthly%22,%22tp_columns%22:{%222022%22:[{%22short%22:%22Jun%22,%22description%22:%22June%22,%22value%22:6,%22active%22:true},{%22short%22:%22Jul%22,%22description%22:%22July%22,%22value%22:7,%22active%22:true},{%22short%22:%22Aug%22,%22description%22:%22August%22,%22value%22:8,%22active%22:true},{%22short%22:%22Sep%22,%22description%22:%22September%22,%22value%22:9,%22active%22:true},{%22short%22:%22Oct%22,%22description%22:%22October%22,%22value%22:10,%22active%22:true},{%22short%22:%22Nov%22,%22description%22:%22November%22,%22value%22:11,%22active%22:true},{%22short%22:%22Dec%22,%22description%22:%22December%22,%22value%22:12,%22active%22:true}],%222023%22:[{%22short%22:%22Jan%22,%22description%22:%22January%22,%22value%22:1,%22active%22:true},{%22short%22:%22Feb%22,%22description%22:%22February%22,%22value%22:2,%22active%22:true},{%22short%22:%22Mar%22,%22description%22:%22March%22,%22value%22:3,%22active%22:true},{%22short%22:%22Apr%22,%22description%22:%22April%22,%22value%22:4,%22active%22:true}]}}"
        );
    });

    it("Should show the Display by year filter when filter is required", () => {
        cy.get("#start_year").type("2022");
        cy.get("#start-month .vs__search").type("June" + "{enter}", {
            force: true,
        });
        cy.get("#end_year").type("2023");
        cy.get("#end_month .vs__search").type("April" + "{enter}", {
            force: true,
        });

        cy.get("#report_type .vs__search").type("PR" + "{enter}", {
            force: true,
        });
        cy.get("#report_builder").contains("Submit").click();
        cy.intercept("GET", "/api/v1/erm/eUsage/monthly_report/*").as(
            "reportRequest"
        );
        cy.wait("@reportRequest");

        cy.get(".yearly_filter label").contains("Display by year");
        // There should be two years - 2022 and 2023 as per the inputs above
        cy.get("#year_select").find(".vs__actions").click();
        cy.get("#year_select").find("li").as("options");
        cy.get("@options").should("have.length", 2);

        // Changing the year should re-trigger the AJAX request for that year
        cy.intercept("GET", "/api/v1/erm/eUsage/monthly_report/*").as(
            "filterRequest2022"
        );
        cy.get("#year_select .vs__search").type("2022" + "{enter}", {
            force: true,
        });
        cy.get("#filter_table").click();
        cy.wait("@filterRequest2022")
            .its("request.query.q")
            .should("include", "2022");

        cy.intercept("GET", "/api/v1/erm/eUsage/monthly_report/*").as(
            "filterRequest2023"
        );
        cy.get("#year_select .vs__search").type("2023" + "{enter}", {
            force: true,
        });
        cy.get("#filter_table").click();
        cy.wait("@filterRequest2023")
            .its("request.query.q")
            .should("include", "2023");
    });
});
