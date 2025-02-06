<template>
    <fieldset
        v-if="available_fields.length"
        class="rows"
        id="additional_fields"
    >
        <legend>{{ $__("Additional fields") }}</legend>
        <ol>
            <template
                v-for="available_field in available_fields"
                v-bind:key="available_field.extended_attribute_type_id"
            >
                <template
                    v-if="
                        available_field.authorised_value_category_name &&
                        !available_field.repeatable
                    "
                >
                    <li>
                        <label
                            :for="
                                `additional_field_` +
                                available_field.extended_attribute_type_id
                            "
                            >{{ available_field.name }}:
                        </label>
                        <v-select
                            :id="
                                `additional_field_` +
                                available_field.extended_attribute_type_id
                            "
                            :name="available_field.name"
                            v-model="
                                current_additional_fields_values[
                                    available_field.extended_attribute_type_id
                                ]
                            "
                            :options="
                                av_options[
                                    available_field
                                        .authorised_value_category_name
                                ]
                            "
                        />
                    </li>
                </template>
                <template
                    v-if="
                        available_field.authorised_value_category_name &&
                        available_field.repeatable
                    "
                >
                    <li>
                        <label
                            :for="
                                `additional_field_` +
                                available_field.extended_attribute_type_id
                            "
                            >{{ available_field.name }}:
                        </label>
                        <v-select
                            :id="
                                `additional_field_` +
                                available_field.extended_attribute_type_id
                            "
                            :name="available_field.name"
                            :multiple="available_field.repeatable"
                            v-model="
                                current_additional_fields_values[
                                    available_field.extended_attribute_type_id
                                ]
                            "
                            :options="
                                av_options[
                                    available_field
                                        .authorised_value_category_name
                                ]
                            "
                        />
                    </li>
                </template>

                <template
                    v-if="!available_field.authorised_value_category_name"
                >
                    <li
                        v-for="current in current_additional_fields_values[
                            available_field.extended_attribute_type_id
                        ]"
                        v-bind:key="current.id"
                    >
                        <label
                            :for="
                                `additional_field_` +
                                available_field.extended_attribute_type_id
                            "
                            >{{ available_field.name }}:
                        </label>
                        <input type="text" v-model="current.value" />
                        <a
                            href="#"
                            class="clear_attribute"
                            @click="clearField(current, $event)"
                        >
                            <i class="fa fa-fw fa-trash-can"></i>
                            {{ $__("Clear") }}
                        </a>
                        <template v-if="available_field.repeatable">
                            <a
                                href="#"
                                class="clone_attribute"
                                @click="
                                    cloneField(available_field, current, $event)
                                "
                            >
                                <i class="fa fa-fw fa-plus"></i>
                                {{ $__("New") }}
                            </a>
                        </template>
                    </li>
                </template>
            </template>
        </ol>
    </fieldset>
</template>

<script>
import { APIClient } from "../fetch/api-client.js";

export default {
    data() {
        return {
            available_fields: [],
            av_options: [],
            current_additional_fields_values: {},
        };
    },
    beforeCreate() {
        const client = APIClient.additional_fields;
        client.additional_fields.getAll(this.resource_type).then(
            available_fields => {
                this.available_fields = available_fields;
                this.initialized = true;
            },
            error => {}
        );
    },
    watch: {
        current_additional_fields_values: {
            deep: true,
            handler(current_additional_fields_values) {
                this.updateParentAdditionalFieldValues(
                    current_additional_fields_values
                );
            },
        },
        available_fields: function (available_fields) {
            if (available_fields) {
                const client_av = APIClient.authorised_values;
                let av_cat_array = available_fields
                    .map(field => field.authorised_value_category_name)
                    .filter(field => field);

                client_av.values
                    .getCategoriesWithValues([
                        ...new Set(
                            av_cat_array.map(av_cat => '"' + av_cat + '"')
                        ),
                    ]) // unique
                    .then(av_categories => {
                        av_cat_array.forEach(av_cat => {
                            let av_match = av_categories.find(
                                element => element.category_name == av_cat
                            );
                            this.av_options[av_cat] =
                                av_match.authorised_values.map(av => ({
                                    value: av.value,
                                    label: av.description,
                                }));
                        });

                        // Iterate on available fields
                        available_fields.forEach(available_field => {
                            // Initialize current field as empty array
                            this.current_additional_fields_values[
                                available_field.extended_attribute_type_id
                            ] = [];

                            // Grab all existing field values of this field
                            let existing_field_values =
                                this.additional_field_values.filter(
                                    afv =>
                                        afv.field_id ==
                                            available_field.extended_attribute_type_id &&
                                        afv.value
                                );

                            // If there are existing field values for this field, add them to current_additional_fields_values
                            if (existing_field_values.length) {
                                existing_field_values.forEach(
                                    existing_field_value => {
                                        let label = "";
                                        if (
                                            available_field.authorised_value_category_name
                                        ) {
                                            let av_value = this.av_options[
                                                available_field
                                                    .authorised_value_category_name
                                            ].filter(
                                                av_option =>
                                                    av_option.value ==
                                                    existing_field_value.value
                                            );
                                            label = av_value.length
                                                ? av_value[0].label
                                                : "";
                                        }
                                        this.current_additional_fields_values[
                                            existing_field_value.field_id
                                        ].push({
                                            value: existing_field_value.value,
                                            label: label,
                                        });
                                    }
                                );

                                // Otherwise add them as empty if not AV field
                            } else {
                                if (
                                    !available_field.authorised_value_category_name
                                ) {
                                    this.current_additional_fields_values[
                                        available_field.extended_attribute_type_id
                                    ] = [
                                        {
                                            label: "",
                                            value: "",
                                        },
                                    ];
                                }
                            }
                        });
                    });
            }
        },
    },
    methods: {
        clearField: function (current_field, event) {
            event.preventDefault();
            current_field.value = "";
        },
        cloneField: function (available_field, current, event) {
            event.preventDefault();
            this.current_additional_fields_values[
                available_field.extended_attribute_type_id
            ].push({
                value: current.value,
                label: available_field.name,
            });
        },
        updateParentAdditionalFieldValues: function (
            current_additional_fields_values
        ) {
            let updatedAdditionalFields = [];
            Object.keys(current_additional_fields_values).forEach(field_id => {
                if (
                    !Array.isArray(
                        current_additional_fields_values[field_id]
                    ) &&
                    current_additional_fields_values[field_id]
                ) {
                    current_additional_fields_values[field_id] = [
                        current_additional_fields_values[field_id],
                    ];
                }
                if (current_additional_fields_values[field_id]) {
                    let new_extended_attributes =
                        current_additional_fields_values[field_id].map(
                            value => ({
                                field_id: field_id,
                                value: value.value,
                            })
                        );
                    updatedAdditionalFields = updatedAdditionalFields.concat(
                        new_extended_attributes
                    );
                }
            });

            this.$emit("additional-fields-changed", updatedAdditionalFields);
        },
    },
    name: "AdditionalFieldsEntry",
    props: {
        resource_type: String,
        additional_field_values: Array,
    },
};
</script>
