import { createApp } from "vue";
import { createPinia } from "pinia";

import App from "../components/Circ/Checkin/Main.vue";

import "../../../css/vue.css";

import { useMainStore } from "../stores/main";
import i18n from "@koha-vue/i18n";

const pinia = createPinia();

const mainStore = useMainStore(pinia);

const app = createApp(App);

app.use(i18n).use(pinia);

app.provide("mainStore", mainStore);

app.mount("#checkin");
