<template>
    <div class="dialog message" v-if="message" v-html="message"></div>
    <div class="dialog alert" v-if="error" v-html="error"></div>
    <div class="dialog alert modal" v-if="warning">
        <h1 v-html="warning"></h1>
        <button id="close_modal" class="approve" @click="removeMessages">
            <i class="fa fa-fw fa-check"></i>
            {{ $__("Close") }}
        </button>
    </div>
    <div class="modal_centered" v-if="confirmation">
        <div class="dialog alert confirmation">
            <h1 v-html="confirmation"></h1>
            <button
                v-if="accept_callback"
                id="accept_modal"
                class="approve"
                @click="accept_callback"
            >
                <i class="fa fa-fw fa-check"></i>
                {{ $__("Accept") }}
            </button>
            <button id="close_modal" class="deny" @click="removeMessages">
                <i class="fa fa-fw fa-remove"></i>
                {{ $__("Close") }}
            </button>
        </div>
    </div>
    <!-- Must be styled differently -->

    <div class="modal_centered" v-if="is_submitting">
        <div class="spinner dialog alert">{{ $__("Submitting...") }}</div>
    </div>
    <div class="modal_centered" v-if="is_loading">
        <div class="spinner dialog message">{{ $__("Loading...") }}</div>
    </div>
</template>

<script>
import { inject } from "vue"
import { storeToRefs } from "pinia"
export default {
    setup() {
        const mainStore = inject("mainStore")
        const {
            message,
            error,
            warning,
            confirmation,
            accept_callback,
            is_submitting,
            is_loading,
        } = storeToRefs(mainStore)
        const { removeMessages } = mainStore
        return {
            message,
            error,
            warning,
            confirmation,
            accept_callback,
            is_submitting,
            is_loading,
            removeMessages,
        }
    },
}
</script>

<style scoped>
.modal {
    position: fixed;
    z-index: 9998;
    display: table;
    transition: opacity 0.3s ease;
    margin: auto;
    padding: 20px 30px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.33);
    transition: all 0.3s ease;
}
#close_modal {
    cursor: pointer;
}

.modal_centered {
    position: fixed;
    z-index: 9998;
    display: table;
    transition: opacity 0.3s ease;
    left: 0px;
    top: 0px;
    width: 100%;
    height: 100%;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.33);
}
.spinner {
    position: absolute;
    top: 50%;
    left: 40%;
    width: 10%;
}

.confirmation {
    position: absolute;
    top: 25%;
    left: 40%;

    width: 50%;
    min-height: 10%;
    margin: auto;
    align-items: center;
    justify-content: center;
}
</style>
