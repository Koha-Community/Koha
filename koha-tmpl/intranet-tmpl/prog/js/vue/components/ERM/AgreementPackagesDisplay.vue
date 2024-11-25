<template>
    <label>{{ $__("Packages") }}</label>
    <div id="agreement_packages">
        <div
            v-for="agreement_package in agreement.agreement_packages"
            v-bind:key="agreement_package.package_id"
        >
            <span
                v-if="
                    agreement_package.package.external_id &&
                    agreement_package.package.provider == 'ebsco'
                "
            >
                <router-link
                    :to="{
                        name: 'EHoldingsEBSCOPackagesShow',
                        params: {
                            package_id: agreement_package.package.external_id,
                        },
                    }"
                    >{{ agreement_package.package.name }}</router-link
                >
                {{ $__("(EBSCO)") }}</span
            >
            <span v-else
                ><router-link
                    :to="{
                        name: 'EHoldingsLocalPackagesShow',
                        params: {
                            package_id: agreement_package.package.package_id,
                        },
                    }"
                    >{{ agreement_package.package.name }}</router-link
                >
                ({{ $__("local") }})</span
            >
        </div>
    </div>
</template>

<script>
export default {
    props: {
        agreement: Object,
    },
};
</script>

<style></style>
