<template>
    <b-button
        @click="$emit('switch-view', 'add-form')"
        id="new_agreement"
        variant="default"
        ><font-awesome-icon icon="plus" /> New agreement</b-button
    >
</template>

<script>
export default {
    name: "AgreementsToolbar",
    emits: ['switch-view'],
}
</script>
