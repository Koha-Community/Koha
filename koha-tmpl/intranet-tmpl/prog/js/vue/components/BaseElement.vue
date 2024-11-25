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
            const importPath = show
                ? attr.showElement.componentPath
                : attr.componentPath;

            return defineAsyncComponent(() => import(`${importPath}`));
        },
        requiredProps(show = false) {
            const propList = show
                ? this.attr.showElement.props
                : this.attr.props;
            if (!propList) {
                return {};
            }
            const props = Object.keys(propList).reduce((acc, key) => {
                // This might be better in a switch statement
                const prop = propList[key];
                if (prop.type === "resource") {
                    acc[key] = this.resource;
                }
                if (prop.type === "resourceProperty") {
                    acc[key] = this.resource[prop.resourceProperty];
                }
                if (prop.type === "av") {
                    acc[key] = prop.av;
                }
                if (prop.type === "string") {
                    if (prop.indexRequired && this.index > -1) {
                        acc[key] = `${prop.value}${this.index}`;
                    } else {
                        acc[key] = prop.value;
                    }
                }
                if (prop.type === "boolean") {
                    acc[key] = prop.value;
                }
                return acc;
            }, {});
            if (this.attr.showElement.subFields?.length) {
                props.subFields = this.attr.showElement.subFields;
            }
            return props;
        },
    },
    name: "BaseElement",
};
</script>
