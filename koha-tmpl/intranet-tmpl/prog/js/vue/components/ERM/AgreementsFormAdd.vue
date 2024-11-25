<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="agreements_add">
        <h2 v-if="agreement.agreement_id">
            {{ $__("Edit agreement #%s").format(agreement.agreement_id) }}
        </h2>
        <h2 v-else>{{ $__("New agreement") }}</h2>
        <div>
            <form @submit="onSubmit($event)">
                <fieldset class="rows">
                    <ol>
                        <li
                            v-for="(attr, index) in resource_attrs.filter(
                                attr => attr.type !== 'relationship'
                            )"
                            v-bind:key="index"
                        >
                            <FormElement
                                :resource="agreement"
                                :attr="attr"
                                :index="index"
                            />
                        </li>
                    </ol>
                </fieldset>
                <AdditionalFieldsEntry
                    resource_type="agreement"
                    :additional_field_values="agreement.extended_attributes"
                    @additional-fields-changed="additionalFieldsChanged"
                />
                <template
                    v-for="(attr, index) in resource_attrs.filter(
                        attr => attr.type === 'relationship'
                    )"
                    v-bind:key="'rel-' + index"
                >
                    <FormElement :resource="agreement" :attr="attr" />
                </template>
                <fieldset class="action">
                    <ButtonSubmit />
                    <router-link
                        :to="{ name: 'AgreementsList' }"
                        role="button"
                        class="cancel"
                        >{{ $__("Cancel") }}</router-link
                    >
                </fieldset>
            </form>
        </div>
    </div>
</template>

<script>
import FormElement from "../FormElement.vue";
import AdditionalFieldsEntry from "../AdditionalFieldsEntry.vue";
import ButtonSubmit from "../ButtonSubmit.vue";
import { setMessage, setError, setWarning } from "../../messages";
import { APIClient } from "../../fetch/api-client.js";
import AgreementResource from "./AgreementResource.vue";

export default {
    extends: AgreementResource,
    setup() {

        return {
            ...AgreementResource.setup(),
        };
    },
    data() {
        return {
            ...AgreementResource.data(),
            agreement: {
                agreement_id: null,
                name: "",
                vendor_id: null,
                description: "",
                status: "",
                closure_reason: "",
                is_perpetual: false,
                renewal_priority: "",
                license_info: "",
                periods: [],
                user_roles: [],
                agreement_licenses: [],
                agreement_relationships: [],
                documents: [],
                extended_attributes: [],
            },
            initialized: false,
        };
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            if (to.params.agreement_id) {
                vm.getAgreement(to.params.agreement_id);
            } else {
                vm.initialized = true;
            }
        });
    },
    watch: {
        "agreement.status": function (newVal, oldVal) {
            var index = this.resource_attrs.findIndex(function (attr) {
                return attr.name === "closure_reason";
            });

            if (newVal != "closed") {
                this.agreement.closure_reason = "";
                this.resource_attrs[index].disabled = true;
            } else {
                this.resource_attrs[index].disabled = false;
            }
        },
    },
    methods: {
        async getAgreement(agreement_id) {
            const client = APIClient.erm;
            client.agreements.get(agreement_id).then(
                data => {
                    this.agreement = data;
                    this.initialized = true;
                },
                error => {}
            );
        },
        checkForm(agreement) {
            let errors = [];

            let agreement_licenses = agreement.agreement_licenses;
            // Do not use al.license.name here! Its name is not the one linked with al.license_id
            // At this point al.license is meaningless, form/template only modified al.license_id
            const license_ids = agreement_licenses.map(al => al.license_id);
            const duplicate_license_ids = license_ids.filter(
                (id, i) => license_ids.indexOf(id) !== i
            );

            if (duplicate_license_ids.length) {
                errors.push(this.$__("A license is used several times"));
            }

            const related_agreement_ids = agreement.agreement_relationships.map(
                rs => rs.related_agreement_id
            );
            const duplicate_related_agreement_ids =
                related_agreement_ids.filter(
                    (id, i) => related_agreement_ids.indexOf(id) !== i
                );

            if (duplicate_related_agreement_ids.length) {
                errors.push(
                    this.$__(
                        "An agreement is used as relationship several times"
                    )
                );
            }

            if (
                agreement_licenses.filter(al => al.status == "controlling")
                    .length > 1
            ) {
                errors.push(
                    this.$__("Only one controlling license is allowed")
                );
            }

            let documents_with_uploaded_files = agreement.documents.filter(
                doc => typeof doc.file_content !== "undefined"
            );
            if (
                documents_with_uploaded_files.filter(
                    doc => atob(doc.file_content).length >= max_allowed_packet
                ).length >= 1
            ) {
                errors.push(
                    this.$__("File size exceeds maximum allowed: %s MB").format(
                        (max_allowed_packet / (1024 * 1024)).toFixed(2)
                    )
                );
            }
            agreement.user_roles.forEach((user, i) => {
                if (user.patron_str === "") {
                    errors.push(
                        this.$__("Agreement user %s is missing a user").format(
                            i + 1
                        )
                    );
                }
            });
            setWarning(errors.join("<br>"));
            return !errors.length;
        },
        onSubmit(e) {
            e.preventDefault();

            //let agreement= Object.assign( {} ,this.agreement); // copy
            let agreement = JSON.parse(JSON.stringify(this.agreement)); // copy
            let agreement_id = agreement.agreement_id;

            if (!this.checkForm(agreement)) {
                return false;
            }

            delete agreement.agreement_id;
            delete agreement.vendor;
            delete agreement._strings;
            agreement.is_perpetual = agreement.is_perpetual ? true : false;

            if (agreement.vendor_id == "") {
                agreement.vendor_id = null;
            }

            agreement.periods = agreement.periods.map(
                ({ agreement_id, agreement_period_id, ...keepAttrs }) =>
                    keepAttrs
            );

            agreement.user_roles = agreement.user_roles.map(
                ({ patron, patron_str, ...keepAttrs }) => keepAttrs
            );

            agreement.agreement_licenses = agreement.agreement_licenses.map(
                ({
                    license,
                    agreement_id,
                    agreement_license_id,
                    ...keepAttrs
                }) => keepAttrs
            );

            agreement.agreement_relationships =
                agreement.agreement_relationships.map(
                    ({ related_agreement, ...keepAttrs }) => keepAttrs
                );

            agreement.documents = agreement.documents.map(
                ({ file_type, uploaded_on, ...keepAttrs }) => keepAttrs
            );

            delete agreement.agreement_packages;

            const client = APIClient.erm;
            if (agreement_id) {
                client.agreements.update(agreement, agreement_id).then(
                    success => {
                        setMessage(this.$__("Agreement updated"));
                        this.$router.push({ name: "AgreementsList" });
                    },
                    error => {}
                );
            } else {
                client.agreements.create(agreement).then(
                    success => {
                        setMessage(this.$__("Agreement created"));
                        this.$router.push({ name: "AgreementsList" });
                    },
                    error => {}
                );
            }
        },
        additionalFieldsChanged(additionalFieldValues) {
            this.agreement.extended_attributes = additionalFieldValues;
        },
    },
    components: {
        ButtonSubmit,
        FormElement,
        AdditionalFieldsEntry,
    },
    name: "AgreementsFormAdd",
};
</script>
