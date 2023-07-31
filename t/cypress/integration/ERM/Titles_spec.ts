import { mount } from "@cypress/vue";
const dayjs = require("dayjs"); /* Cannot use our calendar JS code, it's in an include file (!)
                                   Also note that moment.js is deprecated */

function get_packages_to_relate() {
    return [
        {
            package_id: 1,
            description: "a package",
            name: "first package name"
        },
        {
            package_id: 2,
            description: "a second package",
            name: "second package name"
        }
    ]
}

describe("Title CRUD operations", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.intercept("GET", "/cgi-bin/koha/svc/config/systempreferences/?pref=ERMModule", '{"value":"1"}');
        cy.intercept("GET", "/cgi-bin/koha/svc/config/systempreferences/?pref=ERMProviders", '{"value":"local"}');
    });

    it("Import titles", () => {
        let erm_title = cy.get_title();
        let resource = erm_title.resources[0];

        // Create a list in case none exists
        cy.visit("/cgi-bin/koha/virtualshelves/shelves.pl");
        cy.contains("New list").click();
        cy.get("#shelfname").type('list name');
        cy.contains("Save").click();

        // First attempt to import list has no packages
        cy.intercept("GET", "/api/v1/erm/eholdings/local/packages*", {
            statusCode: 200,
            body: []
        }).as("get-empty-packages");
        cy.visit("/cgi-bin/koha/erm/eholdings/local/titles");
        cy.wait(500);
        cy.get("#toolbar a").contains("Import from list").click();
        cy.get("h2").contains("Import from a list");
        cy.get("#package_list .vs__selected").should('not.exist');

        // Make sure packages are returned
        cy.intercept("GET", "/api/v1/erm/eholdings/local/packages*", {
            statusCode: 200,
            body: get_packages_to_relate(),
        }).as("get-related-packages");
        cy.visit("/cgi-bin/koha/erm/eholdings/local/titles");
        cy.get("#toolbar a").contains("Import from list").click();
        cy.get("h2").contains("Import from a list");
        cy.wait(500);

        // Prepare background job response to the POST
        cy.intercept("POST", "/api/v1/erm/eholdings/local/titles/import", {
            statusCode: 200,
            body: {job_id: 1},
        }).as("get-job-response");
        cy.get("#list_list tbody tr:first td a").contains("Import").click();
        cy.get("main div[class='dialog message']").contains("Import in progress, see job #1");
    });

    it("List title", () => {
        // GET title returns 500
        cy.intercept("GET", "/api/v1/erm/eholdings/local/titles*", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.visit("/cgi-bin/koha/erm/erm.pl");
        cy.get("#navmenulist").contains("Titles").click();
        cy.get("main div[class='dialog alert']").contains(
            /Something went wrong/
        );

        // GET titles returns empty list
        cy.intercept("GET", "/api/v1/erm/eholdings/local/titles*", {
            statusCode: 200,
            body: [],
            headers: {
                "X-Base-Total-Count": "0",
                "X-Total-Count": "0",
            },
        });
        cy.visit("/cgi-bin/koha/erm/eholdings/local/titles");
        cy.get("#titles_list").contains("There are no titles defined");

        // GET titles returns something
        let erm_title = cy.get_title();
        let titles = [erm_title];

        cy.intercept("GET", "/api/v1/erm/eholdings/local/titles*", {
            statusCode: 200,
            body: titles,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.visit("/cgi-bin/koha/erm/eholdings/local/titles");
        cy.get("#titles_list").contains("Showing 1 to 1 of 1 entries");
    });

    it("Add title", () => {

        cy.intercept({
            method: "GET",
            url: "/api/v1/erm/eholdings/local/packages*",
            times: 1
        },
        {
            body: [],
        });

        // Click the button in the toolbar
        cy.visit("/cgi-bin/koha/erm/eholdings/local/titles");
        cy.wait(500); // Cypress is too fast! Vue hasn't populated the form yet!
        cy.contains("New title").click();
        cy.get("#titles_add h2").contains("New title");

        // Fill in the form for normal attributes
        let erm_title = cy.get_title();

        cy.get("#titles_add").contains("Submit").click();
        cy.get("input:invalid,textarea:invalid,select:invalid").should(
            "have.length",
            1
        );
        cy.get("#title_publication_title").type(erm_title.publication_title);
        cy.get("#title_print_identifier").type(erm_title.print_identifier);
        cy.get("#title_online_identifier").type(erm_title.online_identifier);
        cy.get("#title_date_first_issue_online").type(erm_title.date_first_issue_online);
        cy.get("#title_num_first_vol_online").type(erm_title.num_first_vol_online);
        cy.get("#title_num_first_issue_online").type(erm_title.num_first_issue_online);
        cy.get("#title_date_last_issue_online").type(erm_title.date_last_issue_online);
        cy.get("#title_num_last_vol_online").type(erm_title.num_last_vol_online);
        cy.get("#title_num_last_issue_online").type(erm_title.num_last_issue_online);
        cy.get("#title_title_url").type(erm_title.title_url);
        cy.get("#title_first_author").type(erm_title.first_author);
        cy.get("#title_embargo_info").type(erm_title.embargo_info);
        cy.get("#title_coverage_depth").type(erm_title.coverage_depth);
        cy.get("#title_notes").type(erm_title.notes);
        cy.get("#title_publisher_name").type(erm_title.publisher_name);
        cy.get("#title_publication_type .vs__search").type(
            erm_title.publication_type + "{enter}",
            { force: true }
        );
        cy.get("#title_date_monograph_published_print").type(erm_title.date_monograph_published_print);
        cy.get("#title_date_monograph_published_online").type(erm_title.date_monograph_published_online);
        cy.get("#title_monograph_volume").type(erm_title.monograph_volume);
        cy.get("#title_monograph_edition").type(erm_title.monograph_edition);
        cy.get("#title_first_editor").type(erm_title.first_editor);
        cy.get("#title_parent_publication_title_id").type(erm_title.parent_publication_title_id);
        cy.get("#title_preceeding_publication_title_id").type(erm_title.preceeding_publication_title_id);
        cy.get("#title_access_type").type(erm_title.access_type);

        cy.get("#resources").contains(
            "There are no packages created yet"
        );

        // Submit the form, get 500
        cy.intercept("POST", "/api/v1/erm/eholdings/local/titles", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.get("#titles_add").contains("Submit").click();
        cy.get("main div[class='dialog alert']").contains(
            "Something went wrong: SyntaxError: Unexpected end of JSON input"
        );

        // Submit the form, success!
        cy.intercept("POST", "/api/v1/erm/eholdings/local/titles", {
            statusCode: 201,
            body: erm_title,
        });
        cy.get("#titles_add").contains("Submit").click();
        cy.get("main div[class='dialog message']").contains("Title created");

        // Add new related package (resource)
        let related_package = erm_title.resources[0];
        cy.intercept("GET", "/api/v1/erm/eholdings/local/packages*", {
            statusCode: 200,
            body: get_packages_to_relate(),
        }).as('get-related-packages');
        cy.visit("/cgi-bin/koha/erm/eholdings/local/titles/add");
        cy.get("#resources").contains("Add to another package").click();
        cy.get("#resources").contains("Package 1");
        cy.get("#resources #resource_package_id_0 .vs__search").type(
            related_package.package.name
        );
        cy.get("#resources #resource_package_id_0 .vs__dropdown-menu li").eq(0).click( { force: true } ); //click first package suggestion
    });

    it("Edit title", () => {
        let erm_title = cy.get_title();
        let titles = [erm_title];
        // Click the 'Edit' button from the list
        cy.intercept("GET", "/api/v1/erm/eholdings/local/titles*", {
            statusCode: 200,
            body: titles,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept(
            "GET",
            "/api/v1/erm/eholdings/local/titles/*",
            erm_title
        ).as("get-title");
        cy.visit("/cgi-bin/koha/erm/eholdings/local/titles");
        // Intercept related packages request after entering title edit
        cy.intercept("GET", "/api/v1/erm/eholdings/local/packages*", {
            statusCode: 200,
            body: get_packages_to_relate(),
        }).as('get-related-packages');

        cy.get("#titles_list table tbody tr:first").contains("Edit").click();
        cy.wait("@get-title");
        cy.wait(500); // Cypress is too fast! Vue hasn't populated the form yet!
        cy.get("#titles_add h2").contains("Edit title");

        // Form has been correctly filled in
        cy.get("#title_publication_title").should("have.value", erm_title.publication_title);
        cy.get("#title_print_identifier").should("have.value", erm_title.print_identifier);
        cy.get("#title_online_identifier").should("have.value", erm_title.online_identifier);
        cy.get("#title_date_first_issue_online").should("have.value", erm_title.date_first_issue_online);
        cy.get("#title_num_first_vol_online").should("have.value", erm_title.num_first_vol_online);
        cy.get("#title_num_first_issue_online").should("have.value", erm_title.num_first_issue_online);
        cy.get("#title_date_last_issue_online").should("have.value", erm_title.date_last_issue_online);
        cy.get("#title_num_last_vol_online").should("have.value", erm_title.num_last_vol_online);
        cy.get("#title_num_last_issue_online").should("have.value", erm_title.num_last_issue_online);
        cy.get("#title_title_url").should("have.value", erm_title.title_url);
        cy.get("#title_first_author").should("have.value", erm_title.first_author);
        cy.get("#title_embargo_info").should("have.value", erm_title.embargo_info);
        cy.get("#title_coverage_depth").should("have.value", erm_title.coverage_depth);
        cy.get("#title_notes").should("have.value", erm_title.notes);
        cy.get("#title_publisher_name").should("have.value", erm_title.publisher_name);
        cy.get("#title_publication_type .vs__selected").contains('Journal');
        cy.get("#title_date_monograph_published_print").should("have.value", erm_title.date_monograph_published_print);
        cy.get("#title_date_monograph_published_online").should("have.value", erm_title.date_monograph_published_online);
        cy.get("#title_monograph_volume").should("have.value", erm_title.monograph_volume);
        cy.get("#title_monograph_edition").should("have.value", erm_title.monograph_edition);
        cy.get("#title_first_editor").should("have.value", erm_title.first_editor);
        cy.get("#title_parent_publication_title_id").should("have.value", erm_title.parent_publication_title_id);
        cy.get("#title_preceeding_publication_title_id").should("have.value", erm_title.preceeding_publication_title_id);
        cy.get("#title_access_type").should("have.value", erm_title.access_type);

        //Test related content
        cy.get("#resources #resource_package_id_0 .vs__selected").contains("package name");

        // Submit the form, get 500
        cy.intercept("PUT", "/api/v1/erm/eholdings/local/titles/*", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.get("#titles_add").contains("Submit").click();
        cy.get("main div[class='dialog alert']").contains(
            "Something went wrong: SyntaxError: Unexpected end of JSON input"
        );

        // Submit the form, success!
        cy.intercept("PUT", "/api/v1/erm/eholdings/local/titles/*", {
            statusCode: 200,
            body: erm_title,
        });
        cy.get("#titles_add").contains("Submit").click();
        cy.get("main div[class='dialog message']").contains("Title updated");
    });

    it("Show title", () => {
        let erm_title = cy.get_title();
        let titles = [erm_title];
        // Click the "name" link from the list
        cy.intercept("GET", "/api/v1/erm/eholdings/local/titles*", {
            statusCode: 200,
            body: titles,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        // Title with empty resources.
        cy.intercept(
            {
                method: "GET",
                url: "/api/v1/erm/eholdings/local/titles/*",
                times: 1
            },
            {
                body: {
                    publication_title: "publication title",
                    resources: [],
                    title_id: 1,
                }
            }
        ).as("get-title");
        cy.visit("/cgi-bin/koha/erm/eholdings/local/titles");
        let title_link = cy.get(
            "#titles_list table tbody tr:first td:first a"
        );
        title_link.should(
            "have.text",
            erm_title.publication_title + " (#" + erm_title.title_id + ")"
        );
        cy.get(
            "#titles_list table tbody tr:first td:first a"
        ).click();
        cy.wait("@get-title");
        cy.wait(500); // Cypress is too fast! Vue hasn't populated the form yet!
        cy.get("#eholdings_title_show h2").contains(
            "Title #" + erm_title.title_id
        );
        // There are no packages, the table should not be displayed
        cy.contains("Packages (0)");
        cy.get("#table#package_list").should("not.exist");

        // Test now with all values
        cy.intercept(
            "GET",
            "/api/v1/erm/eholdings/local/titles/*",
            erm_title
        ).as("get-title");

        // List packages
        cy.visit("/cgi-bin/koha/erm/eholdings/local/titles/1");
        cy.contains("Packages (1)");
        cy.wait(500);

        // Visit resource
        let related_package = erm_title.resources[0];
        // cy.get("#package_list tbody tr:first td a").contains("first package name").click();
        cy.intercept(
            "GET",
            "/api/v1/erm/eholdings/local/resources/"+related_package.resource_id,
            related_package
        ).as("get-related-package");
        cy.get("table#package_list").contains("first package name").click();
        cy.contains("Resource #"+related_package.resource_id);
        cy.contains(related_package.package.name);
    });

    it("Delete title", () => {
        let erm_title = cy.get_title();
        let titles = [erm_title];

        // Click the 'Delete' button from the list
        cy.intercept("GET", "/api/v1/erm/eholdings/local/titles*", {
            statusCode: 200,
            body: titles,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept(
            "GET",
            "/api/v1/erm/eholdings/local/titles/*",
            erm_title
        );
        cy.visit("/cgi-bin/koha/erm/eholdings/local/titles");

        cy.get("#titles_list table tbody tr:first")
            .contains("Delete")
            .click();
        cy.get(".dialog.alert.confirmation h1").contains("remove this title");
        cy.contains(erm_title.publication_title);

        // Accept the confirmation dialog, get 500
        cy.intercept("DELETE", "/api/v1/erm/eholdings/local/titles/*", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.contains("Yes, delete").click();
        cy.get("main div[class='dialog alert']").contains(
            "Something went wrong: SyntaxError: Unexpected end of JSON input"
        );

        // Accept the confirmation dialog, success!
        cy.intercept("DELETE", "/api/v1/erm/eholdings/local/titles/*", {
            statusCode: 204,
            body: null,
        });
        cy.get("#titles_list table tbody tr:first")
            .contains("Delete")
            .click();
        cy.get(".dialog.alert.confirmation h1").contains("remove this title");
        cy.contains("Yes, delete").click();
        cy.get("main div[class='dialog message']").contains("Local title").contains("deleted");

        // Delete from show
        // Click the "name" link from the list
        cy.intercept("GET", "/api/v1/erm/eholdings/local/titles*", {
            statusCode: 200,
            body: titles,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        // Title with empty resources.
        cy.intercept(
            {
                method: "GET",
                url: "/api/v1/erm/eholdings/local/titles/*",
                times: 1
            },
            {
                body: {
                    publication_title: "publication title",
                    resources: [],
                    title_id: 1,
                }
            }
        ).as("get-title");
        cy.visit("/cgi-bin/koha/erm/eholdings/local/titles");
        let title_link = cy.get(
            "#titles_list table tbody tr:first td:first a"
        );
        title_link.should(
            "have.text",
            erm_title.publication_title + " (#" + erm_title.title_id + ")"
        );
        cy.get(
            "#titles_list table tbody tr:first td:first a"
        ).click();
        cy.wait("@get-title");
        cy.wait(500); // Cypress is too fast! Vue hasn't populated the form yet!
        cy.get("#eholdings_title_show h2").contains(
            "Title #" + erm_title.title_id
        );

        cy.get('#eholdings_title_show .action_links .fa-trash').click();
        cy.get(".dialog.alert.confirmation h1").contains("remove this title");
        cy.contains("Yes, delete").click();

        //Make sure we return to list after deleting from show
        cy.get("#titles_list table tbody tr:first")
    });
});
