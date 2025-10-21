import { mount } from "@cypress/vue";

function get_package() {
    return {
        package_id: 1,
        name: "package 1",
        package_type: "complete",
        content_type: "Print",
        package_agreements: [
            {
                agreement: {
                    agreement_id: 2,
                    description: "agreement description",
                    name: "agreement name",
                },
                agreement_id: 2,
                package_id: 1,
            },
        ],
        notes: "",
        resources_count: 0,
    };
}

describe("Dialog operations", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.intercept(
            "GET",
            "/api/v1/erm/config",
            '{"settings":{"ERMModule":"1","ERMProviders":["local"]}}'
        );
    });

    it("There are no ... defined", () => {
        // GET packages returns empty list
        cy.intercept("GET", "/api/v1/erm/eholdings/local/packages*", {
            statusCode: 200,
            body: [],
            headers: {
                "X-Base-Total-Count": "0",
                "X-Total-Count": "0",
            },
        });
        cy.visit("/cgi-bin/koha/erm/eholdings/local/packages");
        cy.get("#packages_list").contains("There are no packages defined");
    });

    it("Something went wrong - 500", () => {
        // GET package returns 500
        cy.intercept("GET", "/api/v1/erm/eholdings/local/packages*", {
            statusCode: 500,
            body: {
                error: "This is a specific error message",
            },
        });
        cy.visit("/cgi-bin/koha/erm/erm.pl");
        cy.get(".sidebar_menu").contains("Packages").click();
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: This is a specific error message"
        );

        cy.intercept("GET", "/api/v1/erm/eholdings/local/packages*", {
            statusCode: 500, // No body, in case of Internal Server Error, we get statusText
        });
        cy.visit("/cgi-bin/koha/erm/erm.pl");
        cy.get(".sidebar_menu").contains("Packages").click();
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        cy.intercept("GET", "/api/v1/erm/agreements*", []);
        cy.get(".sidebar_menu").contains("Agreements").click();
        // Info messages should be cleared when view is changed
        cy.get("main div[class='alert alert-info']").contains(
            "There are no agreements defined"
        );
        cy.get("main div[class='alert alert-info']").should("have.length", 1);
    });

    it("...created!", () => {
        let erm_package = get_package();
        cy.intercept("GET", "/api/v1/erm/agreements*", []);

        cy.visit("/cgi-bin/koha/erm/eholdings/local/packages/add");
        cy.get("#name").type(erm_package.name);
        cy.get("#package_type .vs__search").type(
            erm_package.package_type + "{enter}",
            { force: true }
        );

        cy.intercept(
            "GET",
            "/api/v1/erm/eholdings/local/packages/*",
            erm_package
        ).as("get-package");
        cy.get("#packages_add").contains("Save").click();
        cy.wait("@get-package");
        cy.get("#packages_show").should("exist");
        cy.get("main div[class='alert alert-info']").contains(
            "Package created"
        );
        cy.get("main div[class='alert alert-info']").should("have.length", 1);

        cy.intercept("GET", "/api/v1/erm/eholdings/local/titles*", {
            statusCode: 200,
            body: [cy.get_title()],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("get-titles");
        cy.get(".sidebar_menu").contains("Titles").click();
        // Info messages should be cleared when view is changed
        cy.get("main div[class='alert alert-info']").should("not.exist");
    });

    it("Confirmation messages", () => {
        let erm_package = get_package();
        let packages = [erm_package];

        // Click the 'Delete' button from the list
        cy.intercept("GET", "/api/v1/erm/eholdings/local/packages*", {
            statusCode: 200,
            body: packages,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("PUT", "/api/v1/erm/eholdings/local/packages/*", {
            statusCode: 200,
            body: erm_package,
        }).as("put-package");
        cy.intercept(
            "GET",
            "/api/v1/erm/eholdings/local/packages/*",
            erm_package
        ).as("get-package");
        cy.visit("/cgi-bin/koha/erm/eholdings/local/packages");

        cy.get("#packages_list table tbody tr:first").contains("Edit").click();
        cy.wait("@get-package");
        cy.get("#packages_add").contains("Save").click();
        cy.wait("@put-package");
        cy.get("main div[class='alert alert-info']").contains(
            "Package updated"
        );
        cy.get("main div[class='alert alert-info']").should("have.length", 1);

        cy.get("#packages_show #toolbar").contains("Delete").click();
        cy.contains("No, do not delete").click();
        cy.get(".alert-warning.confirmation h1").should("not.exist");
        cy.get("main div[class='alert alert-info']").contains(
            "Package updated"
        );
        cy.get("main div[class='alert alert-info']").should("have.length", 1);

        cy.intercept("DELETE", "/api/v1/erm/eholdings/local/packages/*", {
            statusCode: 204,
            body: null,
        });

        cy.visit("/cgi-bin/koha/erm/eholdings/local/packages");
        cy.get("#packages_list table tbody tr:first")
            .contains("Delete")
            .click();
        cy.get(".alert-warning.confirmation h1").contains(
            "remove this local package"
        );
        cy.contains("Yes, delete").click();
        cy.get("main div[class='alert alert-info']")
            .contains("Local package")
            .contains("deleted");
        cy.get("main div[class='alert alert-info']").should("have.length", 1);
    });

    it("Confirmation messages with inputs", () => {
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
});
