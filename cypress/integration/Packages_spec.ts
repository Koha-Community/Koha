import { mount } from "@cypress/vue";
const dayjs = require("dayjs"); /* Cannot use our calendar JS code, it's in an include file (!)
                                   Also note that moment.js is deprecated */

function get_package() {
    return {
        package_id: 1,
        name: "package 1",
        package_type: "complete",
        content_type: "Print",
        package_agreements: [],
        resources_count: 0,
    };
}

describe("Package CRUD operations", () => {
    beforeEach(() => {
        cy.login("koha", "koha");
        cy.title().should("eq", "Koha staff interface");
    });

    it("List package", () => {
        // GET package returns 500
        cy.intercept("GET", "/api/v1/erm/eholdings/local/packages", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.visit("/cgi-bin/koha/erm/erm.pl");
        cy.get("#navmenulist").contains("Packages").click();
        cy.get("main div[class='dialog alert']").contains(
            /Something went wrong/
        );

        // GET packages returns empty list
        cy.intercept("GET", "/api/v1/erm/eholdings/local/packages*", []);
        cy.visit("/cgi-bin/koha/erm/eholdings/local/packages");
        cy.get("#packages_list").contains("There are no packages defined");

        // GET packages returns something
        let erm_package = get_package();
        let packages = [erm_package];

        cy.intercept("GET", "/api/v1/erm/eholdings/local/packages*", {
            statusCode: 200,
            body: packages,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept(
            "GET",
            "/api/v1/erm/eholdings/local/packages/*",
            erm_package
        );
        cy.visit("/cgi-bin/koha/erm/eholdings/local/packages");
        cy.get("#packages_list").contains("Showing 1 to 1 of 1 entries");
    });

    it("Add package", () => {
        // Click the button in the toolbar
        cy.visit("/cgi-bin/koha/erm/eholdings/local/packages");
        cy.contains("New package").click();
        cy.get("#packages_add h2").contains("New package");

        // Fill in the form for normal attributes
        let erm_package = get_package();

        cy.get("#packages_add").contains("Submit").click();
        cy.get("input:invalid,textarea:invalid,select:invalid").should(
            "have.length",
            1
        );
        cy.get("#package_name").type(erm_package.name);
        cy.get("#package_type .vs__search").type(
            erm_package.package_type + "{enter}",
            { force: true }
        );
        cy.get("#package_content_type .vs__search").type(
            erm_package.content_type + "{enter}",
            { force: true }
        );

        cy.get("#package_agreements").contains(
            "There are no agreements created yet"
        );

        // Submit the form, get 500
        cy.intercept("POST", "/api/v1/erm/eholdings/local/packages", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.get("#packages_add").contains("Submit").click();
        cy.get("main div[class='dialog alert']").contains(
            "Something went wrong: Internal Server Error"
        );

        // Submit the form, success!
        cy.intercept("POST", "/api/v1/erm/eholdings/local/packages", {
            statusCode: 201,
            body: erm_package,
        });
        cy.get("#packages_add").contains("Submit").click();
        cy.get("main div[class='dialog message']").contains("Package created");

        // Link with an agreement
        cy.intercept("GET", "/api/v1/erm/agreements", {
            statusCode: 200,
            body: [{ package_id: 1, description: "an agreement" }],
        });
        cy.visit("/cgi-bin/koha/erm/eholdings/local/packages/add");
        cy.get("#package_agreements").contains("Add new agreement");
    });

    it("Edit package", () => {
        let erm_package = get_package();
        let packages = [erm_package];
        // Click the 'Edit' button from the list
        cy.intercept("GET", "/api/v1/erm/eholdings/local/packages*", {
            statusCode: 200,
            body: packages,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept(
            "GET",
            "/api/v1/erm/eholdings/local/packages/*",
            erm_package
        ).as("get-package");
        cy.visit("/cgi-bin/koha/erm/eholdings/local/packages");
        cy.get("#packages_list table tbody tr:first").contains("Edit").click();
        cy.wait("@get-package");
        cy.wait(500); // Cypress is too fast! Vue hasn't populated the form yet!
        cy.get("#packages_add h2").contains("Edit package");

        // Form has been correctly filled in
        cy.get("#package_name").should("have.value", erm_package.name);
        cy.get("#package_type .vs__selected").contains("Complete");
        cy.get("#package_content_type .vs__selected").contains("Print");

        // Submit the form, get 500
        cy.intercept("PUT", "/api/v1/erm/eholdings/local/packages/*", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.get("#packages_add").contains("Submit").click();
        cy.get("main div[class='dialog alert']").contains(
            "Something went wrong: Internal Server Error"
        );

        // Submit the form, success!
        cy.intercept("PUT", "/api/v1/erm/eholdings/local/packages/*", {
            statusCode: 200,
            body: erm_package,
        });
        cy.get("#packages_add").contains("Submit").click();
        cy.get("main div[class='dialog message']").contains("Package updated");
    });

    it("Show package", () => {
        let erm_package = get_package();
        let packages = [erm_package];
        // Click the "name" link from the list
        cy.intercept("GET", "/api/v1/erm/eholdings/local/packages*", {
            statusCode: 200,
            body: packages,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept(
            "GET",
            "/api/v1/erm/eholdings/local/packages/*",
            erm_package
        ).as("get-package");
        cy.visit("/cgi-bin/koha/erm/eholdings/local/packages");
        let name_link = cy.get(
            "#packages_list table tbody tr:first td:first a"
        );
        name_link.should(
            "have.text",
            erm_package.name + " (#" + erm_package.package_id + ")"
        );
        name_link.click();
        cy.wait("@get-package");
        cy.wait(500); // Cypress is too fast! Vue hasn't populated the form yet!
        cy.get("#packages_show h2").contains(
            "Package #" + erm_package.package_id
        );
        // There are no resources, the table should not be displayed
        cy.contains("Titles (0)");
        cy.get("#table#title_list").should("not.exist");

        // List resources
        cy.intercept("GET", "/api/v1/erm/eholdings/local/packages/*", {
            ...erm_package,
            resources_count: 1,
        });
        cy.intercept(
            "GET",
            "/api/v1/erm/eholdings/local/packages/1/resources*",
            {
                statusCode: 200,
                body: [
                    {
                        package_id: erm_package.package_id,
                        resource_id: 1,
                        title_id: 1,
                        title: {
                            biblio_id: 42,
                            publication_title: "A great title",
                            publication_type: "",
                        },
                    },
                ],
                headers: {
                    "X-Base-Total-Count": "1",
                    "X-Total-Count": "1",
                },
            }
        ).as("get-resource");
        cy.visit("/cgi-bin/koha/erm/eholdings/local/packages/1");
        cy.contains("Titles (1)");
        cy.wait("@get-resource");
        cy.wait(500);
        cy.get("table#title_list").contains("A great title");
    });

    it("Delete package", () => {
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
        cy.intercept(
            "GET",
            "/api/v1/erm/eholdings/local/packages/*",
            erm_package
        );
        cy.visit("/cgi-bin/koha/erm/eholdings/local/packages");

        cy.get("#packages_list table tbody tr:first")
            .contains("Delete")
            .click();
        cy.get("#packages_confirm_delete h2").contains("Delete package");
        cy.contains("Package name: " + erm_package.name);

        // Submit the form, get 500
        cy.intercept("DELETE", "/api/v1/erm/eholdings/local/packages/*", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.contains("Yes, delete").click();
        cy.get("main div[class='dialog alert']").contains(
            "Something went wrong: Internal Server Error"
        );

        // Submit the form, success!
        cy.intercept("DELETE", "/api/v1/erm/eholdings/local/packages/*", {
            statusCode: 204,
            body: null,
        });
        cy.contains("Yes, delete").click();
        cy.get("main div[class='dialog message']").contains("Package deleted");
    });
});
