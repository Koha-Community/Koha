<template>
    <fieldset class="rows">
        <p>
            <strong>{{ $__("Number of subscriptions") }}: </strong>
            <a
                v-if="isUserPermitted('CAN_user_serials')"
                :href="`/cgi-bin/koha/serials/serials-search.pl?bookseller_filter=${vendor.name}&searched=1`"
                >{{ vendor.subscriptions_count }}</a
            >
            <span v-else>{{ vendor.subscriptions_count }}</span>
        </p>
    </fieldset>
</template>

<script>
import { inject } from "vue";

export default {
    props: {
        vendor: Object,
    },
    setup(props) {
        const vendorStore = inject("vendorStore");

        const { isUserPermitted } = vendorStore;

        return {
            isUserPermitted,
        };
    },
};
</script>

<style></style>
