import { mount } from "@cypress/vue";

describe("Generate Random Patron", () => {
    it("should generate a random patron from the schema", () => {
        cy.task("buildSampleObject", { object: "patron" }).then(mockPatron => {
            expect(mockPatron).to.have.property("patron_id");
        });
    });
});

describe("Generate Random Patrons", () => {
    it("should generate 42 random patron from the schema", () => {
        cy.task("buildSampleObjects", { object: "patron", count: 42 }).then(
            mockPatrons => {
                expect(mockPatrons.length).to.equal(42);
                expect(mockPatrons[0]).to.have.property("patron_id");
            }
        );
    });
});

describe("Generate Random Library", () => {
    it("should generate a random library from the schema", () => {
        cy.task("buildSampleObject", { object: "library" }).then(
            mockLibrary => {
                expect(mockLibrary).to.have.property("library_id");
            }
        );
    });
});

describe("Generate Random Libraries", () => {
    it("should generate 42 random library from the schema", () => {
        cy.task("buildSampleObjects", { object: "library", count: 42 }).then(
            mockLibraries => {
                expect(mockLibraries.length).to.equal(42);
                expect(mockLibraries[0]).to.have.property("library_id");
            }
        );
    });
});
