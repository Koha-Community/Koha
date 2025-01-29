<template>
    <template v-if="attr.type == 'text'">
        <label
            :for="`${attr.name}${index}`"
            :class="{ required: attr.required }"
            >{{ attr.label }}:</label
        >
        <input
            :id="`${attr.name}${index}`"
            v-model="resource[attr.name]"
            :placeholder="attr.placeholder || attr.label"
            :required="attr.required ? true : false"
        />
        <span v-if="attr.required" class="required">{{ $__("Required") }}</span>
    </template>
    <template v-else-if="attr.type == 'textarea'">
        <label
            :for="`${attr.name}${index}`"
            :class="{ required: attr.required }"
            >{{ attr.label }}:</label
        >
        <textarea
            :id="`${attr.name}${index}`"
            v-model="resource[attr.name]"
            :rows="attr.textAreaRows"
            :cols="attr.textAreaCols"
            :placeholder="attr.placeholder || attr.label"
            :required="attr.required ? true : false"
        />
        <span v-if="attr.required" class="required">{{ $__("Required") }}</span>
    </template>
    <template v-else-if="attr.type == 'checkbox'">
        <label
            :for="`${attr.name}${index}`"
            :class="{ required: attr.required }"
            >{{ attr.label }}:</label
        >
        <input
            type="checkbox"
            :id="`${attr.name}${index}`"
            v-model="resource[attr.name]"
            @change="attr.onChange && attr.onChange(resource)"
        />
        <span v-if="attr.required" class="required">{{ $__("Required") }}</span>
    </template>
    <template v-else-if="attr.type == 'boolean'">
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
    </template>
    <template v-else-if="attr.type == 'select'">
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
            :disabled="disabled"
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
        <span v-if="attr.required" class="required">{{ $__("Required") }}</span>
    </template>
    <template v-else-if="attr.type == 'component'">
        <label
            v-if="attr.label"
            :for="attr.name"
            :class="{ required: attr.required }"
            >{{ attr.label }}:</label
        >
        <component
            v-if="isVModelRequired(attr.componentPath)"
            :is="requiredComponent"
            v-bind="requiredProps()"
            v-model="resource[attr.name]"
            v-on="getEventHandlers()"
        ></component>
        <component
            v-else
            :is="requiredComponent"
            v-bind="requiredProps()"
            v-on="getEventHandlers()"
        ></component>
        <span v-if="attr.required" class="required">{{ $__("Required") }}</span>
    </template>
    <template v-else-if="attr.type == 'relationship' && attr.componentPath">
        <component
            :is="requiredComponent"
            v-bind="requiredProps()"
            v-on="getEventHandlers()"
        ></component>
    </template>
    <template v-else-if="attr.type == 'relationshipWidget'">
        <component
            :is="relationshipWidget"
            :title="attr.label"
            :apiClient="attr.apiClient"
            :name="attr.name"
            v-bind="requiredProps()"
            v-on="getEventHandlers()"
        ></component>
    </template>
    <template v-else-if="attr.type == 'relationshipSelect'">
        <label
            v-if="attr.label"
            :for="attr.name"
            :class="{ required: attr.required }"
            >{{ attr.label }}:</label
        >
        <FormRelationshipSelect
            v-bind="attr"
            :resource="resource"
        ></FormRelationshipSelect>
        <span v-if="attr.required" class="required">{{ $__("Required") }}</span>
    </template>
</template>

<script>
import BaseElement from "./BaseElement.vue";
import FormRelationshipSelect from "./FormRelationshipSelect.vue";

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
        relationshipWidget() {
            const component = this.identifyAndImportComponent({
                componentPath: "./RelationshipWidget.vue",
            });
            return component;
        },
    },
    methods: {
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
    components: { FormRelationshipSelect },
};
</script>
