import { defineStore } from "pinia";

export const useERMStore = defineStore("erm", {
    state: () => ({
        config: {
            settings: {
                ERMModule: false,
                ERMProviders: [],
            },
        },
    }),
});
