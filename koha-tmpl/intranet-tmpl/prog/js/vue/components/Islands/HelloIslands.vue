<template>
    <h2 :style="{ color }">Hello from Islands!</h2>
    <p>This component is rendered as an island in a static HTML page.</p>

    <!-- Display message prop -->
    <p v-if="message">{{ message }}</p>

    <!-- Display store data -->
    <p v-if="stringFromStore">{{ stringFromStore }}</p>
    <p v-if="anotherStoreString">{{ anotherStoreString }}</p>

    <!-- Reactive counter example -->
    <p>Counter: {{ count }}</p>
    <!-- Koha's bootstrap works in here! -->
    <button @click="incrementCounter" class="btn btn-primary">
        Increment Counter
    </button>
</template>

<script>
import { ref } from "vue";
import { inject } from "vue";

export default {
    props: {
        message: {
            type: String,
            default: "No content",
        },
        color: {
            type: String,
            default: "crimson",
        },
    },
    setup() {
        const mainStore = inject("mainStore");
        const { stringFromStore } = mainStore;
        const navigationStore = inject("navigationStore");
        const { anotherStoreString } = navigationStore;
        return {
            stringFromStore,
            anotherStoreString,
        };
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
