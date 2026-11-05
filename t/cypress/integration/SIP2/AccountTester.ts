// Where an element starts, to check that things line up
function left(el: HTMLElement) {
    return Math.round(el.getBoundingClientRect().left);
}

// How wide an element is, a label above its content is as wide as the content
function width(el: HTMLElement) {
    return Math.round(el.getBoundingClientRect().width);
}

function get_account() {
    return {
        sip_account_id: 1,
        login_id: "sip_tester",
        institution: {
            name: "MPL",
            sip_institution_id: 1,
            implementation: "ILS",
        },
    };
}

// Picks an option of a v-select by its text
function choose(id: string, text: string) {
    cy.get(`#${id} .vs__search`).click();
    cy.get(`#${id} .vs__dropdown-menu li`).contains(text).click();
}

describe("Account tester", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.set_syspref("UseCashRegisters", 0);
    });

    it("Shows an error when the account cannot be loaded", () => {
        cy.intercept("GET", "/api/v1/sip2/accounts/1", {
            statusCode: 404,
            body: { error: "Account not found" },
        });
        cy.visit("/cgi-bin/koha/sip2/accounts/test/1");
        cy.get("#sip2_account_tester [role=alert]").contains(
            "Account not found"
        );
        cy.get("#sip2_account_tester form").should("not.exist");
    });

    it("Builds the request from the form", () => {
        cy.intercept("GET", "/api/v1/sip2/accounts/1", get_account());
        cy.visit("/cgi-bin/koha/sip2/accounts/test/1");

        cy.get("#sip2_account_tester h1").contains("sip_tester");

        cy.get("#raw_request")
            .invoke("val")
            .should("match", /^63001/);
        cy.get("#raw_request").invoke("val").should("contain", "AOMPL|");

        cy.get("#patron_id").type("23529000000001");
        cy.get("#raw_request")
            .invoke("val")
            .should("contain", "AA23529000000001|");

        // The label of the raw request sits above it and lines up with it
        cy.get("label[for=raw_request]").then($label => {
            cy.get("#raw_request").then($request => {
                expect(left($label[0]), "raw request label").to.equal(
                    left($request[0])
                );
            });
        });
        // The patron password is a choice of outcome, a real one is never typed
        cy.get("#patron_password").should("have.class", "v-select");
        cy.get("#patron_password input[type=password]").should("not.exist");
        cy.get("#patron_password").siblings(".tooltip_helper").should("exist");
        cy.get("#raw_request").invoke("val").should("not.contain", "AD");
        choose("patron_password", "Valid password");
        cy.get("#raw_request").invoke("val").should("contain", "ADGOOD|");
        choose("patron_password", "Invalid password");
        cy.get("#raw_request").invoke("val").should("contain", "ADBAD|");
        choose("patron_password", "Not sent");
        cy.get("#raw_request").invoke("val").should("not.contain", "AD");

        // A patron information request asks for one list of items with the summary
        cy.get("#summary .vs__selected").should("contain", "None");
        cy.get("#raw_request")
            .invoke("val")
            .should("match", /^63001.{18} {10}AO/);
        choose("summary", "Fine items");
        cy.get("#raw_request")
            .invoke("val")
            .should("match", /^63001.{18} {3}Y {6}AO/);
        choose("summary", "Hold items");
        cy.get("#raw_request")
            .invoke("val")
            .should("match", /^63001.{18}Y {9}AO/);
        choose("summary", "None");
        cy.get("#raw_request")
            .invoke("val")
            .should("match", /^63001.{18} {10}AO/);

        // Switching message type changes the fields and the request
        choose("message", "Item information");
        cy.get("#patron_id").should("not.exist");
        cy.get("#summary").should("not.exist");
        cy.get("#item_id").type("39999000001234");
        cy.get("#raw_request").invoke("val").should("match", /^17/);
        cy.get("#raw_request")
            .invoke("val")
            .should("contain", "AB39999000001234|");

        // Editing the request by hand stops the form from changing it
        cy.get("#raw_request").type("AY");
        cy.contains("You have edited the request by hand");
        cy.get("#item_id").type("5");
        cy.get("#raw_request")
            .invoke("val")
            .should("not.contain", "AB399990000012345|");
        cy.contains("Reset to the generated request").click();
        cy.get("#raw_request")
            .invoke("val")
            .should("contain", "AB399990000012345|");
    });

    it("Refuses a delimiter in a value", () => {
        cy.intercept("GET", "/api/v1/sip2/accounts/1", get_account());
        cy.visit("/cgi-bin/koha/sip2/accounts/test/1");

        cy.get("#patron_id").type("123|AB456");
        cy.get("#sip2_account_tester [role=alert]").contains(
            "cannot be used in a barcode"
        );
        cy.get("#sip2_account_tester input[type=submit]").should("be.disabled");

        cy.get("#patron_id").clear().type("123");
        cy.get("#sip2_account_tester input[type=submit]").should(
            "not.be.disabled"
        );
    });

    it("Runs a test and shows the response", () => {
        cy.intercept("GET", "/api/v1/sip2/accounts/1", get_account());
        cy.intercept("POST", "/api/v1/sip2/accounts/1/test_message", {
            statusCode: 200,
            body: {
                request: "63001...",
                response: "64              001AAA1|AEA Patron|",
                fixed: "64              001",
                fields: [
                    { field: "AA", value: "A1" },
                    { field: "AE", value: "A Patron" },
                ],
            },
        }).as("testMessage");
        cy.visit("/cgi-bin/koha/sip2/accounts/test/1");

        cy.get("#patron_id").type("A1");
        cy.get("#sip2_account_tester input[type=submit]").click();
        cy.wait("@testMessage")
            .its("request.body")
            .should("have.property", "request");

        // The labels of the response sit above what they label, as wide as it
        cy.get("#sip2_account_tester span.label").each($label => {
            const content = $label[0].parentElement.querySelector("pre");
            expect(left($label[0]), $label.text()).to.equal(left(content));
            expect(width($label[0]), $label.text() + " width").to.equal(
                width(content)
            );
        });
        cy.get("table.sip-fields").contains("td", "AA - Patron identifier");
        cy.get("table.sip-fields").contains("td", "A Patron");
        cy.get("#sip2_account_tester").contains("64              001AAA1|");
    });

    it("Shows the reason when a test is refused", () => {
        cy.intercept("GET", "/api/v1/sip2/accounts/1", get_account());
        cy.intercept("POST", "/api/v1/sip2/accounts/1/test_message", {
            statusCode: 403,
            body: { error: "Cannot access this patron" },
        });
        cy.visit("/cgi-bin/koha/sip2/accounts/test/1");

        cy.get("#patron_id").type("A1");
        cy.get("#sip2_account_tester input[type=submit]").click();
        cy.get("#sip2_account_tester [role=alert]").contains(
            "Cannot access this patron"
        );
        cy.get("table.sip-fields").should("not.exist");
    });

    it("Copes with an error that is not JSON", () => {
        cy.intercept("GET", "/api/v1/sip2/accounts/1", get_account());
        cy.intercept("POST", "/api/v1/sip2/accounts/1/test_message", {
            statusCode: 502,
            headers: { "content-type": "text/html" },
            body: "<html><body>Bad gateway</body></html>",
        });
        cy.visit("/cgi-bin/koha/sip2/accounts/test/1");

        cy.get("#patron_id").type("A1");
        cy.get("#sip2_account_tester input[type=submit]").click();
        cy.get("#sip2_account_tester [role=alert]").should("exist");
        cy.get("table.sip-fields").should("not.exist");
        // The page is still usable
        cy.get("#sip2_account_tester form").should("exist");
    });
});
