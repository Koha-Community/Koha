<template>
    <h1>{{ testString }}</h1>
    <h2>{{ resourceProp }}</h2>
</template>

<script>
export default {
    props: {
        testString: String,
        resourceProp: String,
    },
};
</script>

<style></style>
