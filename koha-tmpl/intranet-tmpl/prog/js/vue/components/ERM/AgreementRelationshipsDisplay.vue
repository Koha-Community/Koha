<template>
    <label>{{ $__("Related agreements") }}</label>
    <div id="agreement_relationships">
        <div
            v-for="relationship in agreement.agreement_relationships"
            v-bind:key="relationship.related_agreement_id"
        >
            <span
                ><router-link
                    :to="{
                        name: 'AgreementsShow',
                        params: {
                            agreement_id:
                                relationship.related_agreement.agreement_id,
                        },
                    }"
                    >{{ relationship.related_agreement.name }}</router-link
                ></span
            >
            {{
                get_lib_from_av(
                    "av_agreement_relationships",
                    relationship.relationship
                )
            }}
            {{ agreement.name }}
        </div>
    </div>
</template>

<script>
import { inject } from "vue";

export default {
    props: {
        agreement: Object,
    },
    setup() {
        const AVStore = inject("AVStore");
        const { get_lib_from_av } = AVStore;

        return {
            get_lib_from_av,
        };
    },
};
</script>

<style></style>
