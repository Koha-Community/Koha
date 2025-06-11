import { mount } from "@cypress/vue";

const RESTdefaultPageSize = "20"; // FIXME Mock this
const baseTotalCount = "42";

const ExtendedPatronAttributes = 42;

const patron_attr_type = "attribute_type4TEST";

function cleanup() {
    const sql = "DELETE FROM borrower_attribute_types WHERE code=?";
    cy.query(sql, patron_attr_type);
}
describe("ExtendedPatronAttributes", () => {
    beforeEach(() => {
        cleanup();
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.window().then(win => {
            win.localStorage.clear();
        });
        cy.query(
            "SELECT value FROM systempreferences WHERE variable='ExtendedPatronAttributes'"
        ).then(value => {
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

            cy.query(
                "select count(*) as nb_searchable from borrower_attribute_types where staff_searchable=1"
            ).then(result => {
                const has_searchable = result[0].nb_searchable;
                cy.wait("@searchPatrons").then(interception => {
                    const q = interception.request.query.q;
                    expect(q).to.not.match(/extended_attributes/);
                });
            });

            cy.query(
                "INSERT INTO borrower_attribute_types(code, description, staff_searchable, searched_by_default) VALUES (?, 'only for tests', 1, 1)",
                patron_attr_type
            ).then(() => {
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

            cy.query(
                "select count(*) as nb_searchable from borrower_attribute_types where staff_searchable=1 AND searched_by_default=1"
            ).then(result => {
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

            cy.query(
                "INSERT INTO borrower_attribute_types(code, description, staff_searchable, searched_by_default) VALUES (?, 'only for tests', 1, 1)",
                patron_attr_type
            ).then(() => {
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
                    map[p.category_id] = p.category_id;
                    return map;
                }, {});
            });
            cy.get("form.patron_search_form .branchcode_filter").select("CPL");
            cy.get("form.patron_search_form .categorycode_filter").select("S");
            cy.get("form.patron_search_form input[type='submit']").click();

            cy.get(`#${table_id}_wrapper .dt-info`).contains(
                `Showing 1 to ${RESTdefaultPageSize} of ${baseTotalCount} entries`
            );

            cy.get(`#${table_id} thead tr`).should("have.length", 2);

            cy.get(
                `#${table_id} thead tr th[data-filter='libraries'] select`
            ).should("have.value", "^CPL$");
            // Lowercase see bug 32517 and related code in datatables.js
            cy.get(
                `#${table_id} thead tr th[data-filter='categories'] select`
            ).should("have.value", "^s$");

            cy.get(`form.patron_search_form input.clear_search`).click();
            cy.get("form.patron_search_form input[type='submit']").click();
            cy.get(
                `#${table_id} thead tr th[data-filter='libraries'] select`
            ).should("have.value", null);
            // Lowercase see bug 32517 and related code in datatables.js
            cy.get(
                `#${table_id} thead tr th[data-filter='categories'] select`
            ).should("have.value", null);
        });
    });
});
