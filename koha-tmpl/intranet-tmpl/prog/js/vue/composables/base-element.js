export function useBaseElement(instancedElement) {
    /**
     * Identifies and returns the import path for a component based on the attribute type and the show flag.
     *
     * @param {Object} attr - The attribute object containing component details.
     * @param {boolean} [show=false] - A flag indicating whether to use the showElement's component path if available.
     * @returns {string} The computed import path for the component.
     */
    const identifyAndImportComponent = (attr, show = false) => {
        if (attr.type === "date") {
            attr.componentPath = "@koha-vue/components/FlatPickrWrapper.vue";
        }
        if (attr.type === "vendor") {
            attr.componentPath = "@koha-vue/components/FormSelectVendors.vue";
        }
        if (attr.type === "relationshipWidget") {
            attr.componentPath = "@koha-vue/components/RelationshipWidget.vue";
        }
        const importPath = show
            ? attr.showElement?.componentPath
                ? attr.showElement.componentPath
                : attr.componentPath
            : attr.componentPath;

        return importPath;
    };
    /**
     * Returns the value of the property at the given path, if it exists.
     * Traverses the object by splitting the path on '.' and accessing the
     * property at each level. If any level of the path does not exist, or the
     * property does not exist at that level, null is returned.
     *
     * @param {string} path - A string describing the path to the property.
     * @param {Object} obj - The object to traverse.
     * @returns {any|null} The value of the property at the given path, or null.
     */
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
    /**
     * Generates a set of component properties based on the given attribute configuration.
     * The properties are derived from `instancedElement.attr.componentProps` or
     * `instancedElement.attr.showElement.componentProps` depending on the `show` parameter.
     *
     * @param {boolean} show - Determines whether to use the 'showElement' properties.
     * @returns {Object} An object containing the processed properties for the component.
     *                   The properties are adjusted based on their type (e.g., resource,
     *                   boolean, av, filter) and may include additional keys like
     *                   'relationshipFields' and 'index' if applicable.
     */
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
            if (key === "relationshipI18n") {
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
            if (instancedElement.attr.indexRequired) {
                acc.index = instancedElement.index;
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

    /**
     * Updates the extended_attributes property of the provided resource
     * with the given additional field values.
     *
     * @param {Array} additionalFieldValues - Array of objects containing
     *        name and value pairs to be assigned to the resource's
     *        extended_attributes property.
     * @param {Object} resource - The resource object whose
     *        extended_attributes property is to be updated.
     */
    const additionalFieldsChanged = (additionalFieldValues, resource) => {
        resource.extended_attributes = additionalFieldValues;
    };

    return {
        ...instancedElement,
        identifyAndImportComponent,
        getComponentProps,
        accessNestedProperty,
        additionalFieldsChanged,
    };
}
