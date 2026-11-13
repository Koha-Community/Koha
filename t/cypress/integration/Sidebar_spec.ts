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

describe("Sidebar toggle on Vue pages", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        window.localStorage.removeItem("sidebar-collapsed");
    });

    afterEach(() => {
        window.localStorage.removeItem("sidebar-collapsed");
    });

    it("Should let the content fill the space when the sidebar is collapsed", () => {
        cy.visit("/cgi-bin/koha/acquisition/vendors");
        cy.get("#toggle-sidebar").should("be.visible");

        cy.get(".sidebar-main").then($main => {
            const expanded_width = $main.outerWidth();
            cy.get("#toggle-sidebar").click();
            cy.get("html").should("have.class", "sidebar-collapsed");
            cy.get(".sidebar-main").should($collapsed => {
                expect($collapsed.outerWidth()).to.be.greaterThan(
                    expanded_width + 100
                );
            });
        });
    });

    it("Should expand on the first click after a reload while collapsed", () => {
        cy.visit("/cgi-bin/koha/acquisition/vendors");
        cy.get("#toggle-sidebar").click();
        cy.get("html").should("have.class", "sidebar-collapsed");

        cy.reload();
        cy.get("html").should("have.class", "sidebar-collapsed");
        cy.get("#toggle-sidebar").click();

        cy.get("html").should("not.have.class", "sidebar-collapsed");
        cy.get("#sidebar-container").should("not.have.class", "collapsed");
    });

    it("Should label the icons of a collapsed Vue sidebar", () => {
        cy.visit("/cgi-bin/koha/sip2/sip2.pl");
        cy.get("#toggle-sidebar").click();
        cy.get("#sidebar-container .sidebar_menu a").each($link => {
            expect($link.attr("title"), "title of the link").to.be.a("string")
                .and.not.be.empty;
        });
    });
});

describe("Sidebar menu entries", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.set_syspref("NoticesManagement", "1");
        window.localStorage.removeItem("sidebar-collapsed");
    });

    afterEach(() => {
        cy.set_syspref("NoticesManagement", "0");
        window.localStorage.removeItem("sidebar-collapsed");
    });

    it("Should give the Tools menu 'Notices management' entry an icon and a label", () => {
        cy.visit("/cgi-bin/koha/tools/letter.pl");

        cy.get('#sidebar-container a[href="/cgi-bin/koha/tools/notices.pl"]')
            .should("have.attr", "title", "Notices management")
            .within(() => {
                cy.get("i.fa-fw").should("exist");
                cy.get("span.menu-label").should(
                    "have.text",
                    "Notices management"
                );
            });
    });

    it("Should keep that entry inside the collapsed sidebar", () => {
        cy.visit("/cgi-bin/koha/tools/notices.pl");
        cy.get("#toggle-sidebar").click();
        cy.get("#sidebar-container").should("have.class", "collapsed");

        cy.get(
            '#sidebar-container a[href="/cgi-bin/koha/tools/notices.pl"]'
        ).should($link => {
            const link = $link[0].getBoundingClientRect();
            const sidebar =
                Cypress.$("#sidebar-container")[0].getBoundingClientRect();
            expect(link.right, "link right edge").to.be.at.most(
                sidebar.right + 1
            );
            expect(link.width, "link width").to.be.greaterThan(0);
        });
    });
});
