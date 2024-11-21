import { mount } from "@cypress/vue";

describe("Generate Random Patron", () => {
    it("should generate a random patron from the schema", () => {
        cy.task("buildSamplePatron").then(mockPatron => {
            expect(mockPatron).to.have.property("patron_id");
        });
    });
});

describe("Generate Random Patrons", () => {
    it("should generate 42 random patron from the schema", () => {
        cy.task("buildSamplePatrons", 42).then(mockPatrons => {
            expect(mockPatrons.length).to.equal(42);
            expect(mockPatrons[0]).to.have.property("patron_id");
        });
    });
});
