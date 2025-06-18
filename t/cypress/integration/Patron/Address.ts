describe("Display address", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.task("buildSampleObject", {
            object: "patron",
            values: {
                street_number: 12,
                street_type: "Rd",
                address: "Awesome",
                address2: "Library",
                city: "Portland",
                state: "OR",
                postal_code: "44240",
                country: "USA",
            },
        }).then(generatedPatron => {
            cy.task("insertObject", {
                type: "patron",
                object: generatedPatron,
            }).then(objects_patron => {
                cy.wrap(objects_patron).as("objects_patron");
            });
        });
    });

    afterEach(function () {
        cy.task("deleteSampleObjects", [this.objects_patron]);
    });

    it("should have correct spacing", function () {
        cy.visit(
            `/cgi-bin/koha/members/moremember.pl?borrowernumber=${this.objects_patron.patron_id}`
        );
        const patron = this.objects_patron;
        cy.get(".patronbriefinfo").should($el => {
            const re = new RegExp(
                `${patron.street_number} ${patron.address} ${patron.street_type}\\n\\s*${patron.address2}\\n\\s*${patron.city}, ${patron.state} ${patron.postal_code}\\n\\s*${patron.country}`
            );
            const displayedText = $el.text().replace(/ /g, " ").trim();
            expect(displayedText).to.match(re);
        });
    });
});
