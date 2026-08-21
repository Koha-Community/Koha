function findDetailsQuery(value: any): any {
    if (!value || typeof value !== "object") return;

    if (Array.isArray(value["extended_attributes.type"])) {
        return value;
    }

    for (const child of Object.values(value)) {
        const result = findDetailsQuery(child);
        if (result) return result;
    }
}

const matchingOrderId = "cypress-ill-search-match";
const excludedOrderId = "cypress-ill-search-excluded";
const searchValue = "cypress-ill-details-needle";

describe("ILL requests", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");

        cy.task("query", {
            sql: "SELECT value FROM systempreferences WHERE variable='ILLModule'",
        }).then(rows => {
            cy.wrap(rows[0].value).as("syspref_ILLModule");
        });
        cy.set_syspref("ILLModule", 1);

        cy.task("query", {
            sql: `DELETE FROM illrequests WHERE orderid IN ('${matchingOrderId}', '${excludedOrderId}')`,
        });
        cy.task("query", {
            sql: `INSERT INTO illrequests (borrowernumber, branchcode, status, backend, orderid)
                  SELECT borrowernumber, branchcode, 'NEW', 'Standard', '${matchingOrderId}'
                  FROM borrowers ORDER BY borrowernumber LIMIT 1`,
        });
        cy.task("query", {
            sql: `INSERT INTO illrequests (borrowernumber, branchcode, status, backend, orderid)
                  SELECT borrowernumber, branchcode, 'NEW', 'Standard', '${excludedOrderId}'
                  FROM borrowers ORDER BY borrowernumber LIMIT 1`,
        });
        cy.task("query", {
            sql: `INSERT INTO illrequestattributes (illrequest_id, backend, type, value, readonly)
                  SELECT illrequest_id, 'Standard', 'title', '${searchValue}', 0
                  FROM illrequests WHERE orderid = '${matchingOrderId}'`,
        });
        cy.task("query", {
            sql: `INSERT INTO illrequestattributes (illrequest_id, backend, type, value, readonly)
                  SELECT illrequest_id, 'Standard', 'unrelated_type', '${searchValue}', 0
                  FROM illrequests WHERE orderid = '${excludedOrderId}'`,
        });
        cy.task("query", {
            sql: `SELECT illrequest_id, orderid, borrowernumber
                  FROM illrequests
                  WHERE orderid IN ('${matchingOrderId}', '${excludedOrderId}')`,
        }).then(rows => {
            const matchingRequest = rows.find(
                request => request.orderid === matchingOrderId
            );
            cy.wrap(matchingRequest).as("matchingRequest");
        });
    });

    afterEach(function () {
        cy.task("query", {
            sql: `DELETE FROM illrequests WHERE orderid IN ('${matchingOrderId}', '${excludedOrderId}')`,
        });
        cy.set_syspref("ILLModule", this.syspref_ILLModule);
    });

    it("searches the combined request details column", function () {
        const tableId = `ill-requests-patron-${this.matchingRequest.borrowernumber}`;

        cy.intercept("GET", "/api/v1/ill/requests*").as("getRequests");

        cy.visit(
            `/cgi-bin/koha/members/ill-requests.pl?borrowernumber=${this.matchingRequest.borrowernumber}`
        );
        cy.wait("@getRequests");

        cy.get(`#${tableId}_wrapper input.dt-input[type='search']`).type(
            searchValue
        );

        cy.wait("@getRequests").then(interception => {
            expect(interception.response?.statusCode).to.equal(200);

            const query = JSON.parse(interception.request.query.q as string);
            const detailsQuery = findDetailsQuery(query);

            expect(JSON.stringify(query)).not.to.contain('"me."');
            expect(detailsQuery).not.to.be.undefined;
            expect(detailsQuery["extended_attributes.type"]).to.deep.equal([
                "article_title",
                "title",
                "article_author",
                "author",
                "issue",
                "volume",
                "year",
                "pages",
            ]);
            expect(detailsQuery["extended_attributes.value"]).to.deep.equal({
                like: `%${searchValue}%`,
            });
            expect(interception.response?.body).to.have.length(1);
            expect(interception.response?.body[0].ill_request_id).to.equal(
                this.matchingRequest.illrequest_id
            );
        });

        cy.get(`#${tableId} tbody`).contains(searchValue).should("be.visible");
    });
});
