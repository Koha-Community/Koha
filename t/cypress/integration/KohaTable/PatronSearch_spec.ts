import { mount } from "@cypress/vue";

const RESTdefaultPageSize = "20"; // FIXME Mock this
const baseTotalCount = "42";

const ExtendedPatronAttributes = 42;

const patron_attr_type = "attribute_type4TEST";

function cleanup() {
    const sql = "DELETE FROM borrower_attribute_types WHERE code=?";
    cy.task("query", { sql, values: [patron_attr_type] });
}
describe("ExtendedPatronAttributes", () => {
    beforeEach(() => {
        cleanup();
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.window().then(win => {
            win.localStorage.clear();
        });
        cy.task("query", {
            sql: "SELECT value FROM systempreferences WHERE variable='ExtendedPatronAttributes'",
        }).then(value => {
            cy.wrap(value).as("syspref_ExtendedPatronAttributes");
        });
    });

    afterEach(function () {
        cleanup();
        cy.set_syspref(
            "ExtendedPatronAttributes",
            this.syspref_ExtendedPatronAttributes
        );
    });

    const table_id = "memberresultst";

    it("ExtendedPatronAttributes=0", () => {
        cy.intercept("GET", "/api/v1/patrons*").as("searchPatrons");

        cy.set_syspref("ExtendedPatronAttributes", 0).then(() => {
            cy.visit("/cgi-bin/koha/members/members-home.pl");

            cy.get("#search_patron_filter").type("something");
            cy.get("form.patron_search_form input[type='submit']").click();

            cy.task("query", {
                sql: "select count(*) as nb_searchable from borrower_attribute_types where staff_searchable=1",
            }).then(result => {
                const has_searchable = result[0].nb_searchable;
                cy.wait("@searchPatrons").then(interception => {
                    const q = interception.request.query.q;
                    expect(q).to.not.match(/extended_attributes/);
                });
            });

            cy.task("query", {
                sql: "INSERT INTO borrower_attribute_types(code, description, staff_searchable, searched_by_default) VALUES (?, 'only for tests', 1, 1)",
                values: [patron_attr_type],
            }).then(() => {
                cy.visit("/cgi-bin/koha/members/members-home.pl");

                cy.get("#search_patron_filter").type("something");
                cy.get("form.patron_search_form input[type='submit']").click();

                cy.wait("@searchPatrons").then(interception => {
                    const q = interception.request.query.q;
                    expect(q).to.not.match(/extended_attributes/);
                });
            });
        });
    });
    it("ExtendedPatronAttributes=1", () => {
        cy.intercept("GET", "/api/v1/patrons*").as("searchPatrons");

        cy.set_syspref("ExtendedPatronAttributes", 1).then(() => {
            cy.visit("/cgi-bin/koha/members/members-home.pl");

            cy.get("#search_patron_filter").type("something");
            cy.get("form.patron_search_form input[type='submit']").click();

            cy.task("query", {
                sql: "select count(*) as nb_searchable from borrower_attribute_types where staff_searchable=1 AND searched_by_default=1",
            }).then(result => {
                const has_searchable = result[0].nb_searchable;
                cy.wait("@searchPatrons").then(interception => {
                    const q = interception.request.query.q;
                    if (has_searchable) {
                        expect(q).to.match(/extended_attributes/);
                    } else {
                        expect(q).to.not.match(/extended_attributes/);
                    }
                });
            });

            cy.task("query", {
                sql: "INSERT INTO borrower_attribute_types(code, description, staff_searchable, searched_by_default) VALUES (?, 'only for tests', 1, 1)",
                values: [patron_attr_type],
            }).then(() => {
                cy.visit("/cgi-bin/koha/members/members-home.pl");

                cy.get("#search_patron_filter").type("something");
                cy.get("form.patron_search_form input[type='submit']").click();

                cy.wait("@searchPatrons").then(interception => {
                    const q = interception.request.query.q;
                    expect(q).to.match(/extended_attributes/);
                });
            });
        });
    });
});

describe("Filters", () => {
    const table_id = "memberresultst";

    beforeEach(() => {
        cleanup();
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.window().then(win => {
            win.localStorage.clear();
        });
    });

    it("Keep filters in the column filters", () => {
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
            cy.get("form.patron_search_form .branchcode_filter").select("CPL");
            cy.get("form.patron_search_form .categorycode_filter").select("S");
            cy.get("form.patron_search_form input[type='submit']").click();

            cy.get(`#${table_id}_wrapper .dt-info`).contains(
                `Showing 1 to ${RESTdefaultPageSize} of ${baseTotalCount} entries`
            );

            cy.get(`#${table_id}`).then($table => {
                const dt = $table.DataTable();
                const libraryCol = dt.column("library:name");
                const libraryVisibleIndex = libraryCol.index("visible");
                const categoryCol = dt.column("category:name");
                const categoryVisibleIndex = categoryCol.index("visible");

                cy.get(`#${table_id} thead tr`).should("have.length", 2);
                cy.get(`#${table_id} thead tr`)
                    .eq(1)
                    .find("th")
                    .eq(libraryVisibleIndex)
                    .find("select")
                    .should("have.value", "^CPL$");

                // Lowercase see bug 32517 and related code in datatables.js
                cy.get(`#${table_id} thead tr`)
                    .eq(1)
                    .find("th")
                    .eq(categoryVisibleIndex)
                    .find("select")
                    .should("have.value", "^s$");

                cy.get(`form.patron_search_form input.clear_search`).click();
                cy.get("form.patron_search_form input[type='submit']").click();
                cy.get(`#${table_id} thead tr`)
                    .eq(1)
                    .find("th")
                    .eq(libraryVisibleIndex)
                    .find("select")
                    .should("have.value", null);
                // Lowercase see bug 32517 and related code in datatables.js
                cy.get(`#${table_id} thead tr`)
                    .eq(1)
                    .find("th")
                    .eq(categoryVisibleIndex)
                    .find("select")
                    .should("have.value", null);
            });
        });
    });

    describe("Exact search for all attributes", () => {
        // In this case the library column is bind to library.name and library.library_id
        it("From the form", () => {
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
                }).as("searchPatrons");

                cy.visit("/cgi-bin/koha/members/members-home.pl");

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

                cy.wait("@searchPatrons").then(interception => {
                    const q = interception.request.query.q;
                    expect(q).to.equal(
                        '[{"library.name":"CPL"},{"me.library_id":"CPL"}]'
                    );
                });
            });
        });

        it("From the column filter", () => {
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
                }).as("searchPatrons");

                cy.visit("/cgi-bin/koha/members/members-home.pl");

                cy.window().then(win => {
                    win.categories_map = patrons.reduce((map, p) => {
                        map[p.category_id.toLowerCase()] = p.category_id;
                        return map;
                    }, {});
                });

                cy.get("form.patron_search_form input[type='submit']").click();

                cy.wait("@searchPatrons");

                cy.get(`#${table_id}`).then($table => {
                    const dt = $table.DataTable();
                    const libraryCol = dt.column("library:name");
                    const libraryVisibleIndex = libraryCol.index("visible");
                    cy.get(`#${table_id} thead tr`)
                        .eq(1)
                        .find("th")
                        .eq(libraryVisibleIndex)
                        .find("select")
                        .select("^CPL$");
                });

                cy.wait("@searchPatrons").then(interception => {
                    const q = interception.request.query.q;
                    expect(q).to.equal(
                        '[{"library.name":"CPL"},{"me.library_id":"CPL"}]'
                    );
                });
            });
        });
    });
});

describe("On single result", () => {
    const table_id = "memberresultst";

    beforeEach(() => {
        cleanup();
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.window().then(win => {
            win.localStorage.clear();
        });
    });

    it("should redirect", () => {
        cy.task("insertSamplePatron").then(patron_objects => {
            let patron = patron_objects.patron;
            patron.library = patron_objects.library;
            cy.intercept("GET", "/api/v1/patrons*", {
                statusCode: 200,
                body: [patron],
                headers: {
                    "X-Base-Total-Count": baseTotalCount,
                    "X-Total-Count": "1",
                },
            }).as("searchPatrons");

            cy.visit("/cgi-bin/koha/mainpage.pl");

            cy.get("#findborrower").type(
                `${patron.surname} ${patron.firstname}`
            );
            // Wait for auto complete
            cy.wait("@searchPatrons");

            cy.get("#findborrower").type(`{enter}`);

            cy.title().should(
                "to.match",
                new RegExp(`^Checking out to.* ${patron.surname}`)
            );

            cy.location("pathname").should(
                "include",
                "/cgi-bin/koha/circ/circulation.pl"
            );
            cy.location("search").should(
                "include",
                `?borrowernumber=${patron.patron_id}`
            );
        });
    });
});
