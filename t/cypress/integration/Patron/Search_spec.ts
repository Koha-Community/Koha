import { mount } from "@cypress/vue";

const RESTdefaultPageSize = "20"; // FIXME Mock this
const baseTotalCount = "42";

describe("Header search", () => {
    const table_id = "memberresultst";

    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    it("Should trigger a search", () => {
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

            cy.get(`#${table_id}_wrapper .dt-info`).should("not.be.visible");

            cy.get("#patron_header_search #searchmember").type("a{enter}");

            cy.get(`#${table_id}_wrapper .dt-info`).should("be.visible");
        });
    });
});
