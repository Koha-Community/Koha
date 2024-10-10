import { defineStore } from "pinia";

export const useSIP2Store = defineStore("sip2", {
    state: () => ({
        config: {
            displayRestartSIPDialog: true,
        },
    }),
});
