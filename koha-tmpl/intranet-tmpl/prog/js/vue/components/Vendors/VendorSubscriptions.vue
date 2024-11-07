<template>
    <fieldset class="rows">
        <h2>
            {{ $__("Subscription details") }}
        </h2>
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
    setup() {
        const permissionsStore = inject("permissionsStore");

        const { isUserPermitted } = permissionsStore;

        return {
            isUserPermitted,
        };
    },
};
</script>

<style></style>
