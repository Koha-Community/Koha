import { mount } from "@cypress/vue";

describe("kohaTable (using REST API)", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    afterEach(() => {});

    const RESTdefaultPageSize = "20"; // FIXME Mock this
    const baseTotalCount = "42";

    describe("Simple tables", () => {
        const table_id = "libraries";

        it("Input search bar and clear filter ", () => {
            cy.task("buildSampleObjects", {
                object: "library",
                count: RESTdefaultPageSize,
                values: { library_hours: [] },
            }).then(libraries => {
                cy.intercept("GET", "/api/v1/libraries*", {
                    statusCode: 200,
                    body: libraries,
                    headers: {
                        "X-Base-Total-Count": baseTotalCount,
                        "X-Total-Count": baseTotalCount,
                    },
                });

                cy.visit("/cgi-bin/koha/admin/branches.pl");

                cy.get(`#${table_id}_wrapper .dt-info`).contains(
                    `Showing 1 to ${RESTdefaultPageSize} of ${baseTotalCount} entries`
                );

                // Should be disabled by default - empty search bar
                cy.get(`#${table_id}_wrapper .dt_button_clear_filter`).should(
                    "have.class",
                    "disabled"
                );

                // Type something in the input search bar
                cy.get(`#${table_id}_wrapper input.dt-input`).type(
                    "centerville"
                );
                cy.get(`#${table_id}_wrapper input.dt-input`).should(
                    "have.value",
                    "centerville"
                );

                // Should no longer be disabled
                cy.get(`#${table_id}_wrapper .dt_button_clear_filter`).should(
                    "not.have.class",
                    "disabled"
                );

                // Click the clear_filter button
                cy.get(`#${table_id}_wrapper .dt_button_clear_filter`).click();
                cy.get(`#${table_id}_wrapper input.dt-input`).should(
                    "have.value",
                    ""
                );
            });
        });
    });

    describe("Patrons search", () => {
        const table_id = "memberresultst";

        it("Input search bar and clear filter ", () => {
            cy.task("buildSampleObjects", {
                object: "patron",
                count: RESTdefaultPageSize,
                values: {},
            }).then(patrons => {
                // Needs more properties to not explode
                // account_balace: balance_str.escapeHtml(...).format_price is not a function
                patrons = patrons.map(p => ({ ...p, account_balance: 0 }));

                cy.intercept("GET", "/api/v1/patrons*", {
                    statusCode: 200,
                    body: patrons,
                    headers: {
                        "X-Base-Total-Count": baseTotalCount,
                        "X-Total-Count": baseTotalCount,
                    },
                });

                cy.visit("/cgi-bin/koha/members/members-home.pl");

                cy.window().then(win => {
                    win.categories_map = patrons.reduce((map, p) => {
                        map[p.category_id] = p.category_id;
                        return map;
                    }, {});
                });
                cy.get("form.patron_search_form input[type='submit']").click();

                cy.get(`#${table_id}_wrapper .dt-info`).contains(
                    `Showing 1 to ${RESTdefaultPageSize} of ${baseTotalCount} entries`
                );

                // Should be disabled by default - empty search bar
                cy.get(`#${table_id}_wrapper .dt_button_clear_filter`).should(
                    "have.class",
                    "disabled"
                );

                // Type something in the input search bar
                cy.get(`#${table_id}_wrapper input.dt-input`).type(
                    "edna",
                    { force: true } // Needs to force because of sticky header? It's not clear what's happening, Cypress bug?
                );
                cy.get(`#${table_id}_wrapper input.dt-input`).should(
                    "have.value",
                    "edna"
                );

                // Should no longer be disabled
                cy.get(`#${table_id}_wrapper .dt_button_clear_filter`).should(
                    "not.have.class",
                    "disabled"
                );

                // Click the clear_filter button
                cy.get(`#${table_id}_wrapper .dt_button_clear_filter`).click({
                    force: true,
                }); // #searchheader is on top of it
                cy.get(`#${table_id}_wrapper input.dt-input`).should(
                    "have.value",
                    ""
                );
            });
        });
    });
});

describe("ERM ", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.intercept(
            "GET",
            "/api/v1/erm/config",
            '{"settings":{"ERMModule":"1","ERMProviders":["local"]}}'
        );
    });

    it("Local titles", () => {
        const container_id = "title_list_result";
        it("Input search bar and clear filter ", () => {
            let erm_title = cy.get_title();
            let titles = [erm_title];

            cy.intercept("GET", "/api/v1/erm/eholdings/local/titles*", {
                statusCode: 200,
                body: titles,
                headers: {
                    "X-Base-Total-Count": "1",
                    "X-Total-Count": "1",
                },
            }).as("get_titles");

            cy.visit("/cgi-bin/koha/erm/eholdings/local/titles");
            cy.get("#titles_list").contains("Showing 1 to 1 of 1 entries");
            cy.get(`#${container_id} .dt-info`).contains(
                `Showing 1 to 1 of 1 entries`
            );

            // Should be disabled by default - empty search bar
            cy.get(`#${container_id} .dt_button_clear_filter`).should(
                "have.class",
                "disabled"
            );

            // Type something in the input search bar
            cy.get(`#${container_id} input.dt-input`).type(
                erm_title.publication_title
            );
            cy.get(`#${container_id} input.dt-input`).type(
                "have.value",
                erm_title.publication_title
            );

            // Should no longer be disabled
            cy.get(`#${container_id} .dt_button_clear_filter`).should(
                "not.have.class",
                "disabled"
            );

            // Click the clear_filter button
            cy.get(`#${container_id} .dt_button_clear_filter`).click();
            cy.get(`#${container_id} input.dt-input`).should("have.value", "");

            // TODO: Some actual live API with data requests to test the search actually works
            // and returns results accordingly (or not)
        });
    });
});
