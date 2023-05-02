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
            "/cgi-bin/koha/svc/config/systempreferences/?pref=ERMModule",
            '{"value":"1"}'
        );
        cy.intercept(
            "GET",
            "/cgi-bin/koha/svc/config/systempreferences/?pref=ERMProviders",
            '{"value":"local"}'
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
            error: "Something went wrong",
        });
        cy.visit("/cgi-bin/koha/erm/erm.pl");
        cy.get("#navmenulist").contains("Packages").click();
        cy.get("main div[class='dialog alert']").contains(
            /Something went wrong/
        );

        cy.intercept("GET", "/api/v1/erm/agreements*", []);
        cy.get("#navmenulist").contains("Agreements").click();
        // Info messages should be cleared when view is changed
        cy.get("main div[class='dialog message']").contains(
            "There are no agreements defined"
        );
        cy.get("main div[class='dialog message']").should("have.length", 1);
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
        cy.get("#packages_add").contains("Submit").click();
        cy.get("main div[class='dialog message']").contains("Package created");
        cy.get("main div[class='dialog message']").should("have.length", 1);

        cy.intercept("GET", "/api/v1/erm/eholdings/local/titles*", {
            statusCode: 200,
            body: [cy.get_title()],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.get("#navmenulist").contains("Titles").click();
        // Info messages should be cleared when view is changed
        cy.get("main div[class='dialog message']").should("not.exist");
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
        cy.get("main div[class='dialog message']").contains("Package updated");
        cy.get("main div[class='dialog message']").should("have.length", 1);

        cy.get("#packages_list table tbody tr:first")
            .contains("Delete")
            .click();
        cy.contains("No, do not delete").click();
        cy.get(".dialog.alert.confirmation h1").should("not.exist");
        cy.get("main div[class='dialog message']").contains("Package updated");
        cy.get("main div[class='dialog message']").should("have.length", 1);

        cy.intercept("DELETE", "/api/v1/erm/eholdings/local/packages/*", {
            statusCode: 204,
            body: null,
        });
        cy.get("#packages_list table tbody tr:first")
            .contains("Delete")
            .click();
        cy.get(".dialog.alert.confirmation h1").contains("remove this package");
        cy.contains("Yes, delete").click();
        cy.get("main div[class='dialog message']")
            .contains("Local package")
            .contains("deleted");
        cy.get("main div[class='dialog message']").should("have.length", 1);
    });
});
