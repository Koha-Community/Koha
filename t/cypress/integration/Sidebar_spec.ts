describe("Sidebar toggle", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.task("insertSamplePatron").then(objects_patron => {
            cy.wrap(objects_patron).as("objects_patron");
        });
    });

    afterEach(function () {
        cy.task("deleteSampleObjects", this.objects_patron);
    });

    it("Should display toggle button on patron detail page", function () {
        const patron = this.objects_patron.patron;
        cy.visit(
            `/cgi-bin/koha/members/moremember.pl?borrowernumber=${patron.patron_id}`
        );
        cy.get("#toggle-sidebar").should("be.visible");
    });

    it("Should toggle sidebar collapsed state when button is clicked", function () {
        const patron = this.objects_patron.patron;
        cy.visit(
            `/cgi-bin/koha/members/moremember.pl?borrowernumber=${patron.patron_id}`
        );

        // Sidebar should not be collapsed initially
        cy.get("#sidebar-container").should("not.have.class", "collapsed");
        cy.get("#toggle-sidebar").should("have.attr", "aria-expanded", "true");

        // Click the toggle button
        cy.get("#toggle-sidebar").click();

        // Sidebar should now be collapsed
        cy.get("#sidebar-container").should("have.class", "collapsed");
        cy.get("#toggle-sidebar").should("have.attr", "aria-expanded", "false");

        // Click again to expand
        cy.get("#toggle-sidebar").click();

        // Sidebar should be expanded again
        cy.get("#sidebar-container").should("not.have.class", "collapsed");
        cy.get("#toggle-sidebar").should("have.attr", "aria-expanded", "true");
    });

    it("Should update chevron icon when sidebar is toggled", function () {
        const patron = this.objects_patron.patron;
        cy.visit(
            `/cgi-bin/koha/members/moremember.pl?borrowernumber=${patron.patron_id}`
        );

        // Initially should have chevron-left (expanded state)
        cy.get("#toggle-sidebar i").should("have.class", "fa-chevron-left");
        cy.get("#toggle-sidebar i").should(
            "not.have.class",
            "fa-chevron-right"
        );

        // Click to collapse
        cy.get("#toggle-sidebar").click();

        // Should now have chevron-right (collapsed state)
        cy.get("#toggle-sidebar i").should("have.class", "fa-chevron-right");
        cy.get("#toggle-sidebar i").should("not.have.class", "fa-chevron-left");

        // Click again to expand
        cy.get("#toggle-sidebar").click();

        // Should have chevron-left again
        cy.get("#toggle-sidebar i").should("have.class", "fa-chevron-left");
        cy.get("#toggle-sidebar i").should(
            "not.have.class",
            "fa-chevron-right"
        );
    });
});
