import { mount } from "@cypress/vue";

describe("Generate Random Patron", () => {
    it("should generate a random patron from the schema", () => {
        cy.task("buildSampleObject", { object: "patron" }).then(mockPatron => {
            expect(mockPatron).to.have.property("patron_id");
        });
    });
    it("should generate a random patron with predefined values", () => {
        cy.task("buildSampleObject", {
            object: "patron",
            values: { surname: "test_surname" },
        }).then(mockPatron => {
            expect(mockPatron.surname).to.equal("test_surname");
            expect(mockPatron.overdues_count).to.be.a("number");
            expect(mockPatron.date_of_birth).to.match(/^\d{4}-\d{2}-\d{2}$/);
            // TODO We are not testing for timezone part
            expect(mockPatron.updated_on).to.match(
                /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/
            );
        });
    });

    it("should not overwrite _id if passed", () => {
        const home_library_id = "LIB4TEST";
        cy.task("buildSampleObject", {
            object: "item",
            values: { home_library_id },
        }).then(mockItem => {
            expect(mockItem.home_library_id).to.equal(home_library_id);
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

describe("Generate objects", () => {
    it("should generate an object for library", () => {
        cy.task("buildSampleObject", { object: "item" }).then(mockItem => {
            expect(mockItem.home_library).to.have.property("library_id");
            expect(mockItem.home_library).to.have.property("name");
            expect(mockItem.home_library_id).to.equal(
                mockItem.home_library.library_id
            );
            expect(mockItem.holding_library).to.have.property("library_id");
            expect(mockItem.holding_library).to.have.property("name");
            expect(mockItem.holding_library_id).to.equal(
                mockItem.holding_library.library_id
            );
            expect(mockItem.item_type).to.have.property("item_type_id");
            expect(mockItem.item_type).to.have.property("description");
            expect(mockItem.item_type_id).to.equal(
                mockItem.item_type.item_type_id
            );
        });
    });

    it("should not overwrite _id if passed", () => {
        const home_library_id = "LIB4TEST";
        cy.task("buildSampleObject", {
            object: "item",
            values: { home_library_id },
        }).then(mockItem => {
            expect(mockItem.home_library_id).to.equal(home_library_id);
        });
    });
});
