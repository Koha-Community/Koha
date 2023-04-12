describe("Searchbar header changes", () => {
    before(() => {
        cy.fetch_initial_ERM_sys_pref_value();
        cy.set_ERM_sys_pref_value(true);
    });

    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    after(() => {
        cy.reset_initial_ERM_sys_pref_value();
    });

    it("Default option is agreements", () => {
        cy.visit("/cgi-bin/koha/erm/erm.pl");
        cy.get("#agreement_search_tab").parent().should("have.class", "active")

        cy.visit("/cgi-bin/koha/erm/agreements");
        cy.get("#agreement_search_tab").parent().should("have.class", "active")
    })

    it("Default option also applies to licenses", () => {
        cy.visit("/cgi-bin/koha/erm/license");
        cy.get("#agreement_search_tab").parent().should("have.class", "active")
    })

    it("Should change to packages when in local packages", () => {
        cy.visit("/cgi-bin/koha/erm/eholdings/local/packages");
        cy.get("#package_search_tab").parent().should("have.class", "active")
    })

    it("Should change to titles when in local titles", () => {
        cy.visit("/cgi-bin/koha/erm/eholdings/local/titles");
        cy.get("#title_search_tab").parent().should("have.class", "active")
    })
})