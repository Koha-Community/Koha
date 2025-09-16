import UseBaseResource from "@cypress/component/UseBaseResource.vue";

const globalConfig = {
    global: {
        stores: ["mainStore", "navigationStore"],
        testingStore: {
            initialState: {
                authorisedValues: {
                    av_test: [
                        {
                            description: "Test value",
                            value: "test_value",
                        },
                    ],
                },
            },
        },
    },
    props: {
        resourceConfig: cy.getBaseResourceConfig(),
    },
};

describe("useBaseResource - toolbar methods", () => {
    beforeEach(() => {
        globalConfig.props.resourceConfig = cy.getBaseResourceConfig();
    });
    it("toolbarButtons - default buttons", () => {
        cy.mount(UseBaseResource, globalConfig).then(({ component }) => {
            const baseResource = component.result;
            const toolbarButtons = baseResource.toolbarButtons.value;

            const defaultButtonsShowComponent = toolbarButtons({}, "show", {});
            expect(defaultButtonsShowComponent).to.have.length(2);
            expect(defaultButtonsShowComponent[0].action).to.be.equal("edit");
            expect(defaultButtonsShowComponent[1].action).to.be.equal("delete");

            const defaultButtonsListComponent = toolbarButtons({}, "list", {});
            expect(defaultButtonsListComponent).to.have.length(1);
            expect(defaultButtonsListComponent[0].action).to.be.equal("add");
        });
    });
    it("toolbarButtons - additional buttons", () => {
        const additionalToolbarButtons = () => {
            return {
                list: [{ action: "testList", label: "Test" }],
                show: [{ action: "testShow", label: "Test" }],
            };
        };
        globalConfig.props.resourceConfig.additionalToolbarButtons =
            additionalToolbarButtons;
        cy.mount(UseBaseResource, globalConfig).then(({ component }) => {
            const baseResource = component.result;
            const toolbarButtons = baseResource.toolbarButtons.value;

            const defaultButtonsShowComponent = toolbarButtons({}, "show", {});
            expect(defaultButtonsShowComponent).to.have.length(3);
            expect(defaultButtonsShowComponent[2].action).to.be.equal(
                "testShow"
            );

            const defaultButtonsListComponent = toolbarButtons({}, "list", {});
            expect(defaultButtonsListComponent).to.have.length(2);
            expect(defaultButtonsListComponent[1].action).to.be.equal(
                "testList"
            );
        });
    });
    it("toolbarButtons - additional buttons with the order set by the index property", () => {
        const additionalToolbarButtons = () => {
            return {
                list: [{ action: "testList", label: "Test" }],
                show: [{ action: "testShow", label: "Test", index: -1 }],
            };
        };
        globalConfig.props.resourceConfig.additionalToolbarButtons =
            additionalToolbarButtons;
        cy.mount(UseBaseResource, globalConfig).then(({ component }) => {
            const baseResource = component.result;
            const toolbarButtons = baseResource.toolbarButtons.value;

            const defaultButtonsShowComponent = toolbarButtons({}, "show", {});
            expect(defaultButtonsShowComponent).to.have.length(3);
            expect(defaultButtonsShowComponent[0].action).to.be.equal(
                "testShow"
            );

            const defaultButtonsListComponent = toolbarButtons({}, "list", {});
            expect(defaultButtonsListComponent).to.have.length(2);
            expect(defaultButtonsListComponent[1].action).to.be.equal(
                "testList"
            );
        });
    });
    it("goToResourceAdd", () => {
        cy.mount(UseBaseResource, globalConfig).then(({ component }) => {
            const baseResource = component.result;
            const goToResourceAdd = baseResource.goToResourceAdd;
            const router = baseResource.router;
            cy.stub(router, "push");
            goToResourceAdd();
            expect(router.push).to.have.been.calledWith({ name: "testAdd" });
        });
    });
    it("goToResourceEdit", () => {
        cy.mount(UseBaseResource, globalConfig).then(({ component }) => {
            const baseResource = component.result;
            const goToResourceEdit = baseResource.goToResourceEdit;
            const router = baseResource.router;
            cy.stub(router, "push");
            goToResourceEdit({ id: 1 });
            expect(router.push).to.have.been.calledWith({
                name: "testEdit",
                params: {
                    id: 1,
                },
            });
        });
    });
    it("goToResourceShow", () => {
        cy.mount(UseBaseResource, globalConfig).then(({ component }) => {
            const baseResource = component.result;
            const goToResourceShow = baseResource.goToResourceShow;
            const router = baseResource.router;
            cy.stub(router, "push");
            goToResourceShow({ id: 1 });
            expect(router.push).to.have.been.calledWith({
                name: "testShow",
                params: {
                    id: 1,
                },
            });
        });
    });
    it("goToResourceList", () => {
        cy.mount(UseBaseResource, globalConfig).then(({ component }) => {
            const baseResource = component.result;
            const goToResourceList = baseResource.goToResourceList;
            const router = baseResource.router;
            cy.stub(router, "push");
            goToResourceList({ id: 1 });
            expect(router.push).to.have.been.calledWith({ name: "testList" });
        });
    });
    // it("doResourceDelete", () => {
    //     cy.mount(UseBaseResource, globalConfig).then(({ component }) => {
    //         cy.get_mainStore().then((mainStore) => {
    //             const baseResource = component.result;
    //             const doResourceDelete = baseResource.doResourceDelete;
    //             // const router = baseResource.router;
    //             // cy.stub(router, "push");
    //             cy.stub(mainStore, "setConfirmationDialog")
    //             // const confDialogSpy = cy.spy(mainStore, "setConfirmationDialog");

    //             doResourceDelete({id: 1, name: "Test"});
    //             expect(mainStore.setConfirmationDialog).to.have.been.called();
    //         })
    //     });
    // });
});

describe("useBaseResource - datatables methods", () => {
    beforeEach(() => {
        globalConfig.props.resourceConfig = cy.getBaseResourceConfig();
    });
    it("getResourceTableUrl", () => {
        cy.mount(UseBaseResource, globalConfig).then(({ component }) => {
            const baseResource = component.result;
            const getResourceTableUrl = baseResource.getResourceTableUrl;
            expect(getResourceTableUrl()).to.be.equal("testTableUrl");
        });
    });
    it("getResourceShowURL", () => {
        cy.mount(UseBaseResource, globalConfig).then(({ component }) => {
            const baseResource = component.result;
            const getResourceShowURL = baseResource.getResourceShowURL;
            const router = baseResource.router;
            cy.stub(router, "resolve").callsFake(() => {
                return {
                    href: "testShow",
                };
            });
            getResourceShowURL(10);
            expect(router.resolve).to.have.been.calledWith({
                name: "testShow",
                params: { id: 10 },
            });
        });
    });
    it("getFilterValues - no additionalFilters", () => {
        const filters = {
            filterValue: true,
            anotherFilterValue: "filter",
            andAnother: "another",
        };
        cy.mount(UseBaseResource, globalConfig).then(({ component }) => {
            const baseResource = component.result;
            const getFilterValues = baseResource.getFilterValues;
            const filterResult = getFilterValues(filters);
            expect(Object.keys(filterResult)).to.have.length(3);
            expect(filterResult.filterValue).to.equal(true);
            expect(filterResult.anotherFilterValue).to.equal("filter");
            expect(filterResult.andAnother).to.equal("another");
        });
    });
    it("getFilterValues - with additionalFilters", () => {
        const filters = {
            filterValue: true,
        };
        globalConfig.props.resourceConfig.table.additionalFilters = [
            { name: "additionalFilter", value: "test" },
            { name: "filterValue", value: false },
        ];
        cy.mount(UseBaseResource, globalConfig).then(({ component }) => {
            const baseResource = component.result;
            const getFilterValues = baseResource.getFilterValues;
            const filterResult = getFilterValues(filters);
            expect(Object.keys(filterResult)).to.have.length(2);
            expect(filterResult.filterValue).to.equal(true);
            expect(filterResult.additionalFilter).to.equal("test");
        });
    });
});

describe("useBaseResource - resource display methods", () => {
    beforeEach(() => {
        globalConfig.props.resourceConfig = cy.getBaseResourceConfig();
    });
    it("getFieldGroupings - form with no field groups", () => {
        globalConfig.props.resourceConfig.resourceAttrs =
            cy.getResourceAttrsWithNoGroups();
        cy.mount(UseBaseResource, globalConfig).then(({ component }) => {
            const baseResource = component.result;
            const getFieldGroupings = baseResource.getFieldGroupings;
            const fieldGroupings = getFieldGroupings("Form");
            expect(fieldGroupings[0].name).to.equal(null);
            expect(fieldGroupings[0].fields).to.have.length(3);
            expect(fieldGroupings[0].fields[2].name).to.equal("formField");
            expect(
                fieldGroupings[0].fields[1].relationshipFields[0]
                    .relationshipName
            ).to.equal("relationships");
            expect(fieldGroupings[0].hasDataToDisplay).to.equal(false);
        });
    });
    it("getFieldGroupings - show with no field groups", () => {
        globalConfig.props.resourceConfig.resourceAttrs =
            cy.getResourceAttrsWithNoGroups();
        cy.mount(UseBaseResource, globalConfig).then(({ component }) => {
            const baseResource = component.result;
            const getFieldGroupings = baseResource.getFieldGroupings;
            const fieldGroupings = getFieldGroupings("Show", {
                name: "A name value",
            });
            expect(fieldGroupings[0].name).to.equal(null);
            expect(fieldGroupings[0].fields).to.have.length(4);
            expect(fieldGroupings[0].fields[2].name).to.equal("showField");
            expect(fieldGroupings[0].hasDataToDisplay).to.equal(true);
        });
    });
    it("getFieldGroupings - show with no field group and additional fields", () => {
        globalConfig.props.resourceConfig.resourceAttrs =
            cy.getResourceAttrsWithNoGroups();
        globalConfig.props.resourceConfig.extendedAttributesResourceType =
            "test";
        cy.mount(UseBaseResource, globalConfig).then(({ component }) => {
            const baseResource = component.result;
            const getFieldGroupings = baseResource.getFieldGroupings;
            const fieldGroupings = getFieldGroupings("Show", {
                name: "A name value",
            });
            expect(fieldGroupings[0].fields[4].name).to.equal(
                "additional_fields"
            );
        });
    });
    it("getFieldGroupings - form with field groups", () => {
        globalConfig.props.resourceConfig.resourceAttrs =
            cy.getResourceAttrsWithGroups();
        cy.mount(UseBaseResource, globalConfig).then(({ component }) => {
            const baseResource = component.result;
            const getFieldGroupings = baseResource.getFieldGroupings;
            const fieldGroupings = getFieldGroupings("Form");
            expect(fieldGroupings).to.have.length(2);

            const firstGroup = fieldGroupings[0];
            expect(firstGroup.name).to.equal("Group 2");
            expect(firstGroup.fields).to.have.length(2);
            expect(firstGroup.fields[0].name).to.equal("name");
            expect(firstGroup.fields[1].name).to.equal("formField");

            const secondGroup = fieldGroupings[1];
            expect(secondGroup.name).to.equal("Group 3");
            expect(secondGroup.fields).to.have.length(1);
            expect(secondGroup.fields[0].name).to.equal("relationships");
        });
    });
    it("getFieldGroupings - show with field groups and limited data in the resource", () => {
        globalConfig.props.resourceConfig.resourceAttrs =
            cy.getResourceAttrsWithGroups();
        cy.mount(UseBaseResource, globalConfig).then(({ component }) => {
            const baseResource = component.result;
            const getFieldGroupings = baseResource.getFieldGroupings;
            const fieldGroupings = getFieldGroupings("Show", {
                name: "A name value",
            });
            expect(fieldGroupings).to.have.length(1);

            const firstGroup = fieldGroupings[0];
            expect(firstGroup.name).to.equal("Group 2");
            expect(firstGroup.fields).to.have.length(1);
            expect(firstGroup.fields[0].name).to.equal("name");
        });
    });
    it("getFieldGroupings - show with field groups and fully populated data in the resource", () => {
        globalConfig.props.resourceConfig.resourceAttrs =
            cy.getResourceAttrsWithGroups();
        cy.mount(UseBaseResource, globalConfig).then(({ component }) => {
            const baseResource = component.result;
            const getFieldGroupings = baseResource.getFieldGroupings;
            const fieldGroupings = getFieldGroupings("Show", {
                name: "A name value",
                showField: "test",
                displayName: "test",
            });
            expect(fieldGroupings).to.have.length(3);

            const firstGroup = fieldGroupings[0];
            expect(firstGroup.name).to.equal("Group 2");
            expect(firstGroup.fields).to.have.length(1);
            expect(firstGroup.fields[0].name).to.equal("name");

            const secondGroup = fieldGroupings[1];
            expect(secondGroup.name).to.equal("Group 3");
            expect(secondGroup.fields).to.have.length(2);
            expect(secondGroup.fields[0].name).to.equal("relationships");
            expect(secondGroup.fields[1].name).to.equal("displayName");

            const thirdGroup = fieldGroupings[2];
            expect(thirdGroup.name).to.equal("Group 1");
            expect(thirdGroup.fields).to.have.length(1);
            expect(thirdGroup.fields[0].name).to.equal("showField");
        });
    });
    it("getFieldGroupings - show with field groups and splitScreen mode enabled", () => {
        globalConfig.props.resourceConfig.resourceAttrs =
            cy.getResourceAttrsWithGroups();
        globalConfig.props.resourceConfig.showGroupsDisplayMode = "splitScreen";
        globalConfig.props.resourceConfig.splitScreenGroupings = [
            { name: "Group 1", pane: 1 },
            { name: "Group 2", pane: 2 },
            { name: "Group 3", pane: 2 },
        ];
        cy.mount(UseBaseResource, globalConfig).then(({ component }) => {
            const baseResource = component.result;
            const getFieldGroupings = baseResource.getFieldGroupings;
            const fieldGroupings = getFieldGroupings("Show", {
                name: "A name value",
                showField: "test",
                displayName: "test",
            });
            const firstGroup = fieldGroupings[0];
            expect(firstGroup.splitPane).to.equal(2);
            const secondGroup = fieldGroupings[1];
            expect(secondGroup.splitPane).to.equal(2);
            const thirdGroup = fieldGroupings[2];
            expect(thirdGroup.splitPane).to.equal(1);
        });
    });
    it("getResource", () => {
        cy.mount(UseBaseResource, globalConfig).then(({ component }) => {
            const baseResource = component.result;
            const getResource = baseResource.getResource;
            const apiClient = globalConfig.props.resourceConfig.apiClient;
            const apiSpy = cy.spy(apiClient, "get");
            const componentData = {
                instancedResource: {
                    afterResourceFetch: () => {},
                },
                resource: {
                    value: {},
                },
                initialized: {
                    value: false,
                },
            };
            const resourceFetchSpy = cy.spy(
                componentData.instancedResource,
                "afterResourceFetch"
            );

            getResource(1, componentData, "Form")
                .then(() => {
                    expect(apiSpy).to.have.been.called;
                })
                .then(() => {
                    expect(resourceFetchSpy).to.be.calledWith(
                        componentData,
                        { id: 1, name: "Object 1" },
                        "Form"
                    );
                });
        });
    });
    it("resourceNamePlural", () => {
        cy.mount(UseBaseResource, globalConfig).then(({ component }) => {
            const baseResource = component.result;
            const resourceNamePlural = baseResource.resourceNamePlural;
            expect(resourceNamePlural.value).to.equal("testObjects");
        });
    });
});

describe("useBaseResource - resource creation methods", () => {
    beforeEach(() => {
        globalConfig.props.resourceConfig = cy.getBaseResourceConfig();
    });
    it("additionalFieldsChanged", () => {
        cy.mount(UseBaseResource, globalConfig).then(({ component }) => {
            const baseResource = component.result;
            const additionalFieldsChanged =
                baseResource.additionalFieldsChanged;
            const resource = {
                extended_attributes: null,
            };
            const additionalFieldValues = "A new value";
            additionalFieldsChanged(additionalFieldValues, resource);
            expect(resource.extended_attributes).to.equal(
                additionalFieldValues
            );
        });
    });
    it("newResource", () => {
        globalConfig.props.resourceConfig.resourceAttrs =
            cy.getResourceAttrsWithNoGroups();
        globalConfig.props.resourceConfig.extendedAttributesResourceType =
            "test";
        cy.mount(UseBaseResource, globalConfig).then(({ component }) => {
            const baseResource = component.result;
            const newResource = baseResource.newResource;

            expect(newResource.value).to.deep.equal({
                id: null,
                name: "",
                relationships: [],
                showField: "",
                formField: "",
                displayName: "",
                select: "",
                textarea: "",
                boolean: false,
                checkbox: false,
                dummyType: null,
                defaultValue: "This is a default value",
                extended_attributes: [],
            });
        });
    });
});

describe("useBaseResource - resource utility methods", () => {
    beforeEach(() => {
        globalConfig.props.resourceConfig = cy.getBaseResourceConfig();
    });
    it("hasAdditionalFields", () => {
        globalConfig.props.resourceConfig.extendedAttributesResourceType =
            "test";
        cy.mount(UseBaseResource, globalConfig).then(({ component }) => {
            const baseResource = component.result;
            const hasAdditionalFields = baseResource.hasAdditionalFields;
            expect(hasAdditionalFields.value).to.equal(true);
        });
    });
    it("refreshTemplateState", () => {
        cy.mount(UseBaseResource, globalConfig).then(({ component }) => {
            const baseResource = component.result;
            const refreshTemplateState = baseResource.refreshTemplateState;
            const refreshTemplate = baseResource.refreshTemplate;
            expect(refreshTemplate.value).to.equal(0);
            refreshTemplateState();
            expect(refreshTemplate.value).to.equal(1);
            refreshTemplateState();
            expect(refreshTemplate.value).to.equal(2);
        });
    });
    it("populateAttributesWithAuthorisedValues", () => {
        globalConfig.props.resourceConfig.resourceAttrs =
            cy.getResourceAttrsWithNoGroups();
        cy.mount(UseBaseResource, globalConfig).then(({ component }) => {
            const avCatResourceAttr =
                globalConfig.props.resourceConfig.resourceAttrs.find(
                    ra => !!ra.avCat
                );
            expect(avCatResourceAttr.options).to.exist;
            expect(Object.keys(avCatResourceAttr.options)).to.have.length(1);
            expect(avCatResourceAttr.options[0].description).to.equal(
                "Test value"
            );
            expect(avCatResourceAttr.options[0].value).to.equal("test_value");

            const avRelationshipField =
                globalConfig.props.resourceConfig.resourceAttrs
                    .find(ra => ra.name === "relationships")
                    .relationshipFields.find(rf => !!rf.avCat);
            expect(avRelationshipField.options).to.exist;
            expect(Object.keys(avRelationshipField.options)).to.have.length(1);
            expect(avRelationshipField.options[0].description).to.equal(
                "Test value"
            );
            expect(avRelationshipField.options[0].value).to.equal("test_value");
        });
    });
});
