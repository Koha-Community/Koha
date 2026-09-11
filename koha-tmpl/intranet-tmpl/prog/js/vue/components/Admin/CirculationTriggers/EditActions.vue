<template>
    <fieldset
        class="rows"
        v-if="(ruleSetInitialized && editMode === 'edit') || editMode === 'add'"
        id="trigger-edit-form-general-section"
    >
        <legend v-if="editMode === 'add'">
            {{ $__x("Add new trigger {triggerNumber}", { triggerNumber }) }}
        </legend>
        <legend v-else>
            {{ $__x("Edit trigger {triggerNumber}", { triggerNumber }) }}
        </legend>
        <div class="page-section bg-info">
            <p>
                {{
                    $__(
                        "NOTE: Delay for a given trigger can be pushed forward or backwards only within the bounds of what its two neighbouring triggers allows."
                    )
                }}
            </p>
        </div>
        <ol>
            <li>
                <label for="overdue_delay">{{ $__("Delay") }}: </label>
                <div class="numeric-input-wrapper">
                    <div class="input-with-clear">
                        <input
                            @input="setAllowSubmission"
                            id="overdue_delay"
                            v-model="
                                ruleSetToSubmit[
                                    `overdue_${triggerNumber}_delay`
                                ]
                            "
                            type="number"
                            :placeholder="
                                fallbackRuleSet?.[
                                    `overdue_${triggerNumber}_delay`
                                ]
                            "
                            :min="minDelay"
                            :max="maxDelay"
                            class="numeric-input"
                        />
                        <button
                            v-if="
                                ruleSetToSubmit[
                                    `overdue_${triggerNumber}_delay`
                                ] !== null &&
                                ruleSetToSubmit[
                                    `overdue_${triggerNumber}_delay`
                                ] !== undefined
                            "
                            type="button"
                            class="btn btn-link clear-btn"
                            :title="$__('Undo override and reset to fallback')"
                            @click="handleSetDelayToNull"
                        >
                            <i class="fa-solid fa-xmark"></i>
                        </button>
                        <div class="chevron-buttons">
                            <button
                                type="button"
                                class="increment-btn"
                                @click="incrementDelay"
                            >
                                ▴
                            </button>
                            <button
                                type="button"
                                class="decrement-btn"
                                @click="decrementDelay"
                            >
                                ▾
                            </button>
                        </div>
                    </div>
                </div>
            </li>
            <li>
                <label for="restricts">{{ $__("Restricts checkouts") }}:</label>
                <div>
                    <input
                        @click="setAllowSubmission"
                        type="radio"
                        id="restricts-yes"
                        v-model="
                            ruleSetToSubmit[`overdue_${triggerNumber}_restrict`]
                        "
                        :value="1"
                    />
                    {{ $__("Yes") }}
                    <input
                        @click="setAllowSubmission"
                        type="radio"
                        id="restricts-no"
                        v-model="
                            ruleSetToSubmit[`overdue_${triggerNumber}_restrict`]
                        "
                        :value="0"
                    />
                    {{ $__("No") }}
                    <input
                        @click="setAllowSubmission"
                        type="radio"
                        id="restricts-fallback"
                        v-model="
                            ruleSetToSubmit[`overdue_${triggerNumber}_restrict`]
                        "
                        :value="null"
                    />
                    {{ $__("Fallback to default") }}
                    <span
                        v-if="
                            fallbackRuleSet?.[
                                `overdue_${triggerNumber}_restrict`
                            ] !== null
                        "
                    >
                        ({{
                            fallbackRuleSet?.[
                                `overdue_${triggerNumber}_restrict`
                            ] === "1"
                                ? $__("Yes")
                                : $__("No")
                        }})
                    </span>
                </div>
            </li>
        </ol>
    </fieldset>
    <div v-else-if="editMode === 'add' || editMode === 'edit'">
        <p>{{ $__("Loading current action settings...") }}</p>
    </div>
</template>

<script>
export default {
    props: {
        ruleSetInitialized: { type: Boolean, required: true },
        editMode: { type: [String, Boolean], required: true },
        triggerNumber: { type: Number, required: true },
        ruleSetToSubmit: { type: Object, default: null },
        fallbackRuleSet: { type: Object, default: null },
        minDelay: { type: Number, required: true },
        maxDelay: { type: Number, required: true },
        setAllowSubmission: { type: Function, required: true },
        handleSetDelayToNull: { type: Function, required: true },
        incrementDelay: { type: Function, required: true },
        decrementDelay: { type: Function, required: true },
    },
};
</script>

<style scoped>
li {
    display: flex;
    align-items: center;
}

.numeric-input-wrapper {
    position: relative;
    display: inline-block;
    width: 30%;
}

.input-with-clear {
    position: relative;
    display: flex;
    align-items: center;
    width: 100%;
}

.numeric-input {
    padding-right: 40px;
    padding-left: 0.25em;
    padding-top: 2px;
    padding-bottom: 2px;
    width: 100%;
    border-radius: 4px;
    border: 1px solid #ccc;
    font-size: 16px;
    box-sizing: border-box;
    transition: border-color 0.2s ease;
}

/* overlays the input, clear of the chevrons; appearance comes from btn-link,
   matching the equivalent button in EditNotice.vue */
.clear-btn {
    position: absolute;
    right: 22px;
    z-index: 2;
    padding: 0;
    color: #333;
}

.chevron-buttons {
    display: flex;
    flex-direction: column;
    position: absolute;
    right: 0px;
    top: 0;
    bottom: 0;
    width: 16px;
    padding: 0px 5px 0px 2px;
    justify-content: center;
    z-index: 2;
}

.increment-btn,
.decrement-btn {
    background-color: transparent;
    border: 0px solid #ccc;
    font-size: 10px;
    padding: 0px;
    cursor: pointer;
    color: rgba(60, 60, 60, 0.5);
    border-radius: 2px;
}

.increment-btn:hover,
.decrement-btn:hover {
    background-color: #ddd;
}

input[type="number"]::-webkit-inner-spin-button,
input[type="number"]::-webkit-outer-spin-button {
    -webkit-appearance: none;
    margin: 0;
}

input[type="number"] {
    -moz-appearance: textfield;
}

.numeric-input:focus,
.numeric-input:hover {
    border-color: #007bff;
    outline: none;
}
</style>
