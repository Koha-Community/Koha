import ShowElement from "../../../koha-tmpl/intranet-tmpl/prog/js/vue/components/ShowElement.vue";

const resource = {
    id: 1,
    name: "test",
    showName: "For show",
    nestedObject: {
        nestedProperty: "nested",
    },
    radioCheck: true,
    tableTest: [
        { columnValueOne: "Col 1", columnValueTwo: "Value1" },
        { columnValueOne: "Col 2", columnValueTwo: "Value2" },
        { columnValueOne: "Col 3", columnValueTwo: "Value3" },
    ],
};
const instancedResource = {
    get_lib_from_av: (avCat, value) => {
        return "avValue";
    },
};

describe("ShowElement", () => {
    it("should render a string based on the type and name property of the attribute", () => {
        cy.mount(ShowElement, {
            props: {
                resource,
                instancedResource,
                attr: {
                    type: "text",
                    name: "name",
                    label: "Name",
                },
            },
        });
        cy.get("label").contains("Name");
        cy.get("span").contains(resource.name);
    });
    it("should hide that property if the hidden attribute is set and falsy", () => {
        cy.mount(ShowElement, {
            props: {
                resource,
                instancedResource,
                attr: {
                    type: "text",
                    name: "name",
                    label: "Name",
                    hidden: res => false,
                },
            },
        });
        cy.get("label").should("not.exist");
    });
    it("should wrap that property in a link if the link attribute is set", () => {
        cy.mount(ShowElement, {
            props: {
                resource,
                instancedResource,
                attr: {
                    type: "text",
                    name: "name",
                    label: "Name",
                    link: {
                        href: "blah",
                    },
                },
            },
        });
        cy.get("label").contains("Name");
        cy.get("a").should("have.attr", "href", "blah");
        cy.get("span").contains(resource.name);
    });
    it("should detect a showElement property and use the data from that", () => {
        cy.mount(ShowElement, {
            props: {
                resource,
                instancedResource,
                attr: {
                    type: "text",
                    name: "name",
                    label: "Name",
                    showElement: {
                        type: "text",
                        name: "showName",
                    },
                },
            },
        });
        cy.get("label").contains("Name");
        cy.get("span").contains(resource.showName);
    });
    it("should retrieve a value from a nested object if nesting is detected", () => {
        cy.mount(ShowElement, {
            props: {
                resource,
                instancedResource,
                attr: {
                    type: "text",
                    name: "name",
                    label: "Name",
                    showElement: {
                        type: "text",
                        name: "showName",
                        value: "nestedObject.nestedProperty",
                    },
                },
            },
        });
        cy.get("label").contains("Name");
        cy.get("span").contains(resource.nestedObject.nestedProperty);
    });
    it("should format the value if the formatValue attribute is set", () => {
        cy.mount(ShowElement, {
            props: {
                resource,
                instancedResource,
                attr: {
                    type: "text",
                    name: "name",
                    label: "Name",
                    showElement: {
                        type: "text",
                        name: "showName",
                        format: (attr, resource) => "This has been formatted",
                    },
                },
            },
        });
        cy.get("label").contains("Name");
        cy.get("span").contains("This has been formatted");
    });
    it("should correctly assign the value to a radio type attr", () => {
        cy.mount(ShowElement, {
            props: {
                resource,
                instancedResource,
                attr: {
                    type: "text",
                    name: "name",
                    label: "Name",
                    showElement: {
                        type: "radio",
                        name: "radioCheck",
                        value: "radioCheck",
                        options: [
                            { value: true, description: "Correct" },
                            { value: false, description: "Incorrect" },
                        ],
                    },
                },
            },
        });
        cy.get("span").contains("Correct");
    });
    it("should correctly assign the value to a select/av type attr", () => {
        cy.mount(ShowElement, {
            props: {
                resource,
                instancedResource,
                attr: {
                    type: "text",
                    name: "name",
                    label: "Name",
                    avCat: "testAv",
                    showElement: {
                        type: "select",
                    },
                },
            },
        });
        cy.get("span").contains("avValue");
    });
    it("should correctly assign the value to boolean based attrs", () => {
        cy.mount(ShowElement, {
            props: {
                resource,
                instancedResource,
                attr: {
                    type: "text",
                    name: "name",
                    label: "Name",
                    showElement: {
                        type: "boolean",
                    },
                },
            },
        });
        cy.get("span").contains("Yes");
    });
    it("should correctly render a table when required", () => {
        cy.mount(ShowElement, {
            props: {
                resource,
                instancedResource,
                attr: {
                    type: "text",
                    name: "name",
                    label: "Name",
                    showElement: {
                        type: "table",
                        columnData: "tableTest",
                        hidden: () => true,
                        columns: [
                            { name: "Column 1", value: "columnValueOne" },
                            { name: "Column 2", value: "columnValueTwo" },
                        ],
                    },
                },
            },
        });
        cy.get("table thead th:first").contains("Column 1");
        cy.get("table thead th").eq(1).contains("Column 2");
        cy.get("table tbody tr:first td:first").contains("Col 1");
        cy.get("table tbody tr:first td").eq(1).contains("Value1");
        cy.get("table tbody tr:nth-child(2) td:first").contains("Col 2");
        cy.get("table tbody tr:nth-child(2) td").eq(1).contains("Value2");
    });
    it("should render a component if passed a path and assign props", () => {
        cy.mount(ShowElement, {
            props: {
                resource,
                instancedResource,
                attr: {
                    type: "text",
                    name: "name",
                    showElement: {
                        type: "component",
                        hidden: () => true,
                        componentPath: "./Cypress/ShowElementComponentType.vue",
                        componentProps: {
                            testString: {
                                type: "string",
                                value: "A test string",
                            },
                            resourceProp: {
                                resourceProperty: "showName",
                            },
                        },
                    },
                },
            },
        });
        cy.get("h1").contains("A test string");
        cy.get("h2").contains(resource.showName);
    });
});
