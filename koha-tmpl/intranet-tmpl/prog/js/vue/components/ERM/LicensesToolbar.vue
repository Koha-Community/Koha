<template>
    <a class="btn btn-default" @click="$emit('switch-view', 'add-form')"
        ><font-awesome-icon icon="plus" /> New license</a
    >
</template>

<script>
export default {
    name: "LicensesToolbar",
    emits: ['switch-view'],
}
</script>
