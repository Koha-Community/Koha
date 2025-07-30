import FormElement from "@koha-vue/components/FormElement.vue";

const resource = {
    id: 1,
    name: "test",
    correct: true,
    errorField: "",
};

//form error message
// events

describe("FormElement", () => {
    it("should render a label if required, with the correct 'for' attribute", () => {
        cy.mount(FormElement, {
            props: {
                attr: {
                    name: "name",
                    label: "Name",
                    type: "text",
                },
                resource,
            },
        });
        cy.get("label").should("have.attr", "for", "name");

        cy.mount(FormElement, {
            props: {
                attr: {
                    name: "name",
                    label: "Name",
                    type: "text",
                    id: "newId",
                },
                resource,
            },
        });
        cy.get("label").should("have.attr", "for", "newId");
    });
    it("should mark the field as required", () => {
        cy.mount(FormElement, {
            props: {
                attr: {
                    name: "name",
                    label: "Name",
                    type: "text",
                    required: true,
                },
                resource,
            },
        });
        cy.get("label").should("have.class", "required");
        cy.get("input").should("have.attr", "required");
        cy.get("span").should("have.class", "required");
    });
    it("should mark the field as disabled", () => {
        cy.mount(FormElement, {
            props: {
                attr: {
                    name: "name",
                    label: "Name",
                    type: "text",
                    disabled: true,
                },
                resource,
            },
        });
        cy.get("input").should("have.attr", "disabled");
    });
    it("should pass a placeholder", () => {
        cy.mount(FormElement, {
            props: {
                attr: {
                    name: "name",
                    label: "Name",
                    type: "text",
                    placeholder: "This is a placeholder",
                },
                resource,
            },
        });
        cy.get("input").should(
            "have.attr",
            "placeholder",
            "This is a placeholder"
        );
    });
    it("should render a text type input", () => {
        cy.mount(FormElement, {
            props: {
                attr: {
                    name: "name",
                    label: "Name",
                    type: "text",
                },
                resource,
            },
        });
        cy.get("input").should("have.attr", "type", "text");
    });
    it("should render a number type input", () => {
        cy.mount(FormElement, {
            props: {
                attr: {
                    name: "name",
                    label: "Name",
                    type: "number",
                },
                resource,
            },
        });
        cy.get("input").should("have.attr", "inputmode", "numeric");
    });
    it("should render a textarea", () => {
        cy.mount(FormElement, {
            props: {
                attr: {
                    name: "name",
                    label: "Name",
                    type: "textarea",
                },
                resource,
            },
        });
        cy.get("textarea").should("exist");
    });
    it("should render a checkbox", () => {
        cy.mount(FormElement, {
            props: {
                attr: {
                    name: "name",
                    label: "Name",
                    type: "checkbox",
                },
                resource,
            },
        });
        cy.get("input").should("have.attr", "type", "checkbox");
    });
    it("should render a radio input", () => {
        cy.mount(FormElement, {
            props: {
                attr: {
                    name: "correct",
                    label: "Name",
                    type: "radio",
                    options: [
                        { value: true, description: "Correct" },
                        { value: false, description: "Incorrect" },
                    ],
                },
                resource,
            },
        });
        cy.get("#correct_true").should("have.attr", "type", "radio");
        cy.get("#correct_true").should("have.attr", "checked");
    });
    it("should render a select input", () => {
        const attr = {
            name: "name",
            label: "Name",
            type: "select",
            options: [
                { value: true, description: "Correct" },
                { value: false, description: "Incorrect" },
            ],
            requiredKey: "value",
            selectLabel: "description",
            onSelected: resource => {
                return resource;
            },
        };
        cy.spy(attr, "onSelected").as("onSelected");

        cy.mount(FormElement, {
            props: {
                attr,
                resource,
            },
        });
        cy.get("div.v-select").should("exist");
        cy.get(".vs__open-indicator").click();
        cy.get(".vs__dropdown-option").contains("Correct").click();
        cy.get("span.vs__selected").contains("Correct");
        cy.get("@onSelected").should(res => {
            expect(res).to.be.calledWith(resource);
        });
    });
    it("should render a date input", () => {
        cy.mount(FormElement, {
            props: {
                attr: {
                    name: "name",
                    label: "Name",
                    type: "date",
                },
                resource,
            },
        });
        cy.get("input").should("have.class", "flatpickr-input");
    });
    it("should handle a form error validation method", () => {
        cy.mount(FormElement, {
            props: {
                attr: {
                    name: "errorField",
                    label: "Error check",
                    type: "text",
                    formErrorHandler: value => {
                        return value.length >= 4;
                    },
                    formErrorMessage: "Must be at least 4 characters",
                },
                resource,
            },
        });
        cy.get("#errorField").type("tes");
        cy.get("span.error").contains("Must be at least 4 characters");
        cy.get("#errorField").type("t");
        cy.get("span.error").should("not.exist");
    });
});
