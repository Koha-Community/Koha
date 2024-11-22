<template>
    <div v-if="attr.type == 'text'">
        <label
            :for="`${attr.name}${index}`"
            :class="{ required: attr.required }"
            >{{ attr.label }}:</label
        >
        <input
            :id="`${attr.name}${index}`"
            v-model="resource[attr.name]"
            :placeholder="attr.label"
            :required="attr.required ? true : false"
        />
        <span v-if="attr.required" class="required">{{ $__("Required") }}</span>
    </div>
    <div v-else-if="attr.type == 'textarea'">
        <label
            :for="`${attr.name}${index}`"
            :class="{ required: attr.required }"
            >{{ attr.label }}:</label
        >
        <textarea
            :id="`${attr.name}${index}`"
            v-model="resource[attr.name]"
            :rows="attr.text_area_rows"
            :cols="attr.text_area_col"
            :placeholder="attr.label"
            :required="attr.required ? true : false"
        />
        <span v-if="attr.required" class="required">{{ $__("Required") }}</span>
    </div>
    <div v-else-if="attr.type == 'boolean'">
        <label :for="`${attr.name}${index}`">{{ attr.label }}:</label>
        <label class="radio" :for="`${attr.name}${index}` + '_yes'"
            >{{ $__("Yes") }}:
            <input
                type="radio"
                :name="attr.name"
                :id="attr.name + '_yes'"
                :value="true"
                v-model="resource[attr.name]"
            />
        </label>
        <label class="radio" :for="attr.name + '_no'"
            >{{ $__("No") }}:
            <input
                type="radio"
                :name="attr.name"
                :id="attr.name + '_no'"
                :value="false"
                v-model="resource[attr.name]"
            />
        </label>
    </div>
    <div v-else-if="attr.type == 'select'">
        <label
            :for="`${attr.name}${index}`"
            :class="{ required: attr.required }"
            >{{ attr.label }}:</label
        >
        <v-select
            :id="`${attr.name}${index}`"
            v-model="resource[attr.name]"
            :label="attr.selectLabel"
            :reduce="av => av[attr.requiredKey]"
            :options="selectOptions"
            :required="!resource[attr.name] && attr.required"
            :disabled="attr.disabled"
        >
            <template v-if="attr.required" #search="{ attributes, events }">
                <input
                    :required="!resource[attr.name]"
                    class="vs__search"
                    v-bind="attributes"
                    v-on="events"
                />
            </template>
        </v-select>
        <span v-if="attr.required" class="required">{{ $__("Required") }}</span>
    </div>
    <div v-else-if="attr.type == 'component'">
        <label :for="attr.name" :class="{ required: attr.required }"
            >{{ attr.label }}:</label
        >
        <component
            v-if="isVModelRequired(attr.componentPath)"
            :is="requiredComponent"
            v-bind="requiredProps()"
            v-model="resource[attr.name]"
        ></component>
        <component
            v-else
            :is="requiredComponent"
            v-bind="requiredProps()"
        ></component>
        <span v-if="attr.required" class="required">{{ $__("Required") }}</span>
    </div>
    <template v-else-if="attr.type == 'relationship'">
        <component :is="requiredComponent" v-bind="requiredProps()"></component>
    </template>
</template>

<script>
import { defineAsyncComponent } from "vue";

export default {
    props: {
        resource: Object | null,
        attr: Object | null,
        index: Number | null,
        options: Array,
    },
    computed: {
        requiredComponent() {
            return defineAsyncComponent(
                () => import(`${this.attr.componentPath}`)
            );
        },
        selectOptions() {
            if (this.attr.options) {
                return this.attr.options;
            }
            return this.options;
        },
    },
    methods: {
        requiredProps() {
            if (!this.attr.props) {
                return {};
            }
            const props = Object.keys(this.attr.props).reduce((acc, key) => {
                // This might be better in a switch statement
                const prop = this.attr.props[key];
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
            if (this.attr.subFields?.length) {
                props.subFields = this.attr.subFields;
            }
            return props;
        },
        isVModelRequired(componentPath) {
            let vModelRequired = true;
            const componentsNotRequiringVModel = ["PatronSearch", "Documents"];
            componentsNotRequiringVModel.forEach(component => {
                if (componentPath.includes(component)) {
                    vModelRequired = false;
                }
            });
            return vModelRequired;
        },
    },
    name: "FormElement",
};
</script>
