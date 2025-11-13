describe("Main component - pref off", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.intercept(
            "GET",
            "/api/v1/erm/config",
            '{"settings":{"ERMModule":"0","ERMProviders":["local"]}}'
        );
    });

    it("Home", () => {
        cy.visit("/cgi-bin/koha/erm/erm.pl");
        cy.get(".main .sidebar_menu").should("not.exist");
        cy.get(".main div[class='alert alert-warning']").contains(
            "The e-resource management module is disabled, turn on ERMModule to use it"
        );
        cy.get(".main div[class='alert alert-warning'] a").click();
        cy.url().should("match", /\/cgi-bin\/koha\/admin\/preferences.pl/);
    });
});

describe("Main component - pref on", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.intercept(
            "GET",
            "/api/v1/erm/config",
            '{"settings":{"ERMModule":"1","ERMProviders":["local"]}}'
        );
    });

    it("Home", () => {
        cy.visit("/cgi-bin/koha/erm/erm.pl");
        cy.get(".main .sidebar_menu").should("exist");
        cy.get(".main div[class='alert alert-warning']").should("not.exist");
    });
});

describe("Breadcrumb", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.intercept(
            "GET",
            "/api/v1/erm/config",
            '{"settings":{"ERMModule":"1","ERMProviders":["local"]}}'
        );
    });

    it("Home should not reload the app", () => {
        cy.visit("/cgi-bin/koha/erm/agreements");
        cy.window().then(win => {
            const originalWindow = win;
            cy.get("#breadcrumbs").contains("E-resource management").click();
            cy.window().should(newWin => {
                expect(newWin).to.equal(originalWindow);
            });
        });
    });
});
