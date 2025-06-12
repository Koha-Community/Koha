const { query } = require("./../../plugins/db.js");

describe("insertSampleBiblio", () => {
    it("should generate library and item type", () => {
        cy.task("insertSampleBiblio", { item_count: 3 }).then(objects => {
            const biblio_id = objects.biblio.biblio_id;

            expect(typeof biblio_id).to.be.equal("number");

            cy.task("query", {
                sql: "SELECT COUNT(*) as count FROM biblio WHERE biblionumber=?",
                values: [biblio_id],
            }).then(result => {
                expect(result[0].count).to.be.equal(1);
            });

            cy.task("query", {
                sql: "SELECT COUNT(*) as count FROM items WHERE biblionumber=?",
                values: [biblio_id],
            }).then(result => {
                expect(result[0].count).to.be.equal(3);
            });

            cy.task("query", {
                sql: "SELECT DISTINCT(itype) as count FROM items WHERE biblionumber=?",
                values: [biblio_id],
            }).then(result => {
                expect(result.length).to.be.equal(1);
            });

            cy.task("query", {
                sql: "SELECT COUNT(*) as count FROM branches WHERE branchcode=?",
                values: [objects.library.library_id],
            }).then(result => {
                expect(result[0].count).to.be.equal(1);
            });

            cy.task("query", {
                sql: "SELECT COUNT(*) as count FROM itemtypes WHERE itemtype=?",
                values: [objects.item_type.item_type_id],
            }).then(result => {
                expect(result[0].count).to.be.equal(1);
            });

            cy.task("deleteSampleObjects", objects);

            cy.task("query", {
                sql: "SELECT COUNT(*) as count FROM biblio WHERE biblionumber=?",
                values: [biblio_id],
            }).then(result => {
                expect(result[0].count).to.be.equal(0);
            });

            cy.task("query", {
                sql: "SELECT COUNT(*) as count FROM items WHERE biblionumber=?",
                values: [biblio_id],
            }).then(result => {
                expect(result[0].count).to.be.equal(0);
            });

            cy.task("query", {
                sql: "SELECT COUNT(*) as count FROM branches WHERE branchcode=?",
                values: [objects.library.library_id],
            }).then(result => {
                expect(result[0].count).to.be.equal(0);
            });

            cy.task("query", {
                sql: "SELECT COUNT(*) as count FROM itemtypes WHERE itemtype=?",
                values: [objects.item_type.item_type_id],
            }).then(result => {
                expect(result[0].count).to.be.equal(0);
            });
        });
    });
});
