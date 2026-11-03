// The notification offering the receipt, shown after a payment is taken or a fee is
// written off on the patron account pages (FinePaymentAutoPopup disabled)

describe("Circulation - receipt offered after a payment or a write off", () => {
    let patron, other_patron, payment_id, writeoff_id;

    const insertCredit = (borrowernumber, credit_type_code) =>
        cy
            .task("query", {
                sql: `INSERT INTO accountlines (borrowernumber, amount, amountoutstanding, credit_type_code, interface, description)
                      VALUES (?, -5, 0, ?, 'test', 'test credit')`,
                values: [borrowernumber, credit_type_code],
            })
            .then(result => result.insertId);

    beforeEach(function () {
        cy.login();
        cy.title().should("eq", "Koha staff interface");

        cy.set_syspref("FinePaymentAutoPopup", "0");

        cy.task("insertSampleCheckout").then(objects => {
            patron = objects.patron;
            cy.wrap(objects).as("patron_objects");
        });
        cy.task("insertSampleCheckout").then(objects => {
            other_patron = objects.patron;
            cy.wrap(objects).as("other_patron_objects");
        });
        cy.then(() => insertCredit(patron.patron_id, "PAYMENT")).then(id => {
            payment_id = id;
        });
        cy.then(() => insertCredit(patron.patron_id, "WRITEOFF")).then(id => {
            writeoff_id = id;
        });
    });

    afterEach(function () {
        cy.task("query", {
            sql: "DELETE FROM accountlines WHERE borrowernumber = ?",
            values: [patron.patron_id],
        });
        cy.task("deleteSampleObjects", [
            this.patron_objects,
            this.other_patron_objects,
        ]);
        cy.set_syspref("FinePaymentAutoPopup", "1");
    });

    const pages = {
        "members/pay.pl": "/cgi-bin/koha/members/pay.pl",
        "members/boraccount.pl": "/cgi-bin/koha/members/boraccount.pl",
    };

    Object.entries(pages).forEach(([name, path]) => {
        describe(name, () => {
            it("should offer the receipt of a payment", () => {
                cy.visit(
                    `${path}?borrowernumber=${patron.patron_id}&payment_id=${payment_id}`
                );
                cy.get(".audio-alert-action").should(
                    "contain",
                    "Payment received"
                );
                cy.get(".audio-alert-action").should(
                    "not.contain",
                    "Fee written off"
                );
                cy.get("#print-payment-receipt-button").should(
                    "have.attr",
                    "href"
                );
            });

            it("should say that the fee was written off after a write off", () => {
                cy.visit(
                    `${path}?borrowernumber=${patron.patron_id}&payment_id=${writeoff_id}`
                );
                cy.get(".audio-alert-action").should(
                    "contain",
                    "Fee written off"
                );
                cy.get(".audio-alert-action").should(
                    "not.contain",
                    "Payment received"
                );
                cy.get("#print-payment-receipt-button").should(
                    "have.attr",
                    "href"
                );
            });

            it("should not offer the receipt when it is not the patron's", () => {
                cy.visit(
                    `${path}?borrowernumber=${other_patron.patron_id}&payment_id=${payment_id}`
                );
                cy.get(".audio-alert-action").should("not.exist");
            });

            it("should not offer the receipt when the receipt pops up on its own", () => {
                cy.set_syspref("FinePaymentAutoPopup", "1");
                cy.visit(
                    `${path}?borrowernumber=${patron.patron_id}&payment_id=${payment_id}`,
                    {
                        onBeforeLoad(win) {
                            cy.stub(win, "open");
                        },
                    }
                );
                cy.get(".audio-alert-action").should("not.exist");
            });
        });
    });
});
