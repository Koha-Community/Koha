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

        it("User choices are kept in the state - Save state is ON, search state is OFF", () => {
            const state_key = "DataTables_admin_libraries_libraries";

            build_libraries().then(() => {
                cy.visit("/cgi-bin/koha/admin/branches.pl");

                cy.mock_table_settings({
                    default_save_state: 1,
                    default_save_state_search: 0,
                });

                // Hide "Code"
                cy.get(`#${table_id}_wrapper .buttons-colvis`).click();
                cy.get(`#${table_id}_wrapper .dt-button-collection`)
                    .contains("Code")
                    .click();

                cy.window().then(win => {
                    const state = JSON.parse(
                        win.localStorage.getItem(state_key)
                    );
                    expect(state.user_choices).to.deep.equal({ 1: false });
                });

                // The state is saved on every draw, the user choices must not
                // be dropped by the draws of the next page load
                cy.visit("/cgi-bin/koha/admin/branches.pl");

                cy.mock_table_settings({
                    default_save_state: 1,
                    default_save_state_search: 0,
                });

                cy.get(`#${table_id}_wrapper .dt-info`).contains(
                    `Showing 1 to ${RESTdefaultPageSize} of ${baseTotalCount} entries`
                );

                cy.window().then(win => {
                    const state = JSON.parse(
                        win.localStorage.getItem(state_key)
                    );
                    expect(state.user_choices).to.deep.equal({ 1: false });
                });
            });
        });

        it("One column hidden, feature is off {visibility_condition: false} - Save state is ON", () => {
            build_libraries().then(() => {
                cy.visit("/cgi-bin/koha/admin/branches.pl");

                cy.mock_table_settings({
                    default_save_state: 1,
                    columns: {
                        library_code: {
                            is_hidden: true,
                            visibility_condition: false,
                        },
                    },
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
                    // The feature is off, the column cannot be displayed
                    cy.get(`#${table_id}_wrapper .dt-button-collection`)
                        .contains("Code")
                        .should("not.exist");
                });
            });
        });

        it("Force visibility of one column", () => {
            build_libraries().then(() => {
                cy.visit("/cgi-bin/koha/admin/branches.pl");

                // default settings: show "Code"
                cy.mock_table_settings({
                    default_save_state: 1,
                    columns: { library_code: { is_hidden: false } },
                });

                cy.get("@columns").then(columns => {
                    cy.get(`#${table_id} th`).should(
                        "have.length",
                        columns.length
                    );
                    cy.get(`#${table_id} th`).contains("Name");
                    cy.get(`#${table_id} th`).contains("Code");

                    // Hide "Code"
                    cy.get(`#${table_id}_wrapper .buttons-colvis`).click();
                    cy.get(`#${table_id}_wrapper .dt-button-collection`)
                        .contains("Code")
                        .click();
                    cy.get(`#${table_id} th`).should(
                        "have.length",
                        columns.length - 1
                    );
                    cy.get(`#${table_id} th`).contains("Name");
                    cy.get(`#${table_id} th`)
                        .contains("Code")
                        .should("not.exist");
                });

                // "Code" has been hidden by the user
                cy.visit("/cgi-bin/koha/admin/branches.pl");

                // But we want to display it
                cy.mock_table_settings({
                    default_save_state: 1,
                    columns: {
                        library_code: {
                            is_hidden: false,
                            visibility_condition: true,
                        },
                    },
                });

                cy.get("@columns").then(columns => {
                    cy.get(`#${table_id} th`).should(
                        "have.length",
                        columns.length
                    );
                    // Both are shown
                    cy.get(`#${table_id} th`).contains("Name");
                    cy.get(`#${table_id} th`).contains("Code");
                });

                // Now hide it
                cy.visit("/cgi-bin/koha/admin/branches.pl");

                cy.mock_table_settings({
                    default_save_state: 1,
                    columns: {
                        library_code: {
                            is_hidden: false,
                            visibility_condition: true,
                        },
                    },
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
                });
            });
        });

        it("visibility_condition {visibility_condition: true, is_hidden: true}", () => {
            build_libraries().then(() => {
                cy.visit("/cgi-bin/koha/admin/branches.pl");

                // default settings: hide "Code"
                cy.mock_table_settings({
                    default_save_state: 1,
                    columns: {
                        library_code: {
                            visibility_condition: true,
                            is_hidden: true,
                        },
                    },
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
                });

                // Do not touch anything
                // Should be kept hidden after reload
                cy.visit("/cgi-bin/koha/admin/branches.pl");

                cy.get("@columns").then(columns => {
                    cy.get(`#${table_id} th`).should(
                        "have.length",
                        columns.length - 1
                    );
                    cy.get(`#${table_id} th`).contains("Name");
                    cy.get(`#${table_id} th`)
                        .contains("Code")
                        .should("not.exist");
                });
            });
        });

        it("visibility_condition modified, cannot_be_toggled", () => {
            build_libraries().then(() => {
                cy.visit("/cgi-bin/koha/admin/branches.pl");

                // default settings: Show "Code" and cannot be toggled, but feature is off (visibility_condition=false)
                cy.mock_table_settings({
                    default_save_state: 1,
                    columns: {
                        library_code: {
                            visibility_condition: false,
                            is_hidden: false,
                            cannot_be_toggled: true,
                        },
                    },
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
                });

                // Do not touch anything
                // But turn on the feature that would display the column
                // Should be displayed after reload
                // This is the behaviour for the Export column of the checkouts table, and syspref ExportCircHistory
                cy.mock_table_settings({
                    default_save_state: 1,
                    columns: {
                        library_code: {
                            visibility_condition: true,
                            is_hidden: false,
                            cannot_be_toggled: true,
                        },
                    },
                });

                cy.visit("/cgi-bin/koha/admin/branches.pl");

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

        it("visibility_condition modified, can be toggled", () => {
            build_libraries().then(() => {
                cy.visit("/cgi-bin/koha/admin/branches.pl");

                // default settings: Show "Code" and can be toggled, but feature is off (visibility_condition=false)
                cy.mock_table_settings({
                    default_save_state: 1,
                    columns: {
                        library_code: {
                            visibility_condition: false,
                            is_hidden: false,
                            cannot_be_toggled: false,
                        },
                    },
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
                });

                // Do not touch anything
                // But turn on a syspref that would display the column
                // Should be kept hidden after reload
                cy.mock_table_settings({
                    default_save_state: 1,
                    columns: {
                        library_code: {
                            visibility_condition: true,
                            is_hidden: false,
                            cannot_be_toggled: false,
                        },
                    },
                });

                cy.visit("/cgi-bin/koha/admin/branches.pl");

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

            cy.get("#admin_panel")
                .contains("Table id: libraries")
                .should("be.visible");

            cy.window().its("scrollY").should("be.gt", 0); // Ensure some scrolling happened
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

        it("Prevent XSS when using description", () => {
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

                cy.get("#search_patron_filter").type(
                    "<script>alert('boo');</script>"
                );
                cy.window().then(win => {
                    win.categories_map = patrons.reduce((map, p) => {
                        map[p.category_id.toLowerCase()] = p.category_id;
                        return map;
                    }, {});
                });
                cy.get("form.patron_search_form .branchcode_filter").select(
                    "CPL"
                );
                cy.get("form.patron_search_form input[type='submit']").click();

                cy.get(`#${table_id}_wrapper .dt-info`).contains(
                    `Showing 1 to ${RESTdefaultPageSize} of ${baseTotalCount} entries`
                );
                cy.get("#searchresults .search_description").contains(
                    "Standard starting with '<script>alert('boo');</script>'"
                );
            });
        });
    });

    describe("Coded values search - existing holds table", () => {
        // Libraries with a code that is not part of the description
        const libraries = [
            { library_id: "ZQA", name: "Sparkly Unicorn Land" },
            { library_id: "ZQB", name: "Grumpy Dragon Cave" },
            // The description contains the code of another library
            { library_id: "ZQC", name: "Contains zqa inside" },
        ];
        let table;

        beforeEach(() => {
            cy.task("query", {
                sql: "SELECT value FROM systempreferences WHERE variable='HoldsSplitQueue'",
            }).then(value => {
                cy.wrap(value).as("syspref_HoldsSplitQueue");
            });
            cy.set_syspref("HoldsSplitQueue", "nothing");

            cy.wrap([]).as("inserted_libraries");
            libraries.forEach(values => {
                cy.task("buildSampleObject", {
                    object: "library",
                    values,
                })
                    .then(generated =>
                        cy.task("insertObject", {
                            type: "library",
                            object: generated,
                        })
                    )
                    .then(library => {
                        cy.get("@inserted_libraries").then(l =>
                            l.push(library)
                        );
                    });
            });

            cy.task("insertSampleBiblio", { item_count: 1 }).then(objects => {
                cy.wrap(objects).as("objects_biblio");
                table = `patron_holds_table_${objects.biblio.biblio_id}_any`;
                libraries.forEach((library, i) => {
                    cy.task("insertSampleHold", {
                        biblio: objects.biblio,
                        library_id: library.library_id,
                    }).then(hold => {
                        cy.wrap(hold).as(`objects_hold_${i}`);
                    });
                });
            });
        });

        afterEach(function () {
            cy.task("deleteSampleObjects", [
                this.objects_hold_0,
                this.objects_hold_1,
                this.objects_hold_2,
                this.objects_biblio,
                { libraries: this.inserted_libraries },
            ]);
            cy.set_syspref("HoldsSplitQueue", this.syspref_HoldsSplitQueue);
        });

        function search(term) {
            cy.get(`#${table}_wrapper input.dt-input`).clear();
            if (term) {
                cy.get(`#${table}_wrapper input.dt-input`).type(term, {
                    force: true,
                });
            }
        }

        // Holds displayed in the table, by hold_id
        function expect_holds(...expected) {
            cy.get(`#${table} tbody tr .select_hold`).should($checkboxes => {
                const ids = $checkboxes
                    .toArray()
                    .map(c => Number(c.dataset.id));
                expect(ids).to.have.members(expected);
            });
        }

        // Typing triggers several requests, get the one carrying the term
        function query_for(calls, term) {
            // The url already has a q, kohaTable adds its own
            const queries = calls
                .flatMap(c => new URL(c.request.url).searchParams.getAll("q"))
                .filter(q => q.includes(term));
            return queries.length ? queries.pop() : null;
        }

        function visit_request_page() {
            cy.get("@objects_biblio").then(objects => {
                cy.intercept("GET", "/api/v1/holds/**").as("get-holds");
                cy.visit(
                    `/cgi-bin/koha/reserve/request.pl?biblionumber=${objects.biblio.biblio_id}`
                );
                cy.wait("@get-holds");
            });
        }

        it("Filters by code and description", function () {
            const hold_a = this.objects_hold_0.hold.hold_id;
            const hold_b = this.objects_hold_1.hold.hold_id;
            const hold_c = this.objects_hold_2.hold.hold_id;
            visit_request_page();
            expect_holds(hold_a, hold_b, hold_c);

            // Code
            search("ZQB");
            expect_holds(hold_b);

            // Code of a library and part of the description of another one
            search("ZQA");
            expect_holds(hold_a, hold_c);

            // Beginning of the description
            search("Sparkly");
            expect_holds(hold_a);

            // Not the beginning of the description
            search("Unicorn");
            expect_holds(hold_a);

            // Whole description, regardless of the case
            search("sparkly UNICORN land");
            expect_holds(hold_a);

            // The other library
            search("Dragon");
            expect_holds(hold_b);

            // Beginning of the codes
            search("ZQ");
            expect_holds(hold_a, hold_b, hold_c);

            // Nothing matches
            search("Nothing like this");
            cy.get(`#${table} tbody tr .select_hold`).should("not.exist");

            // Back to the full list
            search("");
            expect_holds(hold_a, hold_b, hold_c);
        });

        it("Does not interpret the search as a regular expression", function () {
            const hold_a = this.objects_hold_0.hold.hold_id;
            const hold_b = this.objects_hold_1.hold.hold_id;
            visit_request_page();

            search(".*");
            cy.get(`#${table} tbody tr .select_hold`).should("not.exist");

            search("[");
            cy.get(`#${table} tbody tr .select_hold`).should("not.exist");

            search("Unicorn");
            expect_holds(hold_a);
        });

        it("Sends the codes matching the description", function () {
            visit_request_page();

            search("Unicorn");
            cy.get("@get-holds.all").should(calls => {
                expect(query_for(calls, "Unicorn")).to.not.be.null;
            });
            cy.get("@get-holds.all").then(calls => {
                expect(query_for(calls, "Unicorn")).to.contain(
                    '"me.pickup_library_id":["ZQA"]'
                );
            });
        });

        it("Sends a like on the code when no description matches", function () {
            visit_request_page();

            search("ZQB");
            cy.get("@get-holds.all").should(calls => {
                expect(query_for(calls, "ZQB")).to.not.be.null;
            });
            cy.get("@get-holds.all").then(calls => {
                expect(query_for(calls, "ZQB")).to.contain(
                    '"me.pickup_library_id":{"like":"%ZQB%"}'
                );
            });
        });

        it("Sends the codes and a like on the code when both match", function () {
            visit_request_page();

            search("ZQA");
            cy.get("@get-holds.all").should(calls => {
                expect(query_for(calls, "ZQA")).to.not.be.null;
            });
            cy.get("@get-holds.all").then(calls => {
                expect(query_for(calls, "ZQA")).to.contain(
                    '"me.pickup_library_id":["ZQC",{"like":"%ZQA%"}]'
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

    it("Prevent XSS in column filters", () => {
        const xss_name = '<img src=x onerror="window.xss_triggered=true">';

        let agreement = cy.get_agreement();
        let vendors = cy.get_vendors_to_relate();
        vendors[0].name = xss_name;
        agreement.vendor = [vendors[0]];

        cy.intercept("GET", "/api/v1/acquisitions/vendors*", {
            statusCode: 200,
            body: vendors,
        });
        cy.intercept("GET", "/api/v1/erm/agreements*", {
            statusCode: 200,
            body: [agreement],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });

        cy.visit("/cgi-bin/koha/erm/agreements");
        cy.get("#agreements_list").contains("Showing 1 to 1 of 1 entries");

        cy.get("#agreements_list select.dt-select-filter option")
            .contains(xss_name)
            .should("exist");
        cy.get("#agreements_list select.dt-select-filter option img").should(
            "not.exist"
        );
        cy.window().its("xss_triggered").should("be.undefined");
    });
});

describe("Itemtypes", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.task("buildSampleObjects", {
            object: "item_type",
            count: RESTdefaultPageSize,
        }).then(itemtypes => {
            itemtypes.forEach(itemtype => {
                cy.task("insertObject", {
                    type: "item_type",
                    object: itemtype,
                });
            });
            cy.wrap(itemtypes).as("itemtypes");
        });
    });

    afterEach(function () {
        cy.task("deleteSampleObjects", [this.itemtypes]);
    });

    const table_id = "table_item_type";
    it("Next && pageLength", function () {
        cy.visit("/cgi-bin/koha/admin/itemtypes.pl");

        cy.task("query", {
            sql: "SELECT COUNT(*) as count FROM itemtypes",
        }).then(result => {
            cy.get(`#${table_id}_wrapper .dt-info`).contains(
                `Showing 1 to 10 of ${result[0].count} entries`
            );

            cy.get(
                `#${table_id}_wrapper .top.pager .dt-paging-button.next`
            ).click();
            cy.get(`#${table_id}_wrapper .dt-info`).contains(
                `Showing 11 to 20 of ${result[0].count} entries`
            );
        });
    });
});
