describe("DB tests", () => {
    it("should be able to SELECT", () => {
        cy.task("query", { sql: "SELECT count(*) FROM borrowers" }).then(
            rows => {
                expect(typeof rows.length).to.be.equal("number");
            }
        );
        cy.task("query", {
            sql: "SELECT count(*) FROM borrowers WHERE `surname` = ?",
            values: ["john"],
        }).then(rows => {
            expect(typeof rows.length).to.be.equal("number");
        });
    });
});
