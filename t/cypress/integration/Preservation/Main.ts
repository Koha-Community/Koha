describe("Main component - pref off", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.intercept(
            "GET",
            "/api/v1/preservation/config",
            '{"permissions":{"manage_sysprefs":1},"settings":{"enabled":"0","not_for_loan_default_train_in":"","not_for_loan_waiting_list_in":""}}'
        );
    });

    it("Home", () => {
        cy.visit("/cgi-bin/koha/preservation/home.pl");
        cy.get(".main .sidebar_menu").should("not.exist");
        cy.get(".main div[class='alert alert-warning']").contains(
            "The preservation module is disabled, turn on PreservationModule to use it"
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
            "/api/v1/preservation/config",
            '{"permissions":{"manage_sysprefs":1},"settings":{"enabled":"1","not_for_loan_default_train_in":"","not_for_loan_waiting_list_in":""}}'
        );
    });

    it("Home", () => {
        cy.visit("/cgi-bin/koha/preservation/home.pl");
        cy.get(".main .sidebar_menu").should("exist");
        cy.get(".main div[class='alert alert-warning']").should("not.exist");
    });

    it("Waiting list", () => {
        cy.visit("/cgi-bin/koha/preservation/waiting-list");
        cy.get(".main .sidebar_menu").should("exist");
        cy.get(".main div[class='alert alert-warning']").contains(
            "You need to configure this module first."
        );
    });
});
