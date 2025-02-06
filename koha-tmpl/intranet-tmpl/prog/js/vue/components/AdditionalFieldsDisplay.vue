<template>
    <fieldset
        v-if="additional_field_values.length"
        class="rows"
        id="additional_fields"
    >
        <legend>{{ $__("Additional fields") }}</legend>
        <ol>
            <li
                v-for="additional_field_value in additional_field_values"
                v-bind:key="additional_field_value.id"
            >
                <label
                    :for="`additional_field_` + additional_field_value.field_id"
                >
                    {{ additional_field_value.field_label }}:
                </label>
                <span> {{ additional_field_value.value_str }} </span>
            </li>
        </ol>
    </fieldset>
</template>

<script>
export default {
    data() {
        return {
            fields_to_display: [],
        };
    },
    name: "AdditionalFieldsDisplay",
    props: {
        resource_type: String,
        additional_field_values: Array,
    },
};
</script>
