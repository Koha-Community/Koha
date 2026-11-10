<template>
    <div
        v-if="visible"
        class="modal modal-lg show d-block"
        tabindex="-1"
        role="dialog"
        aria-modal="true"
        aria-labelledby="checkin-resolve-claim-title"
    >
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h1 id="checkin-resolve-claim-title" class="modal-title">
                        {{ $__("Resolve return claim") }}
                    </h1>
                </div>
                <div class="modal-body">
                    <div v-if="error" class="alert alert-danger" role="alert">
                        {{ error }}
                    </div>
                    <div class="mb-3">
                        <label for="claim-resolution" class="form-label">
                            {{ $__("Resolution:") }}
                        </label>
                        <select
                            id="claim-resolution"
                            v-model="resolution"
                            class="form-select"
                        >
                            <option value="">
                                {{ $__("Select a resolution") }}
                            </option>
                            <option
                                v-for="r in resolutions"
                                :key="r.value"
                                :value="r.value"
                            >
                                {{ r.description }}
                            </option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label for="claim-lost-status" class="form-label">
                            {{ $__("New lost status (optional):") }}
                        </label>
                        <select
                            id="claim-lost-status"
                            v-model="newLostStatus"
                            class="form-select"
                        >
                            <option value="">{{ $__("No change") }}</option>
                            <option
                                v-for="s in lostStatuses"
                                :key="s.value"
                                :value="s.value"
                            >
                                {{ s.description }}
                            </option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button
                        type="button"
                        class="btn btn-primary"
                        :disabled="!resolution || resolving"
                        @click="resolve"
                    >
                        <i class="fa fa-check"></i>
                        {{ $__("Resolve claim") }}
                    </button>
                    <button
                        type="button"
                        class="btn btn-default"
                        :disabled="resolving"
                        @click="$emit('close')"
                    >
                        {{ $__("Cancel") }}
                    </button>
                </div>
            </div>
        </div>
    </div>
    <div v-if="visible" class="modal-backdrop show"></div>
</template>

<script>
import { onMounted, ref, watch } from "vue";
import { APIClient } from "../../../fetch/api-client.js";
import { $__ } from "@koha-vue/i18n";

export default {
    props: {
        claimId: {
            type: Number,
            default: null,
        },
        visible: {
            type: Boolean,
            default: false,
        },
    },
    emits: ["resolved", "close"],
    setup(props, { emit }) {
        const resolution = ref("");
        const newLostStatus = ref("");
        const resolutions = ref([]);
        const lostStatuses = ref([]);
        const resolving = ref(false);
        const error = ref(null);

        // Do not keep the error of a previous attempt when reopening
        watch(
            () => props.visible,
            visible => {
                if (visible) error.value = null;
            }
        );

        onMounted(() => {
            // Fetch RETURN_CLAIM_RESOLUTION authorised values
            APIClient.authorised_values.values
                .get("RETURN_CLAIM_RESOLUTION")
                .then(values => {
                    resolutions.value = values || [];
                })
                .catch(() => {});

            // Fetch LOST authorised values
            APIClient.authorised_values.values
                .get("LOST")
                .then(values => {
                    lostStatuses.value = values || [];
                })
                .catch(() => {});
        });

        async function resolve() {
            if (!props.claimId || !resolution.value) return;
            resolving.value = true;
            error.value = null;
            try {
                await APIClient.claim.return_claims.resolve(props.claimId, {
                    resolution: resolution.value,
                    new_lost_status: newLostStatus.value,
                });
                emit("resolved", props.claimId);
            } catch (e) {
                error.value = $__(
                    "Unable to resolve the return claim: %s"
                ).replace("%s", e.message.replace(/^Error: /, ""));
            } finally {
                resolving.value = false;
            }
        }

        return {
            resolution,
            newLostStatus,
            resolutions,
            lostStatuses,
            resolving,
            error,
            resolve,
        };
    },
};
</script>
