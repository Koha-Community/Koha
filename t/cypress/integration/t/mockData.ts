import { mount } from "@cypress/vue";

describe("Generate Random Patron", () => {
    it("should generate a random patron from the schema", () => {
        cy.task("buildSamplePatron").then(mockPatron => {
            expect(mockPatron).to.have.property("patron_id");
        });
    });
});
