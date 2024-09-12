<template>
    <h2>Hello from Islands!</h2>
    <p>This component is rendered as an island in a static HTML page.</p>

    <!-- Display message prop -->
    <p v-if="message">{{ message }}</p>

    <!-- Reactive counter example -->
    <p>Counter: {{ count }}</p>
    <!-- Koha's bootstrap works in here! -->
    <button @click="incrementCounter" class="btn btn-primary">
        Increment Counter
    </button>
</template>

<script>
import { ref } from "vue";

export default {
    props: {
        message: {
            type: String,
            default: "",
        },
    },
    data() {
        return {
            count: 0,
        };
    },
    methods: {
        incrementCounter() {
            this.count++;
        },
    },
};
</script>
