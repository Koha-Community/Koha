<template>
    <div id="toolbar" class="btn-toolbar">
        <router-link :to="{ name: 'AgreementsFormAdd' }" class="btn btn-default"
            ><font-awesome-icon icon="plus" />
            {{ $__("New agreement") }}</router-link
        >
    </div>
</template>

<script>
export default {
    name: "AgreementsToolbar",
}
</script>
