import { mount } from "@cypress/vue";
const dayjs = require("dayjs"); /* Cannot use our calendar JS code, it's in an include file (!)
                                   Also note that moment.js is deprecated */

const dates = {
    today_iso: dayjs().format("YYYY-MM-DD"),
    today_us: dayjs().format("MM/DD/YYYY"),
    tomorrow_iso: dayjs().add(1, "day").format("YYYY-MM-DD"),
    tomorrow_us: dayjs().add(1, "day").format("MM/DD/YYYY"),
};

describe("License CRUD operations", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.intercept(
            "GET",
            "/api/v1/erm/config",
            '{"settings":{"ERMModule":"1","ERMProviders":["local"]}}'
        );
        cy.intercept("GET", "/api/v1/erm/licenses*", {
            statusCode: 200,
            body: [cy.get_license()],
            headers: {
                "X-Total-Count": "5",
            },
        }).as("getDashboardLicenses");
    });

    it("List license", () => {
        cy.visit("/cgi-bin/koha/erm/erm.pl");
        cy.wait("@getDashboardLicenses");
        // GET license returns 500
        cy.intercept("GET", "/api/v1/erm/licenses*", {
            statusCode: 500,
        });
        cy.get(".sidebar_menu").contains("Licenses").click();
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // GET licenses returns empty list
        cy.intercept("GET", "/api/v1/erm/licenses*", []);
        cy.visit("/cgi-bin/koha/erm/licenses");
        cy.get("#licenses_list").contains("There are no licenses defined");

        // GET licenses returns something
        let license = cy.get_license();
        let licenses = [license];

        cy.intercept("GET", "/api/v1/erm/licenses*", {
            statusCode: 200,
            body: licenses,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/erm/licenses/*", license);
        cy.visit("/cgi-bin/koha/erm/licenses");
        cy.get("#licenses_list").contains("Showing 1 to 1 of 1 entries");
    });

    it("Add license", () => {
        let license = cy.get_license();
        let vendors = cy.get_vendors_to_relate();
        //Intercept vendors request
        cy.intercept("GET", "/api/v1/acquisitions/vendors*", {
            statusCode: 200,
            body: vendors,
        });
        // Click the button in the toolbar
        cy.visit("/cgi-bin/koha/erm/licenses");
        cy.contains("New license").click();
        cy.get("#licenses_add h2").contains("New license");
        cy.left_menu_active_item_is("Licenses");

        // Fill in the form for normal attributes
        cy.get("#licenses_add").contains("Submit").click();
        cy.get("input:invalid,textarea:invalid,select:invalid").should(
            "have.length",
            4
        );
        cy.get("#name").type(license.name);
        cy.get("#description").type(license.description);
        cy.get("#licenses_add").contains("Submit").click();
        cy.get("#type .vs__search").type(license.type + "{enter}", {
            force: true,
        });
        cy.get("#status .vs__search").type(license.status + "{enter}", {
            force: true,
        });

        // vendors
        cy.get("#vendor_id .vs__selected").should("not.exist"); //no vendor pre-selected for new license

        // vendor aliases
        cy.get("#vendor_id .vs__search").click();
        cy.get("#vendor_id #vs3__option-1").contains(vendors[1].name);
        cy.get("#vendor_id #vs3__option-1 cite").contains(
            vendors[1].aliases[0].alias
        );

        cy.get("#vendor_id .vs__search").type(vendors[0].name + "{enter}", {
            force: true,
        });
        cy.get("#vendor_id .vs__selected").contains(vendors[0].name);

        cy.get("#started_on+input").click();
        cy.get(".flatpickr-calendar")
            .eq(0)
            .find("span.today")
            .click({ force: true });

        cy.get("#ended_on+input").click();
        cy.get(".flatpickr-calendar")
            .eq(1)
            .find("span.today")
            .next("span")
            .click();

        // Add new document
        cy.get("#documents_relationship").contains("Add new document").click();
        cy.get("#documents_0 input[id=file__0]").click();
        cy.get("#documents_0 input[id=file__0]").selectFile(
            "t/cypress/fixtures/file.json"
        );
        cy.get("#documents_0 .file_information span").contains("file.json");
        cy.get("#documents_0 input[id=file_description__0]").type(
            "file description"
        );
        cy.get("#documents_0 input[id=documents_physical_location_0]").type(
            "file physical location"
        );
        cy.get("#documents_0 input[id=documents_uri_0]").type("file URI");
        cy.get("#documents_0 input[id=documents_notes_0]").type("file notes");

        // Submit the form, get 500
        cy.intercept("POST", "/api/v1/erm/licenses", {
            statusCode: 500,
        });
        cy.get("#licenses_add").contains("Submit").click();
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Submit the form, success!
        cy.intercept("POST", "/api/v1/erm/licenses", {
            statusCode: 201,
            body: license,
        });
        cy.get("#licenses_add").contains("Submit").click();
        cy.get("main div[class='alert alert-info']").contains(
            "License created"
        );
    });

    it("Edit license", () => {
        let license = cy.get_license();
        let licenses = [license];
        let vendors = cy.get_vendors_to_relate();

        // Intercept vendors request
        cy.intercept("GET", "/api/v1/acquisitions/vendors*", {
            statusCode: 200,
            body: vendors,
        }).as("get-vendor-options");

        // Click the 'Edit' button from the list
        cy.intercept("GET", "/api/v1/erm/licenses*", {
            statusCode: 200,
            body: licenses,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("get-licenses");
        cy.intercept("GET", "/api/v1/erm/licenses/*", license).as(
            "get-license"
        );
        cy.visit("/cgi-bin/koha/erm/licenses");
        cy.wait("@get-licenses");
        cy.get("#licenses_list table tbody tr:first").contains("Edit").click();
        cy.wait("@get-license");
        cy.get("#licenses_add h2").contains("Edit license");
        cy.left_menu_active_item_is("Licenses");

        // Form has been correctly filled in
        cy.get("#name").should("have.value", license.name);

        //vendors
        cy.get("#vendor_id .vs__selected").contains(license.vendor[0].name);

        cy.get("#vendor_id .vs__search").type(vendors[1].name + "{enter}", {
            force: true,
        });

        //vendor aliases
        cy.get("#vendor_id .vs__search").click();
        cy.get("#vendor_id #vs3__option-1").contains(vendors[1].name);
        cy.get("#vendor_id #vs3__option-1 cite").contains(
            vendors[1].aliases[0].alias
        );

        cy.get("#description").should("have.value", license.description);
        cy.get("#type .vs__selected").contains("Local");
        cy.get("#status .vs__selected").contains("Active");
        cy.get("#started_on").invoke("val").should("eq", dates["today_iso"]);
        cy.get("#ended_on").invoke("val").should("eq", dates["tomorrow_iso"]);

        // Test related document
        cy.get("#documents_0 .file_information span").contains("file.json");

        // Submit the form, get 500
        cy.intercept("PUT", "/api/v1/erm/licenses/*", {
            statusCode: 500,
        });
        cy.get("#licenses_add").contains("Submit").click();
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Submit the form, success!
        cy.intercept("PUT", "/api/v1/erm/licenses/*", {
            statusCode: 200,
            body: license,
        });
        cy.get("#licenses_add").contains("Submit").click();
        cy.get("main div[class='alert alert-info']").contains(
            "License updated"
        );
    });

    it("Show license", () => {
        let license = cy.get_license();
        let licenses = [license];
        // Click the "name" link from the list
        cy.intercept("GET", "/api/v1/erm/licenses*", {
            statusCode: 200,
            body: licenses,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("get-licenses");
        cy.intercept("GET", "/api/v1/erm/licenses/*", license).as(
            "get-license"
        );
        cy.visit("/cgi-bin/koha/erm/licenses");
        cy.wait("@get-licenses");
        let id_cell = cy.get("#licenses_list table tbody tr:first td:first");
        id_cell.contains(license.license_id);

        let name_link = cy
            .get("#licenses_list table tbody tr:first td")
            .eq(1)
            .find("a");
        name_link.should("have.text", license.name);
        name_link.click();
        cy.wait("@get-license");
        cy.get("#licenses_show h2").contains("License #" + license.license_id);
        cy.left_menu_active_item_is("Licenses");
    });

    it("Delete license", () => {
        let license = cy.get_license();
        let licenses = [license];

        // Click the 'Delete' button from the list
        cy.intercept("GET", "/api/v1/erm/licenses*", {
            statusCode: 200,
            body: licenses,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/erm/licenses/*", license);
        cy.visit("/cgi-bin/koha/erm/licenses");

        cy.get("#licenses_list table tbody tr:first")
            .contains("Delete")
            .click();
        cy.get(".alert-warning.confirmation h1").contains(
            "remove this license"
        );
        cy.contains(license.name);

        // Accept the confirmation dialog, get 500
        cy.intercept("DELETE", "/api/v1/erm/licenses/*", {
            statusCode: 500,
        });
        cy.contains("Yes, delete").click();
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Accept the confirmation dialog, success!
        cy.intercept("DELETE", "/api/v1/erm/licenses/*", {
            statusCode: 204,
            body: null,
        });
        cy.get("#licenses_list table tbody tr:first")
            .contains("Delete")
            .click();
        cy.get(".alert-warning.confirmation h1").contains(
            "remove this license"
        );
        cy.contains("Yes, delete").click();
        cy.get("main div[class='alert alert-info']")
            .contains("License")
            .contains("deleted");

        // Delete from show
        // Click the "name" link from the list
        cy.intercept("GET", "/api/v1/erm/licenses*", {
            statusCode: 200,
            body: licenses,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("get-licenses");
        cy.intercept("GET", "/api/v1/erm/licenses/*", license).as(
            "get-license"
        );
        cy.visit("/cgi-bin/koha/erm/licenses");
        cy.wait("@get-licenses");
        let id_cell = cy.get("#licenses_list table tbody tr:first td:first");
        id_cell.contains(license.license_id);

        let name_link = cy
            .get("#licenses_list table tbody tr:first td")
            .eq(1)
            .find("a");
        name_link.should("have.text", license.name);
        name_link.click();
        cy.wait("@get-license");
        cy.get("#licenses_show h2").contains("License #" + license.license_id);

        cy.get("#licenses_show #toolbar").contains("Delete").click();
        cy.get(".alert-warning.confirmation h1").contains(
            "remove this license"
        );
        cy.contains("Yes, delete").click();

        //Make sure we return to list after deleting from show
        cy.get("#licenses_list table tbody tr:first");
    });
});
