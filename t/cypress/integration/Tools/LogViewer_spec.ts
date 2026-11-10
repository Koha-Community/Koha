describe("Log viewer date filters", () => {
    const marker = `cypress-log-viewer-${Date.now()}`;
    let actionId;

    before(() => {
        cy.task(
            "query",
            `INSERT INTO action_logs (timestamp, user, module, action, object, info, interface)
             VALUES ('2026-01-15 12:00:00', 0, 'CATALOGUING', 'MODIFY', 0, '${marker}', 'intranet')`
        ).then(result => {
            actionId = result.insertId;
        });
    });

    after(() => {
        if (actionId) {
            cy.task(
                "query",
                `DELETE FROM action_logs WHERE action_id = ${Number(actionId)}`
            );
        }
    });

    beforeEach(() => {
        cy.login();
    });

    [
        { name: "no dates", from: null, to: null },
        { name: "a start date", from: "2026-01-15", to: null },
        { name: "an end date", from: null, to: "2026-01-15" },
        { name: "a date range", from: "2026-01-15", to: "2026-01-15" },
    ].forEach(({ name, from, to }) => {
        it(`loads matching entries with ${name}`, () => {
            cy.visit("/cgi-bin/koha/tools/viewlog.pl");
            cy.get("#info").type(marker);

            if (from) {
                cy.get("#from").then($input => {
                    $input[0]._flatpickr.setDate(from, true, "Y-m-d");
                });
            }
            if (to) {
                cy.get("#to").then($input => {
                    $input[0]._flatpickr.setDate(to, true, "Y-m-d");
                });
            }

            cy.intercept("GET", "/api/v1/action_logs*").as("logs");
            cy.get("#screen").check();
            cy.get('input[type="submit"][value="Submit"]').click();
            cy.wait("@logs").its("response.statusCode").should("eq", 200);
            cy.get("#logst tbody").should("contain", marker);
            cy.get("#logst_processing").should("not.be.visible");
        });
    });
});
