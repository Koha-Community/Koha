<template>
    <transition name="modal">
        <div v-if="showModal" class="add_agreement_modal">
            <AgreementsList :embedded="true" @select-agreement="addAgreement" />
            <input
                type="button"
                @click="showModal = false"
                :value="$__('Close')"
            />
        </div>
    </transition>
    <div id="package_agreements">
        <div
            v-for="(
                package_agreement, counter
            ) in erm_package.package_agreements"
            v-bind:key="counter"
        >
            <router-link
                :to="`/cgi-bin/koha/erm/agreements/${package_agreement.agreement.agreement_id}`"
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
        <a class="btn btn-default btn-xs" @click="showModal = true"
            ><font-awesome-icon icon="plus" /> {{ $__("Add new agreement") }}</a
        >
    </div>
</template>

<script>
import AgreementsList from "./AgreementsList.vue"
import { APIClient } from "../../fetch/api-client.js"
import { setWarning, removeMessages } from "../../messages"

export default {
    data() {
        return { showModal: false }
    },
    beforeCreate() {},
    methods: {
        serializeAgreement() {
            let erm_package = JSON.parse(JSON.stringify(this.erm_package)) // copy
            delete erm_package.vendor_id // This is the EBSCO's vendor_id

            // Remove remote data, we don't need to store them (don't we?)
            // Keep the name, it's mandatory by the REST API specs
            delete erm_package.package_type
            delete erm_package.content_type
            erm_package.external_id = erm_package.package_id
            delete erm_package.package_id
            erm_package.provider = "ebsco"
            erm_package.package_id = erm_package.koha_internal_id
            delete erm_package.koha_internal_id
            delete erm_package.resources
            delete erm_package.vendor
            delete erm_package.resources_count
            delete erm_package.is_selected
            erm_package.package_agreements = erm_package.package_agreements.map(
                ({ package_id, agreement, ...keepAttrs }) => keepAttrs
            )
            return erm_package
        },
        addAgreement(agreement_id) {
            removeMessages()
            this.showModal = false
            let erm_package = this.serializeAgreement()
            // Only add if it does not exist
            if (
                !erm_package.package_agreements.find(
                    a => a.agreement_id == agreement_id
                )
            ) {
                erm_package.package_agreements.push({ agreement_id })
                const client = APIClient.erm

                if (this.erm_package.koha_internal_id) {
                    let package_id = erm_package.package_id
                    delete erm_package.package_id
                    client.localPackages.update(erm_package, package_id).then(
                        success => {
                            this.$emit("refresh-agreements")
                        },
                        error => {}
                    )
                } else {
                    client.localPackages.create(erm_package).then(
                        success => {
                            this.$emit("refresh-agreements")
                        },
                        error => {}
                    )
                }
            } else {
                setWarning(
                    this.$__(
                        "This agreement is already linked with this package"
                    )
                )
            }
        },
        deleteAgreement(counter) {
            let erm_package = this.serializeAgreement()
            erm_package.package_agreements.splice(counter, 1)
            let package_id = erm_package.package_id
            delete erm_package.package_id
            const client = APIClient.erm
            client.localPackages.update(erm_package, package_id).then(
                success => {
                    this.$emit("refresh-agreements")
                },
                error => {}
            )
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
}
</script>
<style>
.add_agreement_modal {
    position: fixed;
    z-index: 9998;
    top: 0;
    left: 0;
    width: 80%;
    height: 80%;
    background-color: rgba(0, 0, 0, 0.5);
    display: table;
    transition: opacity 0.3s ease;
    margin: auto;
    padding: 20px 30px;
    background-color: #fff;
    border-radius: 2px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.33);
    transition: all 0.3s ease;
    font-family: Helvetica, Arial, sans-serif;
}
</style>

<style>
.add_agreement_modal #agreements_list table {
    display: table;
}
.add_agreement_modal .filters label {
    float: none !important;
}
.add_agreement_modal .filters input[type="checkbox"] {
    margin-left: 0 !important;
}
</style>
