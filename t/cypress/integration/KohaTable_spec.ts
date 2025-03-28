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

function mock_table_settings(settings, table_settings_var) {
    cy.window().then(win => {
        let table_settings =
            typeof table_settings_var === "undefined"
                ? win.table_settings
                : table_settings_var
                      .split(".")
                      .reduce((acc, key) => acc[key], win);

        table_settings.columns = table_settings.columns.map(c => ({
            ...c,
            is_hidden: 0,
            cannot_be_toggled: 0,
        }));
        if (settings && settings.hasOwnProperty("default_save_state")) {
            table_settings.default_save_state = settings.default_save_state;
        }
        if (settings && settings.hasOwnProperty("default_save_state_search")) {
            table_settings.default_save_state_search =
                settings.default_save_state_search;
        }

        if (settings && settings.columns) {
            Object.entries(settings.columns).forEach(([name, values]) => {
                let column = table_settings.columns.find(
                    cc => cc.columnname == name
                );
                Object.entries(values).forEach(([prop, value]) => {
                    column[prop] = value;
                });
            });
        }
        cy.wrap(table_settings.columns).as("columns");
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

                mock_table_settings();
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

                mock_table_settings({
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

                mock_table_settings({
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

                mock_table_settings({
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

                mock_table_settings({
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

                mock_table_settings({
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

                mock_table_settings({
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

describe("Hit all tables", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.window().then(win => {
            win.localStorage.clear();
        });
    });

    describe("catalogue/detail/holdings_table", () => {
        const table_id = "holdings_table";
        beforeEach(() => {
            // FIXME All the following code should not be reused as it
            // It must be moved to a Cypress command or task "buildSampleBiblio" or even "insertSampleBiblio"
            let generated_objects = {};
            const objects = [{ object: "library" }, { object: "item_type" }];
            cy.wrap(Promise.resolve())
                .then(() => {
                    return objects.reduce((chain, { object }) => {
                        return chain.then(() => {
                            return cy
                                .task("buildSampleObject", { object })
                                .then(attributes => {
                                    generated_objects[object] = attributes;
                                });
                        });
                    }, Promise.resolve());
                })
                .then(() => {
                    const library = generated_objects["library"];
                    const item_type = generated_objects["item_type"];
                    const queries = [
                        {
                            query: "INSERT INTO branches(branchcode, branchname) VALUES (?, ?)",
                            values: [library.library_id, library.name],
                        },
                        {
                            query: "INSERT INTO itemtypes(itemtype, description) VALUES (?, ?)",
                            values: [
                                item_type.item_type_id,
                                item_type.description,
                            ],
                        },
                    ];
                    cy.wrap(Promise.resolve())
                        .then(() => {
                            return queries.reduce(
                                (chain, { query, values }) => {
                                    return chain.then(() =>
                                        cy.query(query, values)
                                    );
                                },
                                Promise.resolve()
                            );
                        })
                        .then(() => {
                            let biblio = {
                                leader: "     nam a22     7a 4500",
                                fields: [
                                    { "005": "20250120101920.0" },
                                    {
                                        "245": {
                                            ind1: "",
                                            ind2: "",
                                            subfields: [
                                                { a: "Some boring read" },
                                            ],
                                        },
                                    },
                                    {
                                        "100": {
                                            ind1: "",
                                            ind2: "",
                                            subfields: [
                                                { c: "Some boring author" },
                                            ],
                                        },
                                    },
                                    {
                                        "942": {
                                            ind1: "",
                                            ind2: "",
                                            subfields: [
                                                { c: item_type.item_type_id },
                                            ],
                                        },
                                    },
                                ],
                            };
                            cy.request({
                                method: "POST",
                                url: "/api/v1/biblios",
                                headers: {
                                    "Content-Type": "application/marc-in-json",
                                    "x-confirm-not-duplicate": 1,
                                },
                                body: biblio,
                            }).then(response => {
                                const biblio_id = response.body.id;
                                cy.wrap(biblio_id).as("biblio_id");
                                cy.request({
                                    method: "POST",
                                    url: `/api/v1/biblios/${biblio_id}/items`,
                                    headers: {
                                        "Content-Type": "application/json",
                                    },
                                    body: {
                                        home_library_id: library.library_id,
                                        holding_library_id: library.library_id,
                                    },
                                });
                            });
                        });
                });
            cy.query(
                "SELECT value FROM systempreferences WHERE variable='AlwaysShowHoldingsTableFilters'"
            ).then(value => {
                cy.wrap(value).as("syspref_AlwaysShowHoldingsTableFilters");
            });
        });

        afterEach(
            () =>
                function () {
                    cleanup();
                    cy.set_syspref(
                        "AlwaysShowHoldingsTableFilters",
                        this.syspref_AlwaysShowHoldingsTableFilters
                    );
                }
        );

        it("Correctly init the table", function () {
            // Do not use `() => {` or this.biblio_id won't be retrieved
            const biblio_id = this.biblio_id;
            cy.task("buildSampleObjects", {
                object: "item",
                count: RESTdefaultPageSize,
                values: {
                    biblio_id,
                    checkout: null,
                    transfer: null,
                    lost_status: 0,
                    withdrawn: 0,
                    damaged_status: 0,
                    not_for_loan_status: 0,
                    course_item: null,
                    cover_image_ids: [],
                },
            }).then(items => {
                cy.intercept("get", `/api/v1/biblios/${biblio_id}/items*`, {
                    statuscode: 200,
                    body: items,
                    headers: {
                        "X-Base-Total-Count": baseTotalCount,
                        "X-Total-Count": baseTotalCount,
                    },
                });

                cy.visit(
                    "/cgi-bin/koha/catalogue/detail.pl?biblionumber=" +
                        biblio_id
                );

                cy.window().then(win => {
                    win.libraries_map = items.reduce((map, i) => {
                        map[i.library_id] = i.library_id;
                        return map;
                    }, {});
                });

                cy.get(`#${table_id}_wrapper tbody tr`).should(
                    "have.length",
                    RESTdefaultPageSize
                );

                cy.get(`#${table_id}_wrapper .dt-info`).contains(
                    `Showing 1 to ${RESTdefaultPageSize} of ${baseTotalCount} entries`
                );
            });
        });

        it("Show filters", function () {
            // Do not use `() => {` or this.biblio_id won't be retrieved
            const biblio_id = this.biblio_id;
            cy.task("buildSampleObjects", {
                object: "item",
                count: RESTdefaultPageSize,
                values: {
                    biblio_id,
                    checkout: null,
                    transfer: null,
                    lost_status: 0,
                    withdrawn: 0,
                    damaged_status: 0,
                    not_for_loan_status: 0,
                    course_item: null,
                    cover_image_ids: [],
                },
            }).then(items => {
                cy.intercept("get", `/api/v1/biblios/${biblio_id}/items*`, {
                    statuscode: 200,
                    body: items,
                    headers: {
                        "X-Base-Total-Count": baseTotalCount,
                        "X-Total-Count": baseTotalCount,
                    },
                });

                cy.set_syspref("AlwaysShowHoldingsTableFilters", 0).then(() => {
                    cy.visit(
                        "/cgi-bin/koha/catalogue/detail.pl?biblionumber=" +
                            biblio_id
                    );

                    // Hide the 'URL' column
                    mock_table_settings(
                        {
                            columns: { uri: { is_hidden: 1 } },
                        },
                        "items_table_settings.holdings"
                    );

                    cy.window().then(win => {
                        win.libraries_map = items.reduce((map, i) => {
                            map[i.library_id] = i.library_id;
                            return map;
                        }, {});
                    });

                    cy.get("@columns").then(columns => {
                        cy.get(`#${table_id}_wrapper tbody tr`).should(
                            "have.length",
                            RESTdefaultPageSize
                        );

                        // Filters are not displayed
                        cy.get(`#${table_id} thead tr`).should(
                            "have.length",
                            1
                        );

                        cy.get(`#${table_id} th`).contains("Status");
                        cy.get(`#${table_id} th`)
                            .contains("URL")
                            .should("not.exist");
                        cy.get(`#${table_id} th`)
                            .contains("Course reserves")
                            .should("not.exist");

                        cy.get(".show_filters").click();
                        cy.get(`#${table_id}_wrapper .dt-info`).contains(
                            `Showing 1 to ${RESTdefaultPageSize} of ${baseTotalCount} entries`
                        );
                        // Filters are displayed
                        cy.get(`#${table_id} thead tr`).should(
                            "have.length",
                            2
                        );

                        cy.get(`#${table_id} th`).contains("Status");
                        cy.get(`#${table_id} th`)
                            .contains("URL")
                            .should("not.exist");
                        cy.get(`#${table_id} th`)
                            .contains("Course reserves")
                            .should("not.exist");
                    });
                });

                cy.set_syspref("AlwaysShowHoldingsTableFilters", 1).then(() => {
                    cy.visit(
                        "/cgi-bin/koha/catalogue/detail.pl?biblionumber=" +
                            biblio_id
                    );

                    // Hide the 'URL' column
                    mock_table_settings(
                        {
                            columns: { uri: { is_hidden: 1 } },
                        },
                        "items_table_settings.holdings"
                    );

                    cy.window().then(win => {
                        win.libraries_map = items.reduce((map, i) => {
                            map[i.library_id] = i.library_id;
                            return map;
                        }, {});
                    });

                    cy.get("@columns").then(columns => {
                        cy.get(`#${table_id}_wrapper tbody tr`).should(
                            "have.length",
                            RESTdefaultPageSize
                        );

                        // Filters are displayed
                        cy.get(`#${table_id} thead tr`).should(
                            "have.length",
                            2
                        );

                        cy.get(".hide_filters").click();

                        // Filters are not displayed
                        cy.get(`#${table_id} thead tr`).should(
                            "have.length",
                            1
                        );
                    });
                });
            });
        });
    });
});
