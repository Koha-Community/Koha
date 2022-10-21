<template>
    <div id="toolbar" class="btn-toolbar">
        <router-link
            to="/cgi-bin/koha/erm/agreements/add"
            class="btn btn-default"
            ><font-awesome-icon icon="plus" />
            {{ $t("New agreement") }}</router-link
        >
    </div>
</template>

<script>
export default {
    name: "AgreementsToolbar",
}
</script>
