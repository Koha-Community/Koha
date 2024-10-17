<template>
    <div v-if="attr.type == 'text'">
        <label :for="attr.name" :class="{ required: attr.required }"
            >{{ attr.label }}:</label
        >
        <input
            :id="attr.name"
            v-model="resource[attr.name]"
            :placeholder="attr.label"
            :required="attr.required ? true : false"
        />
        <span v-if="attr.required" class="required">{{ $__("Required") }}</span>
    </div>
    <div v-else-if="attr.type == 'textarea'">
        <label :for="attr.name" :class="{ required: attr.required }"
            >{{ attr.label }}:</label
        >
        <textarea
            :id="attr.name"
            v-model="resource[attr.name]"
            :rows="attr.text_area_rows"
            :cols="attr.text_area_col"
            :placeholder="attr.label"
            :required="attr.required ? true : false"
        />
        <span v-if="attr.required" class="required">{{ $__("Required") }}</span>
    </div>
    <div v-else-if="attr.type == 'boolean'">
        <label :for="attr.name">{{ attr.label }}:</label>
        <label class="radio" :for="attr.name + '_yes'"
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
    <div v-else-if="attr.type == 'av'">
        <label :for="attr.name" :class="{ required: attr.required }"
            >{{ attr.label }}:</label
        >
        <v-select
            :id="attr.name"
            v-model="resource[attr.name]"
            label="description"
            :reduce="av => av.value"
            :options="attr.options"
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
    <div
        v-else-if="
            attr.type == 'component' && attr.component == 'FormSelectVendors'
        "
    >
        <label :for="attr.name">{{ attr.label }}:</label>
        <FormSelectVendors :id="attr.name" v-model="resource[attr.name]">
        </FormSelectVendors>
    </div>
</template>

<script>
import FormSelectVendors from "./FormSelectVendors.vue";
export default {
    props: {
        resource: null,
        attr: null,
    },
    components: {
        FormSelectVendors,
    },
    name: "FormElement",
};
</script>
