import { mount } from "@cypress/vue";

const RESTdefaultPageSize = "20"; // FIXME Mock this
const baseTotalCount = "42";

function build_libraries() {
    return cy
        .task("buildSampleObjects", {
            object: "library",
            count: RESTdefaultPageSize,
            values: { library_hours: [] },
        })
        .then(libraries => {
            cy.intercept("GET", "/api/v1/libraries*", {
                statusCode: 200,
                body: libraries,
                headers: {
                    "X-Base-Total-Count": baseTotalCount,
                    "X-Total-Count": baseTotalCount,
                },
            });
        });
}

describe("kohaTable (using REST API)", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.window().then(win => {
            win.localStorage.clear();
        });
    });

    afterEach(() => {});

    describe("Simple tables", () => {
        const table_id = "libraries";

        it("Input search bar and clear filter ", () => {
            build_libraries().then(() => {
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

        it("All columns displayed", () => {
            build_libraries().then(() => {
                cy.visit("/cgi-bin/koha/admin/branches.pl");

                cy.mock_table_settings();
                cy.get("@columns").then(columns => {
                    cy.get(`#${table_id} th`).should(
                        "have.length",
                        columns.length
                    );
                });
            });
        });

        it("One column hidden by default", () => {
            build_libraries().then(() => {
                cy.visit("/cgi-bin/koha/admin/branches.pl");

                cy.mock_table_settings({
                    columns: { library_code: { is_hidden: 1 } },
                });

                cy.get("@columns").then(columns => {
                    cy.get(`#${table_id} th`).should(
                        "have.length",
                        columns.length - 1
                    );
                });

                cy.get(`#${table_id} th`).contains("Name");
                cy.get(`#${table_id} th`).contains("Code").should("not.exist");
            });
        });

        it("One column hidden by default then shown by user - Save state OFF", () => {
            build_libraries().then(() => {
                cy.visit("/cgi-bin/koha/admin/branches.pl");

                cy.mock_table_settings({
                    default_save_state: 0,
                    columns: { library_code: { is_hidden: 1 } },
                });

                cy.get("@columns").then(columns => {
                    cy.get(`#${table_id} th`).should(
                        "have.length",
                        columns.length - 1
                    );
                    cy.get(`#${table_id} th`).contains("Name");
                    cy.get(`#${table_id} th`)
                        .contains("Code")
                        .should("not.exist");
                    cy.get(`#${table_id}_wrapper .buttons-colvis`).click();
                    cy.get(`#${table_id}_wrapper .dt-button-collection`)
                        .contains("Code")
                        .click();
                    cy.get(`#${table_id} th`).should(
                        "have.length",
                        columns.length
                    );
                    cy.get(`#${table_id} th`).contains("Name");
                    cy.get(`#${table_id} th`).contains("Code");
                });

                cy.visit("/cgi-bin/koha/admin/branches.pl");

                cy.mock_table_settings({
                    default_save_state: 0,
                    columns: { library_code: { is_hidden: 1 } },
                });

                cy.get("@columns").then(columns => {
                    cy.get(`#${table_id} th`).should(
                        "have.length",
                        columns.length
                    );
                    cy.get(`#${table_id} th`).contains("Name");
                    cy.get(`#${table_id} th`)
                        .contains("Code")
                        .should("not.exist");
                });
            });
        });

        it("One column hidden by default then shown by user - Save state is ON", () => {
            build_libraries().then(() => {
                cy.visit("/cgi-bin/koha/admin/branches.pl");

                cy.mock_table_settings({
                    default_save_state: 1,
                    columns: { library_code: { is_hidden: 1 } },
                });

                cy.get("@columns").then(columns => {
                    cy.get(`#${table_id} th`).should(
                        "have.length",
                        columns.length - 1
                    );
                    cy.get(`#${table_id} th`).contains("Name");
                    cy.get(`#${table_id} th`)
                        .contains("Code")
                        .should("not.exist");
                    cy.get(`#${table_id}_wrapper .buttons-colvis`).click();
                    cy.get(`#${table_id}_wrapper .dt-button-collection`)
                        .contains("Code")
                        .click();
                    cy.get(`#${table_id} th`).should(
                        "have.length",
                        columns.length
                    );
                    cy.get(`#${table_id} th`).contains("Name");
                    cy.get(`#${table_id} th`).contains("Code");
                });

                cy.visit("/cgi-bin/koha/admin/branches.pl");

                cy.mock_table_settings({
                    default_save_state: 1,
                    columns: { library_code: { is_hidden: 1 } },
                });

                cy.get("@columns").then(columns => {
                    cy.get(`#${table_id} th`).should(
                        "have.length",
                        columns.length
                    );
                    cy.get(`#${table_id} th`).contains("Name");
                    cy.get(`#${table_id} th`).contains("Code");
                });
            });
        });

        it("Shareable link", { scrollBehavior: false }, () => {
            build_libraries().then(() => {
                cy.visit("/cgi-bin/koha/admin/branches.pl");

                cy.mock_table_settings({
                    default_save_state: 1,
                    columns: { library_code: { is_hidden: 1 } },
                });

                cy.get("@columns").then(columns => {
                    // Code is not shown
                    cy.get(`#${table_id} th`).should(
                        "have.length",
                        columns.length - 1
                    );
                    cy.get(`#${table_id} th`).contains("Name");
                    cy.get(`#${table_id} th`)
                        .contains("Code")
                        .should("not.exist");
                    cy.get(`#${table_id}_wrapper .buttons-colvis`).click();
                    // Show Code
                    cy.get(`#${table_id}_wrapper .dt-button-collection`)
                        .contains("Code")
                        .click();
                    cy.get(`#${table_id} th`).should(
                        "have.length",
                        columns.length
                    );
                    cy.get(`#${table_id} th`).contains("Name");
                    cy.get(`#${table_id} th`).contains("Code");
                });

                cy.window().then(win => {
                    // Copy the shareable link (Name and Code shown)
                    const url = win.build_url_with_state(
                        win.libraries_table.DataTable(),
                        win.table_settings
                    );
                    expect(url).to.match(
                        /branches.pl\?DataTables_admin_libraries_libraries_state=/
                    );

                    // Remove localStorage
                    win.localStorage.clear();

                    // Use it
                    cy.visit(url);

                    // Code is shown whereas it is hidden in the config
                    cy.get("@columns").then(columns => {
                        cy.get(`#${table_id} th`).should(
                            "have.length",
                            columns.length
                        );
                        cy.get(`#${table_id} th`).contains("Name");
                        cy.get(`#${table_id} th`).contains("Code");

                        // Hide "Name"
                        cy.get(`#${table_id}_wrapper .buttons-colvis`).click();
                        cy.get(`#${table_id}_wrapper .dt-button-collection`)
                            .contains("Name")
                            .click();
                    });

                    // Go to the shareable link
                    // but do not remove localStorage!
                    cy.visit(url);

                    // Name is hidden and Code is shown
                    cy.get("@columns").then(columns => {
                        cy.get(`#${table_id} th`).should(
                            "have.length",
                            columns.length
                        );

                        cy.get(`#${table_id} th`).contains("Name");
                        cy.get(`#${table_id} th`).contains("Code");
                    });
                });
            });
        });

        it("Jump to the configuration page", () => {
            cy.visit("/cgi-bin/koha/admin/branches.pl");
            cy.get(`#${table_id}_wrapper .dt_button_configure_table`).click();
            cy.url().should("contain", "module=admin");
            cy.url().should("contain", "page=libraries");
            cy.url().should("contain", "table=libraries");

            cy.wait(2000); // ensure the animation completes, random failures?
            cy.get("#admin_panel")
                .contains("Table id: libraries")
                .should("be.visible");

            cy.window().then(win => {
                const scrollTop = win.scrollY || win.pageYOffset;
                expect(scrollTop).to.be.greaterThan(0); // Ensure some scrolling happened
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
                        map[p.category_id.toLowerCase()] = p.category_id;
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

        it("Browse by last name", () => {
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
                        map[p.category_id.toLowerCase()] = p.category_id;
                        return map;
                    }, {});
                });

                cy.get("#searchresults .browse .filterByLetter:first").click();
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
