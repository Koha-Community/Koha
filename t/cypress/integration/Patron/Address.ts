describe("Display address", () => {
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

    it("should have correct spacing", function () {
        const patron = this.objects_patron.patron;
        cy.visit(
            `/cgi-bin/koha/members/moremember.pl?borrowernumber=${patron.patron_id}`
        );
        cy.get(".patronbriefinfo").should($el => {
            const re = new RegExp(
                `${patron.street_number} ${patron.address} ${patron.street_type}\\n\\s*${patron.address2}\\n\\s*${patron.city}, ${patron.state} ${patron.postal_code}\\n\\s*${patron.country}`
            );
            const displayedText = $el.text().replace(/ /g, " ").trim();
            expect(displayedText).to.match(re);
        });
    });
});
