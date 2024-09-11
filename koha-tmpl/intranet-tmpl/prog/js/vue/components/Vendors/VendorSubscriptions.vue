<template>
    <fieldset class="rows">
        <h2>
            {{ $__("Subscription details") }}
        </h2>
        <!-- PERMISSION -->
        <p>
            <strong>{{ $__("Number of subscriptions") }}: </strong>
            <a
                v-if="false"
                :href="`/cgi-bin/koha/serials/serials-search.pl?bookseller_filter=${vendor.name}&searched=1`"
                >{{ vendor.subscriptions.length }}</a
            >
            <span v-if="true">{{ vendor.subscriptions.length }}</span>
        </p>
    </fieldset>
</template>

<script>
export default {
    props: {
        vendor: Object,
    },
};
</script>

<style></style>
