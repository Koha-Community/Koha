import { defineAsyncComponent, inject } from "vue";

export function useBaseElement(instancedElement) {
    const AVStore = inject("AVStore");
    const { get_lib_from_av } = AVStore;

    const identifyAndImportComponent = (attr, show = false) => {
        if (attr.type === "date") {
            attr.componentPath = "./FlatPickrWrapper.vue";
        }
        if (attr.type === "vendor") {
            attr.componentPath = "./FormSelectVendors.vue";
        }
        if (attr.type === "relationshipWidget") {
            attr.componentPath = "./RelationshipWidget.vue";
        }
        const importPath = show
            ? attr.showElement?.componentPath
                ? attr.showElement.componentPath
                : attr.componentPath
            : attr.componentPath;

        return importPath;
    };
    const accessNestedProperty = (path, obj) => {
        const keys = path.split(".");
        let property = null;
        let current = obj;
        keys.forEach(key => {
            if (current.hasOwnProperty(key) && current[key]) {
                property = current[key];
                current = current[key];
            } else {
                property = null;
                current = {};
            }
        });
        return property;
    };
    const getComponentProps = (show = false) => {
        const propList = show
            ? instancedElement.attr.showElement?.componentProps
                ? instancedElement.attr.showElement.componentProps
                : instancedElement.attr.componentProps
            : instancedElement.attr.componentProps;
        if (!propList) {
            return {};
        }
        const props = Object.keys(propList).reduce((acc, key) => {
            // This might be better in a switch statement
            const prop = propList[key];
            if (prop.type === "resource") {
                acc[key] = instancedElement.resource;
            }
            if (prop.hasOwnProperty("resourceProperty")) {
                let propertyValue;
                if (prop.resourceProperty.includes(".")) {
                    propertyValue = accessNestedProperty(
                        prop.resourceProperty,
                        instancedElement.resource
                    );
                } else {
                    propertyValue =
                        instancedElement.resource[prop.resourceProperty];
                }
                if (Object.keys(prop).length === 1) {
                    acc[key] = propertyValue;
                } else {
                    prop.value = propertyValue;
                }
            }
            if (key === "relationshipStrings") {
                acc[key] = prop;
            }
            if (prop.type === "av") {
                acc[key] = prop.av;
            }
            if (
                prop.type === "boolean" ||
                prop.type === "object" ||
                prop.type === "string" ||
                prop.type === "date"
            ) {
                acc[key] = prop.value;
                if (prop.indexRequired && instancedElement.index > -1) {
                    acc[key] = `${prop.value}_${instancedElement.index}`;
                }
            }

            if (key === "disabled") {
                if (
                    typeof prop === "object" &&
                    prop.hasOwnProperty("qualifier")
                ) {
                    let currentValue = prop.value;
                    if (prop.qualifier === "!") {
                        currentValue = !currentValue;
                    }
                    acc[key] = !!currentValue;
                } else {
                    const currentValue = acc[key];
                    acc[key] = !!currentValue;
                }
            }

            if (prop.type === "filter") {
                Object.keys(prop.keys).forEach(k => {
                    if (
                        prop.keys[k].hasOwnProperty("filterType") &&
                        prop.keys[k].filterType
                    ) {
                        acc[key] = {
                            [k]: {
                                [prop.keys[k].filterType]: accessNestedProperty(
                                    prop.keys[k].property,
                                    instancedElement.resource
                                ),
                            },
                        };
                    } else {
                        acc[key] = {
                            [k]: accessNestedProperty(
                                prop.keys[k].property,
                                instancedElement.resource
                            ),
                        };
                    }
                });
            }
            return acc;
        }, {});
        const attr = show
            ? instancedElement.attr.showElement
                ? instancedElement.attr.showElement
                : instancedElement.attr
            : instancedElement.attr;
        if (attr.relationshipFields?.length) {
            props.relationshipFields = attr.relationshipFields;
        }
        return props;
    };

    const additionalFieldsChanged = (additionalFieldValues, resource) => {
        resource.extended_attributes = additionalFieldValues;
    };

    return {
        ...instancedElement,
        get_lib_from_av,
        identifyAndImportComponent,
        getComponentProps,
        accessNestedProperty,
        additionalFieldsChanged,
    };
}
