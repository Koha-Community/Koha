<template>
    <label
        v-if="attr.label"
        :for="getElementId"
        :class="{ required: attr.required }"
        :style="{ ...attr.style }"
        >{{ attr.label }}:</label
    >
    <template v-if="attr.type == 'number'">
        <InputNumberElement
            :id="getElementId"
            v-model="resource[attr.name]"
            :placeholder="attr.placeholder || attr.label"
            :required="attr.required ? true : false"
        />
    </template>
    <template v-else-if="attr.type == 'text'">
        <InputTextElement
            :id="getElementId"
            v-model="resource[attr.name]"
            :placeholder="attr.placeholder || attr.label"
            :required="attr.required ? true : false"
        />
    </template>
    <template v-else-if="attr.type == 'textarea'">
        <TextareaElement
            :id="getElementId"
            v-model="resource[attr.name]"
            :rows="attr.textAreaRows"
            :cols="attr.textAreaCols"
            :placeholder="attr.placeholder || attr.label"
            :required="attr.required ? true : false"
        />
    </template>
    <template v-else-if="attr.type == 'checkbox'">
        <InputCheckboxElement
            :id="getElementId"
            type="checkbox"
            v-model="resource[attr.name]"
            :changeMethod="attr.onChange && attr.onChange.bind(this, resource)"
        />
    </template>
    <template v-else-if="attr.type == 'radio'">
        <template
            v-for="(option, index) in attr.options"
            :key="`radio-option-${index}`"
        >
            <label
                v-if="option.description"
                :for="attr.name + '_' + option.value"
                >{{ option.description }}:</label
            >
            <InputRadioElement
                :name="option.description"
                :id="attr.name + '_' + option.value"
                :value="option.value"
                :checked="
                    (!Object.keys(resource).includes(attr.name) &&
                        attr.default == option.value) ||
                    (Object.keys(resource).includes(attr.name) &&
                        option.value == resource[attr.name])
                "
                v-model="resource[attr.name]"
                @change="attr.onChange && attr.onChange.bind(this, resource)"
            />
        </template>
    </template>
    <template v-else-if="attr.type == 'boolean'">
        <label class="radio" :for="getElementId + '_yes'"
            >{{ $__("Yes") }}:
            <InputRadioElement
                type="radio"
                :name="attr.name"
                :id="attr.name + '_yes'"
                :value="true"
                :checked="resource[attr.name] == true"
                v-model="resource[attr.name]"
            />
        </label>
        <label class="radio" :for="getElementId + '_no'"
            >{{ $__("No") }}:
            <InputRadioElement
                type="radio"
                :name="attr.name"
                :id="attr.name + '_no'"
                :checked="resource[attr.name] == false"
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
    <template v-else-if="attr.type == 'additional_fields'">
        <AdditionalFieldsEntry
            :resource="resource"
            :additional_field_values="resource.extended_attributes"
            :extended_attributes_resource_type="
                attr.extended_attributes_resource_type
            "
            @additional-fields-changed="additionalFieldsChanged"
        ></AdditionalFieldsEntry>
    </template>
    <template v-else>
        <span>{{
            $__("Programming error: unknown type %s").format(attr.type)
        }}</span>
    </template>
    <ToolTip v-if="attr.toolTip" :toolTip="attr.toolTip"></ToolTip>
    <span v-if="attr.required" class="required">{{ $__("Required") }}</span>
</template>

<script>
import AdditionalFieldsEntry from "./AdditionalFieldsEntry.vue";
import BaseElement from "./BaseElement.vue";
import InputTextElement from "./Elements/InputTextElement.vue";
import InputNumberElement from "./Elements/InputNumberElement.vue";
import InputCheckboxElement from "./Elements/InputCheckboxElement.vue";
import TextareaElement from "./Elements/TextareaElement.vue";
import FormRelationshipSelect from "./FormRelationshipSelect.vue";
import ToolTip from "./ToolTip.vue";
import InputRadioElement from "./Elements/InputRadioElement.vue";

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
            return this.attr.id
                ? this.attr.id
                : this.attr.indexRequired
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
    components: {
        FormRelationshipSelect,
        ToolTip,
        AdditionalFieldsEntry,
        InputTextElement,
        InputNumberElement,
        InputCheckboxElement,
        TextareaElement,
        InputRadioElement,
    },
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

.filters > input[type="radio"] {
    min-width: 0 !important;
}
</style>
