<template>
    <a class="btn btn-default" @click="$emit('switch-view', 'add-form')"
        ><font-awesome-icon icon="plus" /> New agreement</a
    >
</template>

<script>
export default {
    name: "AgreementsToolbar",
    emits: ['switch-view'],
}
</script>
