<script>
import { defineAsyncComponent } from "vue";
import { inject } from "vue";

export default {
    setup(props) {
        //global setup for anything required to render form/show elements
        const AVStore = inject("AVStore");
        const { get_lib_from_av } = AVStore;

        return {
            ...props,
            get_lib_from_av,
        };
    },
    methods: {
        identifyAndImportComponent(attr, show = false) {
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
                ? attr.showElement.componentPath
                : attr.componentPath;

            return defineAsyncComponent(() => import(`${importPath}`));
        },
        getComponentProps(show = false) {
            const propList = show
                ? this.attr.showElement.componentProps
                : this.attr.componentProps;
            if (!propList) {
                return {};
            }
            const props = Object.keys(propList).reduce((acc, key) => {
                // This might be better in a switch statement
                const prop = propList[key];
                if (prop.type === "resource") {
                    acc[key] = this.resource;
                }
                if (prop.hasOwnProperty("resourceProperty")) {
                    if (prop.resourceProperty.includes(".")) {
                        acc[key] = this.accessNestedProperty(
                            prop.resourceProperty,
                            this.resource
                        );
                    } else {
                        acc[key] = this.resource[prop.resourceProperty];
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
                    if (prop.indexRequired && this.index > -1) {
                        acc[key] = `${prop.value}_${this.index}`;
                    }
                }

                if (key === "disabled") {
                    const currentValue = acc[key];
                    acc[key] = !!currentValue;
                }

                if (prop.type === "filter") {
                    Object.keys(prop.keys).forEach(k => {
                        if (
                            prop.keys[k].hasOwnProperty("filterType") &&
                            prop.keys[k].filterType
                        ) {
                            acc[key] = {
                                [k]: {
                                    [prop.keys[k].filterType]:
                                        this.accessNestedProperty(
                                            prop.keys[k].property,
                                            this.resource
                                        ),
                                },
                            };
                        } else {
                            acc[key] = {
                                [k]: this.accessNestedProperty(
                                    prop.keys[k].property,
                                    this.resource
                                ),
                            };
                        }
                    });
                }
                return acc;
            }, {});
            const attr = show ? this.attr.showElement : this.attr;
            if (attr.relationshipFields?.length) {
                props.relationshipFields = attr.relationshipFields;
            }
            return props;
        },
        accessNestedProperty(path, obj) {
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
        },
        additionalFieldsChanged(additionalFieldValues, resource) {
            resource.extended_attributes = additionalFieldValues;
        },
    },
    name: "BaseElement",
};
</script>
