<template>
    <div id="toolbar" class="btn-toolbar">
        <router-link
            :to="{ name: 'UsageStatisticsDataProvidersFormAdd' }"
            class="btn btn-default"
            ><font-awesome-icon icon="plus" />
            {{ $__("New data provider") }}</router-link
        >
    </div>
</template>

<script>
export default {
    name: "UsageStatisticsDataProvidersToolbar",
}
</script>
