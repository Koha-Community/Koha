import { defineStore } from "pinia";

export const useERMStore = defineStore("erm", {
    state: () => ({
        sysprefs: {
            ERMModule: false,
        },
        providers: [],
    }),
});
