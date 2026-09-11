import PatronSelect from "@koha-vue/components/PatronSelect.vue";

describe("PatronSelect", () => {
    beforeEach(() => {
        cy.window().then(win => {
            win.__nx = (singular, plural, count, variables) =>
                (count === 1 ? singular : plural).replace(
                    "{count}",
                    variables.count
                );
        });
    });

    it("renders the label and required marker", () => {
        cy.mount(PatronSelect, {
            props: {
                modelValue: null,
                options: [],
                label: "Patron",
                required: true,
            },
        });

        cy.contains("label", "Patron").should("exist");
        cy.contains(".required", "Required").should("be.visible");
    });

    it("emits update:modelValue when an option is selected", () => {
        const onUpdate = cy.stub().as("onUpdate");
        cy.mount(PatronSelect, {
            props: {
                modelValue: null,
                options: [{ label: "Jane Doe", patron_id: 1 }],
                label: "Patron",
                "onUpdate:modelValue": onUpdate,
            },
        });

        cy.get(".vs__search").click();
        cy.contains(".vs__dropdown-option", "Jane Doe").click();
        cy.get("@onUpdate").should(
            "have.been.calledWith",
            Cypress.sinon.match({ label: "Jane Doe", patron_id: 1 })
        );
    });

    it("emits an empty search below minSearchLength, then the term once it's reached", () => {
        cy.clock();
        const onSearch = cy.stub().as("onSearch");
        cy.mount(PatronSelect, {
            props: {
                modelValue: null,
                options: [],
                label: "Patron",
                onSearch,
            },
        });

        cy.get(".vs__search").type("ja");
        cy.tick(250);
        cy.get("@onSearch").should("have.been.calledWith", "");

        cy.get(".vs__search").type("ne");
        cy.tick(250);
        cy.get("@onSearch").should("have.been.calledWith", "jane");
    });

    it("displays age and library metadata alongside matching options", () => {
        cy.mount(PatronSelect, {
            props: {
                modelValue: null,
                options: [
                    {
                        label: "Jane Doe",
                        patron_id: 1,
                        _age: 7,
                        _libraryName: "Main Library",
                    },
                ],
                label: "Patron",
            },
        });

        cy.get(".vs__search").click();
        cy.contains(".vs__dropdown-option", "Jane Doe").within(() => {
            cy.get(".age_years").should("contain.text", "7 years");
            cy.get(".ac-library").should("contain.text", "Main Library");
        });
    });

    it("marks the search input aria-required when required", () => {
        cy.mount(PatronSelect, {
            props: {
                modelValue: null,
                options: [],
                label: "Patron",
                required: true,
            },
        });

        cy.get(".vs__search").should("have.attr", "aria-required", "true");
    });
});
