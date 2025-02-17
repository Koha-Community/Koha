<template>
    <label
        v-if="attr.label"
        :for="getElementId"
        :class="{ required: attr.required }"
        :style="{ ...attr.style }"
        >{{ attr.label }}:</label
    >
    <template v-if="attr.type == 'number'">
        <input
            :id="getElementId"
            type="number"
            v-model="resource[attr.name]"
            :placeholder="attr.placeholder || attr.label"
            :required="attr.required ? true : false"
        />
    </template>
    <template v-if="attr.type == 'text'">
        <input
            :id="getElementId"
            v-model="resource[attr.name]"
            :placeholder="attr.placeholder || attr.label"
            :required="attr.required ? true : false"
        />
    </template>
    <template v-else-if="attr.type == 'textarea'">
        <textarea
            :id="getElementId"
            v-model="resource[attr.name]"
            :rows="attr.textAreaRows"
            :cols="attr.textAreaCols"
            :placeholder="attr.placeholder || attr.label"
            :required="attr.required ? true : false"
        />
    </template>
    <template v-else-if="attr.type == 'checkbox'">
        <input
            type="checkbox"
            :id="getElementId"
            v-model="resource[attr.name]"
            @change="attr.onChange && attr.onChange(resource)"
        />
    </template>
    <template v-else-if="attr.type == 'boolean'">
        <label class="radio" :for="getElementId + '_yes'"
            >{{ $__("Yes") }}:
            <input
                type="radio"
                :name="attr.name"
                :id="attr.name + '_yes'"
                :value="true"
                v-model="resource[attr.name]"
            />
        </label>
        <label class="radio" :for="getElementId + '_no'"
            >{{ $__("No") }}:
            <input
                type="radio"
                :name="attr.name"
                :id="attr.name + '_no'"
                :value="false"
                v-model="resource[attr.name]"
            />
        </label>
    </template>
    <template v-else-if="attr.type == 'select'">
        <v-select
            :id="getElementId"
            v-model="resource[attr.name]"
            :label="attr.selectLabel"
            :reduce="av => selectRequiredKey(av)"
            :options="selectOptions"
            :required="!resource[attr.name] && attr.required"
            :disabled="disabled"
            :multiple="attr.allowMultipleChoices"
            @option:selected="attr.onSelected && attr.onSelected(resource)"
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
    </template>
    <template v-else-if="attr.type == 'vendor'">
        <component
            :is="requiredComponent"
            :id="getElementId"
            v-bind="getComponentProps()"
            v-on="getEventHandlers()"
            v-model="resource[attr.name]"
        ></component>
    </template>
    <template v-else-if="attr.type == 'date'">
        <component
            :is="requiredComponent"
            :id="getElementId"
            v-bind="getComponentProps()"
            v-on="getEventHandlers()"
            v-model="resource[attr.name]"
        ></component>
    </template>
    <template v-else-if="attr.type == 'component' && attr.componentPath">
        <component
            v-if="isVModelRequired(attr.componentPath)"
            :is="requiredComponent"
            v-bind="getComponentProps()"
            v-model="resource[attr.name]"
            v-on="getEventHandlers()"
        ></component>
        <component
            v-else
            :is="requiredComponent"
            v-bind="getComponentProps()"
            v-on="getEventHandlers()"
        ></component>
    </template>
    <template
        v-else-if="attr.type == 'relationshipWidget' && attr.componentProps"
    >
        <component
            :is="requiredComponent"
            :title="attr.group ? null : attr.label"
            :apiClient="attr.apiClient"
            :name="attr.name"
            v-bind="getComponentProps()"
            v-on="getEventHandlers()"
        ></component>
    </template>
    <template v-else-if="attr.type == 'relationshipSelect'">
        <FormRelationshipSelect
            v-bind="attr"
            :resource="resource"
        ></FormRelationshipSelect>
    </template>
    <template v-else-if="attr.name == 'additional_fields'">
        <AdditionalFieldsEntry
            :resource="resource"
            :additional_field_values="resource.extended_attributes"
            :extended_attributes_resource_type="
                attr.extended_attributes_resource_type
            "
            @additional-fields-changed="additionalFieldsChanged"
        ></AdditionalFieldsEntry>
    </template>
    <ToolTip v-if="attr.toolTip" :toolTip="attr.toolTip"></ToolTip>
    <span v-if="attr.required" class="required">{{ $__("Required") }}</span>
</template>

<script>
import AdditionalFieldsEntry from "./AdditionalFieldsEntry.vue";
import BaseElement from "./BaseElement.vue";
import FormRelationshipSelect from "./FormRelationshipSelect.vue";
import ToolTip from "./ToolTip.vue";

export default {
    props: {
        resource: Object | null,
        attr: Object | null,
        index: Number | null,
        options: Array,
    },
    extends: BaseElement,
    setup() {
        return {
            ...BaseElement.setup(),
        };
    },
    computed: {
        getElementId() {
            return this.attr.indexRequired
                ? `${this.attr.name}_${this.index}`
                : this.attr.name;
        },
        requiredComponent() {
            const component = this.identifyAndImportComponent(this.attr);
            return component;
        },
        selectOptions() {
            if (this.attr.options) {
                return this.attr.options;
            }
            return this.options;
        },
        disabled() {
            if (typeof this.attr.disabled === "function") {
                return this.attr.disabled(this.resource);
            } else {
                return this.attr.disabled || false;
            }
        },
    },
    methods: {
        selectRequiredKey(av) {
            if (this.attr.requiredKey == "package_id")
                return parseInt(av[this.attr.requiredKey]);
            return av[this.attr.requiredKey];
        },
        isVModelRequired(componentPath) {
            let vModelRequired = true;
            const componentsNotRequiringVModel = [
                "PatronSearch",
                "Documents",
                "AdditionalFields",
            ];
            componentsNotRequiringVModel.forEach(component => {
                if (componentPath.includes(component)) {
                    vModelRequired = false;
                }
            });
            return vModelRequired;
        },
        getEventHandlers() {
            if (this.attr.events == null) return {};
            return this.attr.events.reduce((acc, event) => {
                acc[event.name] = event.callback;
                return acc;
            }, {});
        },
    },
    name: "FormElement",
    components: { FormRelationshipSelect, ToolTip, AdditionalFieldsEntry },
};
</script>

<style scoped>
/* Chrome, Safari, Edge, Opera */
input::-webkit-outer-spin-button,
input::-webkit-inner-spin-button {
    -webkit-appearance: none;
    margin: 0;
}

/* Firefox */
input[type="number"] {
    -moz-appearance: textfield;
}
</style>
