describe("ERM Module Dashboard", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.intercept(
            "GET",
            "/api/v1/erm/config",
            '{"settings":{"ERMModule":"1","ERMProviders":["local"]}}'
        );
    });

    it("Counts", () => {
        cy.intercept("GET", "/api/v1/erm/counts", {
            counts: {
                agreements_count: 1,
                documents_count: 0,
                eholdings_packages_count: 0,
                eholdings_titles_count: 0,
                licenses_count: 5,
                usage_data_providers_count: 1,
            },
        }).as("getCounts");
        cy.visit("/cgi-bin/koha/erm/erm.pl");

        //Display
        cy.get(".widget#ERMCounts .widget-content").should(
            "contain",
            "Loading..."
        );
        cy.wait("@getCounts");
        cy.get(".widget#ERMCounts .widget-content").contains(
            "There are 1 agreement, 5 licenses, 0 documents, 0 local packages, 0 local titles, 1 usage data provider."
        );

        //Move
        cy.get(
            ".dashboard-left-col .widget#ERMCounts .widget-header #dropdownMenuButton"
        ).click();
        cy.get(
            ".dashboard-left-col .widget#ERMCounts .widget-header .move-right"
        ).click();
        cy.get(".dashboard-left-col .widget#ERMCounts").should("not.exist");
        cy.get(".dashboard-right-col .dragArea")
            .children()
            .first()
            .should("have.id", "ERMCounts");

        //Remove
        cy.get(
            ".dashboard-right-col .widget#ERMCounts .widget-header #dropdownMenuButton"
        ).click();
        cy.get(
            ".dashboard-right-col .widget#ERMCounts .widget-header .remove-widget"
        ).click();
        cy.get(".dashboard-right-col .widget#ERMCounts").should("not.exist");

        //Add
        cy.get("#dashboard-header #open-widget-picker").click();
        cy.get(".modal #ERMCounts .add-widget").click();
        cy.get(".modal .modal-footer button").contains("Close").click();
        cy.get(".dashboard-left-col .dragArea")
            .children()
            .first()
            .should("have.id", "ERMCounts");
    });

    it("Run eUsage report", () => {
        cy.intercept("GET", "/api/v1/erm/default_usage_reports", []).as(
            "getReports"
        );
        cy.visit("/cgi-bin/koha/erm/erm.pl");

        //Display
        cy.get(".widget#ERMRunUsageReport .widget-content").should(
            "contain",
            "Loading..."
        );
        cy.wait("@getReports");
        cy.get(".widget#ERMRunUsageReport .widget-content").should(
            "contain",
            "No saved eUsage reports are available to run."
        );
        cy.get(".widget#ERMRunUsageReport .widget-content")
            .find("a")
            .should("have.attr", "href", "/cgi-bin/koha/erm/eusage/reports")
            .contains("Create a report");

        let reports = [
            {
                erm_default_usage_report_id: 3,
                report_name: "new",
                report_url_params:
                    '{"url":"/api/v1/erm/eUsage/monthly_report/database?q=[{\\"erm_usage_muses.year\\":2020,\\"erm_usage_muses.report_type\\":\\"DR\\",\\"erm_usage_muses.month\\":[1,2,3,4,5,6,7,8,9,10,11,12],\\"erm_usage_muses.metric_type\\":[\\"Searches_Automated\\",\\"Searches_Federated\\",\\"Searches_Regular\\",\\"Total_Item_Investigations\\",\\"Total_Item_Requests\\",\\"Unique_Item_Investigations\\",\\"Unique_Item_Requests\\",\\"Unique_Title_Investigations\\",\\"Unique_Title_Requests\\",\\"Limit_Exceeded\\",\\"No_License\\"]},{\\"erm_usage_muses.year\\":2021,\\"erm_usage_muses.report_type\\":\\"DR\\",\\"erm_usage_muses.month\\":[1,2,3,4,5,6,7,8,9,10,11,12],\\"erm_usage_muses.metric_type\\":[\\"Searches_Automated\\",\\"Searches_Federated\\",\\"Searches_Regular\\",\\"Total_Item_Investigations\\",\\"Total_Item_Requests\\",\\"Unique_Item_Investigations\\",\\"Unique_Item_Requests\\",\\"Unique_Title_Investigations\\",\\"Unique_Title_Requests\\",\\"Limit_Exceeded\\",\\"No_License\\"]},{\\"erm_usage_muses.year\\":2022,\\"erm_usage_muses.report_type\\":\\"DR\\",\\"erm_usage_muses.month\\":[1,2,3,4,5,6,7,8,9,10,11,12],\\"erm_usage_muses.metric_type\\":[\\"Searches_Automated\\",\\"Searches_Federated\\",\\"Searches_Regular\\",\\"Total_Item_Investigations\\",\\"Total_Item_Requests\\",\\"Unique_Item_Investigations\\",\\"Unique_Item_Requests\\",\\"Unique_Title_Investigations\\",\\"Unique_Title_Requests\\",\\"Limit_Exceeded\\",\\"No_License\\"]},{\\"erm_usage_muses.year\\":2023,\\"erm_usage_muses.report_type\\":\\"DR\\",\\"erm_usage_muses.month\\":[1,2,3,4,5,6,7,8,9,10,11,12],\\"erm_usage_muses.metric_type\\":[\\"Searches_Automated\\",\\"Searches_Federated\\",\\"Searches_Regular\\",\\"Total_Item_Investigations\\",\\"Total_Item_Requests\\",\\"Unique_Item_Investigations\\",\\"Unique_Item_Requests\\",\\"Unique_Title_Investigations\\",\\"Unique_Title_Requests\\",\\"Limit_Exceeded\\",\\"No_License\\"]}]","columns":[1],"queryObject":{"data_display":"monthly","report_type":"DR","metric_types":["Searches_Automated","Searches_Federated","Searches_Regular","Total_Item_Investigations","Total_Item_Requests","Unique_Item_Investigations","Unique_Item_Requests","Unique_Title_Investigations","Unique_Title_Requests","Limit_Exceeded","No_License"],"access_types":null,"usage_data_providers":null,"keywords":null,"start_month":null,"start_year":"2020","end_month":null,"end_year":"2023"},"yearly_filter":true,"type":"monthly","tp_columns":{"2020":[{"short":"Jan","description":"January","value":1,"active":true},{"short":"Feb","description":"February","value":2,"active":true},{"short":"Mar","description":"March","value":3,"active":true},{"short":"Apr","description":"April","value":4,"active":true},{"short":"May","description":"May","value":5,"active":true},{"short":"Jun","description":"June","value":6,"active":true},{"short":"Jul","description":"July","value":7,"active":true},{"short":"Aug","description":"August","value":8,"active":true},{"short":"Sep","description":"September","value":9,"active":true},{"short":"Oct","description":"October","value":10,"active":true},{"short":"Nov","description":"November","value":11,"active":true},{"short":"Dec","description":"December","value":12,"active":true}],"2021":[{"short":"Jan","description":"January","value":1,"active":true},{"short":"Feb","description":"February","value":2,"active":true},{"short":"Mar","description":"March","value":3,"active":true},{"short":"Apr","description":"April","value":4,"active":true},{"short":"May","description":"May","value":5,"active":true},{"short":"Jun","description":"June","value":6,"active":true},{"short":"Jul","description":"July","value":7,"active":true},{"short":"Aug","description":"August","value":8,"active":true},{"short":"Sep","description":"September","value":9,"active":true},{"short":"Oct","description":"October","value":10,"active":true},{"short":"Nov","description":"November","value":11,"active":true},{"short":"Dec","description":"December","value":12,"active":true}],"2022":[{"short":"Jan","description":"January","value":1,"active":true},{"short":"Feb","description":"February","value":2,"active":true},{"short":"Mar","description":"March","value":3,"active":true},{"short":"Apr","description":"April","value":4,"active":true},{"short":"May","description":"May","value":5,"active":true},{"short":"Jun","description":"June","value":6,"active":true},{"short":"Jul","description":"July","value":7,"active":true},{"short":"Aug","description":"August","value":8,"active":true},{"short":"Sep","description":"September","value":9,"active":true},{"short":"Oct","description":"October","value":10,"active":true},{"short":"Nov","description":"November","value":11,"active":true},{"short":"Dec","description":"December","value":12,"active":true}],"2023":[{"short":"Jan","description":"January","value":1,"active":true},{"short":"Feb","description":"February","value":2,"active":true},{"short":"Mar","description":"March","value":3,"active":true},{"short":"Apr","description":"April","value":4,"active":true},{"short":"May","description":"May","value":5,"active":true},{"short":"Jun","description":"June","value":6,"active":true},{"short":"Jul","description":"July","value":7,"active":true},{"short":"Aug","description":"August","value":8,"active":true},{"short":"Sep","description":"September","value":9,"active":true},{"short":"Oct","description":"October","value":10,"active":true},{"short":"Nov","description":"November","value":11,"active":true},{"short":"Dec","description":"December","value":12,"active":true}]}}',
            },
        ];

        cy.intercept("GET", "/api/v1/erm/default_usage_reports", reports).as(
            "getReports"
        );
        cy.visit("/cgi-bin/koha/erm/erm.pl");

        cy.get(".widget#ERMRunUsageReport .widget-content")
            .find(".v-select")
            .should("exist");
        cy.get(".widget#ERMRunUsageReport .widget-content")
            .find("button")
            .contains("Run")
            .should("be.disabled");
        cy.get(".widget#ERMRunUsageReport .widget-content .vs__search").type(
            "new{enter}",
            { force: true }
        );
        cy.get(
            ".widget#ERMRunUsageReport .widget-content .vs__selected"
        ).contains("new");
        cy.get(".widget#ERMRunUsageReport .widget-content")
            .find("button")
            .contains("Run")
            .should("not.be.disabled");
        cy.get(
            ".widget#ERMRunUsageReport .widget-content button.btn-primary"
        ).click();
        cy.url().should("match", /erm\/eusage\/reports\/viewer/);

        cy.intercept("GET", "/api/v1/erm/default_usage_reports", reports);
        cy.visit("/cgi-bin/koha/erm/erm.pl");

        //Move
        cy.get(
            ".dashboard-left-col .widget#ERMRunUsageReport .widget-header #dropdownMenuButton"
        ).click();
        cy.get(
            ".dashboard-left-col .widget#ERMRunUsageReport .widget-header .move-right"
        ).click();
        cy.get(".dashboard-left-col .widget#ERMRunUsageReport").should(
            "not.exist"
        );
        cy.get(".dashboard-right-col .dragArea")
            .children()
            .first()
            .should("have.id", "ERMRunUsageReport");

        //Remove
        cy.get(
            ".dashboard-right-col .widget#ERMRunUsageReport .widget-header #dropdownMenuButton"
        ).click();
        cy.get(
            ".dashboard-right-col .widget#ERMRunUsageReport .widget-header .remove-widget"
        ).click();
        cy.get(".dashboard-right-col .widget#ERMRunUsageReport").should(
            "not.exist"
        );

        //Add
        cy.get("#dashboard-header #open-widget-picker").click();
        cy.get(".modal #ERMRunUsageReport .add-widget").click();
        cy.get(".modal .modal-footer button").contains("Close").click();
        cy.get(".dashboard-left-col .dragArea")
            .children()
            .first()
            .should("have.id", "ERMRunUsageReport");
    });

    it("Licenses needing action", () => {
        cy.intercept("GET", "/api/v1/erm/licenses*", [cy.get_license()]).as(
            "getLicenses"
        );
        cy.visit("/cgi-bin/koha/erm/erm.pl");

        //Display
        cy.get(".widget#ERMLicensesNeedingAction .widget-content").should(
            "contain",
            "Loading..."
        );
        cy.wait("@getLicenses");
        cy.get(
            ".widget#ERMLicensesNeedingAction .widget-content table tbody tr:first"
        ).contains("license 1");

        //Settings
        cy.get(".widget#ERMLicensesNeedingAction .widget-settings").should(
            "not.exist"
        );
        cy.get(
            ".widget#ERMLicensesNeedingAction .widget-header #dropdownMenuButton"
        ).click();
        cy.get(
            ".widget#ERMLicensesNeedingAction .widget-header .toggle-settings"
        ).click();
        cy.get(".widget#ERMLicensesNeedingAction .widget-settings").should(
            "exist"
        );
        cy.get(".widget#ERMLicensesNeedingAction .widget-settings button")
            .contains("Close settings")
            .click();
        cy.get(".widget#ERMLicensesNeedingAction .widget-settings").should(
            "not.exist"
        );

        //Move
        cy.get(
            ".dashboard-right-col .widget#ERMLicensesNeedingAction .widget-header #dropdownMenuButton"
        ).click();
        cy.get(
            ".dashboard-right-col .widget#ERMLicensesNeedingAction .widget-header .move-left"
        ).click();
        cy.get(".dashboard-right-col .widget#ERMLicensesNeedingAction").should(
            "not.exist"
        );
        cy.get(".dashboard-left-col .dragArea")
            .children()
            .first()
            .should("have.id", "ERMLicensesNeedingAction");

        //Remove
        cy.get(
            ".dashboard-left-col .widget#ERMLicensesNeedingAction .widget-header #dropdownMenuButton"
        ).click();
        cy.get(
            ".dashboard-left-col .widget#ERMLicensesNeedingAction .widget-header .remove-widget"
        ).click();
        cy.get(".dashboard-left-col .widget#ERMLicensesNeedingAction").should(
            "not.exist"
        );

        //Add
        cy.get("#dashboard-header #open-widget-picker").click();
        cy.get(".modal #ERMLicensesNeedingAction .add-widget").click();
        cy.get(".modal .modal-footer button").contains("Close").click();
        cy.get(".dashboard-right-col .dragArea")
            .children()
            .first()
            .should("have.id", "ERMLicensesNeedingAction");
    });

    it("Latest SUSHI Counter jobs", () => {
        cy.intercept("GET", "/api/v1/jobs*", [
            {
                context: {
                    branch: "CPL",
                    branchname: "Centerville",
                    cardnumber: "42",
                    desk_id: null,
                    desk_name: null,
                    emailaddress: null,
                    firstname: null,
                    flags: "1",
                    id: "koha",
                    interface: "api",
                    number: "51",
                    register_id: null,
                    register_name: null,
                    shibboleth: "0",
                    surname: "koha",
                },
                data: {
                    begin_date: "2025-01-01",
                    end_date: "2025-03-12",
                    messages: [
                        {
                            code: 2010,
                            message:
                                "Error - Requestor is Not Authorized to Access Usage for Institution",
                            type: "error",
                        },
                    ],
                    report: {
                        report_type: "PR",
                        ud_provider_id: 1,
                        ud_provider_name: "Wiley Online Library",
                        us_report_info: {
                            added_mus: 0,
                            added_usage_objects: 0,
                            added_yus: 0,
                            skipped_mus: 0,
                            skipped_yus: 0,
                        },
                    },
                    report_type: "PR",
                    ud_provider_id: 1,
                    ud_provider_name: "Wiley Online Library",
                },
                ended_date: "2025-03-11T16:56:07+00:00",
                enqueued_date: "2025-03-11T16:56:06+00:00",
                job_id: 1,
                patron_id: "51",
                progress: "0",
                queue: "long_tasks",
                size: "1",
                started_date: "2025-03-11T16:56:06+00:00",
                status: "finished",
                type: "erm_sushi_harvester",
            },
        ]).as("getJobs");
        cy.visit("/cgi-bin/koha/erm/erm.pl");

        //Display
        cy.get(".widget#ERMLatestSUSHIJobs .widget-content").should(
            "contain",
            "Loading..."
        );
        cy.wait("@getJobs");
        cy.get(
            ".widget#ERMLatestSUSHIJobs .widget-content table tbody tr td:first"
        ).contains("Finished");

        cy.get(
            ".widget#ERMLatestSUSHIJobs .widget-content table tbody tr td:nth-child(2)"
        )
            .contains("Wiley Online Library")
            .click();

        cy.url().should("match", /erm\/eusage\/usage_data_providers/);

        cy.visit("/cgi-bin/koha/erm/erm.pl");

        cy.get(
            ".widget#ERMLatestSUSHIJobs .widget-content table tbody tr td:nth-child(5)"
        )
            .contains("View")
            .click();

        cy.url().should("match", /erm\/home/);

        //Move
        cy.get(
            ".dashboard-right-col .widget#ERMLatestSUSHIJobs .widget-header #dropdownMenuButton"
        ).click();
        cy.get(
            ".dashboard-right-col .widget#ERMLatestSUSHIJobs .widget-header .move-left"
        ).click();
        cy.get(".dashboard-right-col .widget#ERMLatestSUSHIJobs").should(
            "not.exist"
        );
        cy.get(".dashboard-left-col .dragArea")
            .children()
            .first()
            .should("have.id", "ERMLatestSUSHIJobs");

        //Remove
        cy.get(
            ".dashboard-left-col .widget#ERMLatestSUSHIJobs .widget-header #dropdownMenuButton"
        ).click();
        cy.get(
            ".dashboard-left-col .widget#ERMLatestSUSHIJobs .widget-header .remove-widget"
        ).click();
        cy.get(".dashboard-left-col .widget#ERMLatestSUSHIJobs").should(
            "not.exist"
        );

        //Add
        cy.get("#dashboard-header #open-widget-picker").click();
        cy.get(".modal #ERMLatestSUSHIJobs .add-widget").click();
        cy.get(".modal .modal-footer button").contains("Close").click();
        cy.get(".dashboard-right-col .dragArea")
            .children()
            .first()
            .should("have.id", "ERMLatestSUSHIJobs");
    });
});
