<template>
    <div
        id="add_agreement"
        class="modal"
        role="dialog"
        aria-labelledby="add_agreement_label"
        aria-hidden="true"
    >
        <div class="modal-dialog modal-xl">
            <div class="modal-content modal-xl">
                <div class="modal-header">
                    <h1 class="modal-title" id="add_agreement_label">
                        {{ $__("Add agreement") }}
                    </h1>
                    <button
                        type="button"
                        class="btn-close"
                        data-bs-dismiss="modal"
                        aria-label="Close"
                    ></button>
                </div>
                <div class="modal-body position-relative overflow-visible">
                    <AgreementsList
                        :embedded="true"
                        @select-agreement="addAgreement"
                    />
                </div>
                <div class="modal-footer">
                    <button
                        class="btn btn-default deny cancel"
                        type="button"
                        data-bs-dismiss="modal"
                    >
                        {{ $__("Close") }}
                    </button>
                </div>
            </div>
        </div>
    </div>
    <div id="package_agreements">
        <div
            v-for="(
                package_agreement, counter
            ) in erm_package.package_agreements"
            v-bind:key="counter"
        >
            <router-link
                :to="{
                    name: 'AgreementsShow',
                    params: {
                        agreement_id: package_agreement.agreement.agreement_id,
                    },
                }"
                >{{ package_agreement.agreement.name }}</router-link
            >
            &nbsp;
            <a
                href="#"
                @click.prevent="deleteAgreement(counter)"
                :title="$__('Remove this agreement')"
                ><i class="fa fa-trash"></i
            ></a>
        </div>
        <a class="btn btn-default btn-xs" @click="showAddAgreementModal()"
            ><font-awesome-icon icon="plus" /> {{ $__("Add new agreement") }}</a
        >
    </div>
</template>

<script>
import AgreementsList from "./AgreementsList.vue";
import { APIClient } from "../../fetch/api-client.js";
import { setWarning, removeMessages } from "../../messages";

export default {
    data() {},
    beforeCreate() {},
    methods: {
        serializeAgreement() {
            let erm_package = JSON.parse(JSON.stringify(this.erm_package)); // copy
            delete erm_package.vendor_id; // This is the EBSCO's vendor_id

            // Remove remote data, we don't need to store them (don't we?)
            // Keep the name, it's mandatory by the REST API specs
            delete erm_package.package_type;
            delete erm_package.content_type;
            erm_package.external_id = erm_package.package_id;
            delete erm_package.package_id;
            erm_package.provider = "ebsco";
            erm_package.package_id = erm_package.koha_internal_id;
            delete erm_package.koha_internal_id;
            delete erm_package.resources;
            delete erm_package.vendor;
            delete erm_package.resources_count;
            delete erm_package.is_selected;
            erm_package.package_agreements = erm_package.package_agreements.map(
                ({ package_id, agreement, ...keepAttrs }) => keepAttrs
            );
            return erm_package;
        },
        showAddAgreementModal() {
            $("#add_agreement").modal("show");
        },
        addAgreement(agreement_id) {
            removeMessages();
            $("#add_agreement").modal("hide");
            let erm_package = this.serializeAgreement();
            // Only add if it does not exist
            if (
                !erm_package.package_agreements.find(
                    a => a.agreement_id == agreement_id
                )
            ) {
                erm_package.package_agreements.push({ agreement_id });
                const client = APIClient.erm;

                if (this.erm_package.koha_internal_id) {
                    let package_id = erm_package.package_id;
                    delete erm_package.package_id;
                    client.localPackages.update(erm_package, package_id).then(
                        success => {
                            this.$emit("refresh-agreements");
                        },
                        error => {}
                    );
                } else {
                    client.localPackages.create(erm_package).then(
                        success => {
                            this.$emit("refresh-agreements");
                        },
                        error => {}
                    );
                }
            } else {
                setWarning(
                    this.$__(
                        "This agreement is already linked with this package"
                    )
                );
            }
        },
        deleteAgreement(counter) {
            let erm_package = this.serializeAgreement();
            erm_package.package_agreements.splice(counter, 1);
            let package_id = erm_package.package_id;
            delete erm_package.package_id;
            const client = APIClient.erm;
            client.localPackages.update(erm_package, package_id).then(
                success => {
                    this.$emit("refresh-agreements");
                },
                error => {}
            );
        },
    },
    props: {
        erm_package: Object,
    },
    components: {
        AgreementsList,
    },
    emits: ["refresh-agreements"],
    name: "EHoldingsEBSCOPackageAgreements",
};
</script>
<style>
#add_agreement #agreements_list table {
    display: table;
}
#add_agreement .filters label {
    float: none !important;
}
#add_agreement .filters input[type="checkbox"] {
    margin-left: 0 !important;
}
</style>
