import { mount } from "@cypress/vue";
const dayjs = require("dayjs"); /* Cannot use our calendar JS code, it's in an include file (!)
                                   Also note that moment.js is deprecated */

const dates = {
    today_iso: dayjs().format("YYYY-MM-DD"),
    today_us: dayjs().format("MM/DD/YYYY"),
    tomorrow_iso: dayjs().add(1, "day").format("YYYY-MM-DD"),
    tomorrow_us: dayjs().add(1, "day").format("MM/DD/YYYY"),
};

const createLicenses = start => {
    const licenses = [];
    for (let i = start; i < start + 20; i++) {
        const newLicense = {
            license_id: i,
            name: "License " + i,
            description: "A test license",
            type: "local",
            status: "active",
            started_on: dates["today_iso"],
            ended_on: dates["tomorrow_iso"],
            user_roles: [],
        };
        licenses.push(newLicense);
    }
    return licenses;
};

describe("Infinite scroll", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.intercept(
            "GET",
            "/api/v1/erm/config",
            '{"settings":{"ERMModule":"1","ERMProviders":["local"]}}'
        );
    });

    it("Should load the next page on scroll", () => {
        const pageOne = createLicenses(1);
        const pageTwo = createLicenses(21);
        const pageThree = createLicenses(41);
        const agreement = cy.get_agreement();
        const vendors = cy.get_vendors_to_relate();

        // No agreement, no license yet
        cy.intercept("GET", "/api/v1/erm/agreements*", {
            statusCode: 200,
            body: [],
        });
        cy.intercept("GET", "/api/v1/erm/licenses*", {
            statusCode: 200,
            body: [],
        });
        //Intercept vendors request
        cy.intercept("GET", "/api/v1/acquisitions/vendors*", {
            statusCode: 200,
            body: vendors,
        });
        cy.intercept("GET", "/api/v1/erm/licenses*", {
            statusCode: 200,
            body: pageOne,
            headers: {
                "X-Base-Total-Count": "20",
                "X-Total-Count": "20",
            },
        });

        // Click the button in the toolbar
        cy.visit("/cgi-bin/koha/erm/agreements");
        cy.contains("New agreement").click();

        cy.get("#agreement_licenses").contains("Add new license").click();
        cy.get("#license_id_0 .vs__open-indicator").click();
        cy.get("#license_id_0").find("li").as("options");
        cy.get("@options").should("have.length", 20);

        cy.intercept("GET", "/api/v1/erm/licenses*", {
            statusCode: 200,
            body: pageTwo,
            headers: {
                "X-Base-Total-Count": "20",
                "X-Total-Count": "20",
            },
        }).as("getPageTwo");
        // Scroll the dropdown
        cy.get(".vs__dropdown-menu").scrollTo("bottom");
        cy.wait("@getPageTwo");
        cy.get("@options").should("have.length", 40);

        cy.intercept("GET", "/api/v1/erm/licenses*", {
            statusCode: 200,
            body: pageThree,
            headers: {
                "X-Base-Total-Count": "20",
                "X-Total-Count": "20",
            },
        }).as("getPageThree");
        // Scroll the dropdown again
        cy.get(".vs__dropdown-menu").scrollTo("bottom");
        cy.wait("@getPageThree");
        cy.get("@options").should("have.length", 60);
    });

    it("Should correctly submit the form", () => {
        const pageOne = createLicenses(1);
        const vendors = cy.get_vendors_to_relate();
        let agreement = cy.get_agreement();

        // No agreement, no license yet
        cy.intercept("GET", "/api/v1/erm/agreements*", {
            statusCode: 200,
            body: [],
        });
        cy.intercept("GET", "/api/v1/erm/licenses*", {
            statusCode: 200,
            body: [],
        });
        //Intercept vendors request
        cy.intercept("GET", "/api/v1/acquisitions/vendors*", {
            statusCode: 200,
            body: vendors,
        });
        cy.intercept("GET", "/api/v1/erm/licenses*", {
            statusCode: 200,
            body: pageOne,
            headers: {
                "X-Base-Total-Count": "20",
                "X-Total-Count": "20",
            },
        });

        // Click the button in the toolbar
        cy.visit("/cgi-bin/koha/erm/agreements");
        cy.contains("New agreement").click();

        cy.get("#agreement_licenses").contains("Add new license").click();
        cy.get("#license_id_0 .vs__open-indicator").click();

        cy.get("#agreement_license_0 #license_id_0 .vs__dropdown-menu li")
            .eq(0)
            .click({ force: true }); //click first license suggestion

        // Fill in the other required fields
        cy.get("#agreement_name").type(agreement.name);
        cy.get("#agreement_status .vs__search").type(
            agreement.status + "{enter}",
            { force: true }
        );
        cy.get("#agreement_license_0 #license_status_0 .vs__search").type(
            agreement.agreement_licenses[0].status + "{enter}",
            { force: true }
        );

        cy.intercept("POST", "/api/v1/erm/agreements", {
            statusCode: 201,
            body: agreement,
        });
        // Submit the form, no error should be thrown as the select has correctly set the license id
        cy.get("#agreements_add").contains("Submit").click();
        cy.get("main div[class='dialog message']").contains(
            "Agreement created"
        );
    });

    it("Should correctly display labels", () => {
        const pageOne = createLicenses(1);
        const pageTwo = createLicenses(21);
        const pageThree = createLicenses(41);
        const vendors = cy.get_vendors_to_relate();

        // No agreement, no license yet
        cy.intercept("GET", "/api/v1/erm/agreements*", {
            statusCode: 200,
            body: [],
        });
        cy.intercept("GET", "/api/v1/erm/licenses*", {
            statusCode: 200,
            body: [],
        });
        //Intercept vendors request
        cy.intercept("GET", "/api/v1/acquisitions/vendors*", {
            statusCode: 200,
            body: vendors,
        });
        cy.intercept("GET", "/api/v1/erm/licenses*", {
            statusCode: 200,
            body: pageOne,
            headers: {
                "X-Base-Total-Count": "20",
                "X-Total-Count": "20",
            },
        });

        // Click the button in the toolbar
        cy.visit("/cgi-bin/koha/erm/agreements");
        cy.contains("New agreement").click();

        cy.get("#agreement_licenses").contains("Add new license").click();
        cy.get("#license_id_0 .vs__open-indicator").click();
        cy.get("#license_id_0").find("li").as("options");
        cy.get("@options").should("have.length", 20);

        cy.intercept("GET", "/api/v1/erm/licenses*", {
            statusCode: 200,
            body: pageTwo,
            headers: {
                "X-Base-Total-Count": "20",
                "X-Total-Count": "20",
            },
        }).as("getPageTwo");
        // Scroll the dropdown
        cy.get(".vs__dropdown-menu").scrollTo("bottom");
        cy.wait("@getPageTwo");

        cy.intercept("GET", "/api/v1/erm/licenses*", {
            statusCode: 200,
            body: pageThree,
            headers: {
                "X-Base-Total-Count": "20",
                "X-Total-Count": "20",
            },
        }).as("finalPage");
        // Scroll the dropdown again
        cy.get(".vs__dropdown-menu").scrollTo("bottom");
        cy.wait("@finalPage");

        // Select a  license that is not in the first page of results
        cy.get("#agreement_license_0 #license_id_0 .vs__search").type(
            "License 50{enter}",
            { force: true }
        );
        cy.get("#agreement_license_0").contains("License 50");

        // Re-open the dropdown, License 50 will no longer be in the dataset but the label should still show
        cy.intercept("GET", "/api/v1/erm/licenses*", {
            statusCode: 200,
            body: pageOne,
            headers: {
                "X-Base-Total-Count": "20",
                "X-Total-Count": "20",
            },
        });
        cy.get("#license_id_0 .vs__open-indicator").click();
        cy.get("#agreement_licenses").click();
        cy.get("#agreement_license_0").contains("License 50");

        // Select a different license
        cy.get("#license_id_0 .vs__open-indicator").click();
        cy.get("#agreement_license_0 #license_id_0 .vs__search").type(
            "License 10{enter}",
            { force: true }
        );
        cy.get("#agreement_license_0").contains("License 10");
    });

    it("Should correctly display the label when editing", () => {
        let agreement = cy.get_agreement();
        let agreements = [agreement];
        let licenses_to_relate = cy.get_licenses_to_relate();
        let vendors = cy.get_vendors_to_relate();

        // Intercept vendors request
        cy.intercept("GET", "/api/v1/acquisitions/vendors*", {
            statusCode: 200,
            body: vendors,
        }).as("get-vendor-options");

        // Intercept initial /agreements request once
        cy.intercept(
            {
                method: "GET",
                url: "/api/v1/erm/agreements*",
                times: 1,
            },
            {
                body: agreements,
            }
        );
        // Intercept follow-up 'search' request after entering /agreements
        cy.intercept("GET", "/api/v1/erm/agreements?_page*", {
            statusCode: 200,
            body: agreements,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("get-single-agreement-search-result");
        cy.visit("/cgi-bin/koha/erm/agreements");
        cy.wait("@get-single-agreement-search-result");

        // Intercept request after edit click
        cy.intercept("GET", "/api/v1/erm/agreements/*", agreement).as(
            "get-agreement"
        );

        // Intercept related licenses request after entering agreement edit
        let licenses_count = licenses_to_relate.length.toString();
        cy.intercept("GET", "/api/v1/erm/licenses*", {
            statusCode: 200,
            body: licenses_to_relate,
            headers: {
                "X-Base-Total-Count": licenses_count,
                "X-Total-Count": licenses_count,
            },
        }).as("get-related-licenses");

        // Intercept related agreements request after entering agreement edit
        cy.intercept("GET", "/api/v1/erm/agreements*", {
            statusCode: 200,
            body: cy.get_agreements_to_relate(),
        }).as("get-related-agreements");

        // Click the 'Edit' button from the list
        cy.get("#agreements_list table tbody tr:first")
            .contains("Edit")
            .click();
        cy.wait("@get-agreement");
        cy.wait(500); // Cypress is too fast! Vue hasn't populated the form yet!

        // Licenses should be labelled correctly
        cy.get("#agreement_license_0 #license_id_0 .vs__selected").contains(
            "first license name"
        );
        cy.get("#agreement_license_1 #license_id_1 .vs__selected").contains(
            "second license name"
        );
    });
});
