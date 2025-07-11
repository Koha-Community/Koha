describe("visit", () => {
    it("should visit staff", () => {
        cy.visit("/");
        cy.title().should("eq", "Log in to Koha › Koha");
    });
});

describe("login", () => {
    it("should log in at the staff interface", () => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });
});

describe("visitOpac", () => {
    it("should visit OPAC", () => {
        cy.visitOpac("/");
        cy.title().should("eq", "Koha online catalog");
    });
});

describe("loginOpac", () => {
    it("should log in at the OPAC interface", () => {
        cy.loginOpac();
        cy.title().should("eq", "Your summary › Koha online catalog");
    });
});
