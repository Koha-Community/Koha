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
        cy.get("#package_name").type(erm_package.name);
        cy.get("#package_type .vs__search").type(
            erm_package.package_type + "{enter}",
            { force: true }
        );

        cy.intercept("POST", "/api/v1/erm/eholdings/local/packages", {
            statusCode: 201,
            body: erm_package,
        });
        cy.intercept("GET", "/api/v1/erm/eholdings/local/packages*", {
            statusCode: 200,
            body: [erm_package],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.get("#packages_add").contains("Submit").click();
        cy.get("main div[class='alert alert-info']").contains(
            "Package created"
        );
        cy.get("#package_list_result").should("exist");
        cy.get("main div[class='alert alert-info']").should("have.length", 1);

        cy.intercept("GET", "/api/v1/erm/eholdings/local/titles*", {
            statusCode: 200,
            body: [cy.get_title()],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
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
            body: [erm_package],
        });
        cy.intercept(
            "GET",
            "/api/v1/erm/eholdings/local/packages/*",
            erm_package
        );
        cy.visit("/cgi-bin/koha/erm/eholdings/local/packages");

        cy.get("#packages_list table tbody tr:first").contains("Edit").click();
        cy.get("#packages_add").contains("Submit").click();
        cy.get("main div[class='alert alert-info']").contains(
            "Package updated"
        );
        cy.get("main div[class='alert alert-info']").should("have.length", 1);

        cy.get("#packages_list table tbody tr:first")
            .contains("Delete")
            .click();
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
        cy.get("#packages_list table tbody tr:first")
            .contains("Delete")
            .click();
        cy.get(".alert-warning.confirmation h1").contains(
            "remove this package"
        );
        cy.contains("Yes, delete").click();
        cy.get("main div[class='alert alert-info']")
            .contains("Local package")
            .contains("deleted");
        cy.get("main div[class='alert alert-info']").should("have.length", 1);
    });
});
