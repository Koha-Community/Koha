<template>
    <CirculationTriggersForm
        :submitAction="resetCircRules"
        :formTitle="$__('Confirm circulation rule set reset')"
        :buttonText="$__('Confirm reset')"
        :disabled="resetWouldLeaveRuleSetWithoutDelay"
    >
        <TriggersTable
            v-if="initialized"
            :ruleSets="[effectiveRuleSet]"
            :triggerNumber="triggerNumber"
            :modal="false"
            :displayActions="false"
            :enableActions="false"
            :title="$__('Rule set selected for reset')"
        />

        <fieldset class="rows" v-if="alertMessage">
            <div class="alert alert-warning">{{ alertMessage }}</div>
        </fieldset>
        <fieldset
            v-if="initialized && dependentRuleSets.length > 0"
            class="rows"
        >
            <div class="page-section bg-warning overflow-hidden">
                <TriggersTable
                    :ruleSets="projectedDependentEffectiveRuleSets"
                    :triggerNumber="triggerNumber"
                    :modal="false"
                    :displayActions="false"
                    :enableActions="false"
                    :title="
                        $__('Affected rule sets preview: state after reset')
                    "
                />
            </div>
        </fieldset>
    </CirculationTriggersForm>
</template>

<script>
import ButtonSubmit from "../../ButtonSubmit.vue";
import CirculationTriggersForm from "./CirculationTriggersForm.vue";
import TriggersTable from "./TriggersTable.vue";
import { inject } from "vue";
import { storeToRefs } from "pinia";

export default {
    setup() {
        const circRulesStore = inject("circRulesStore");
        const {
            handleContext,
            handleNotice,
            handleTransport,
            getSelectedRuleSet,
            formatTriggerSpecificRuleSetForDisplay,
            deleteRuleSet,
            handleRestrictions,
            computeDeletionImpact,
            setAllFormattedRuleSets,
        } = circRulesStore;
        const {
            libraries,
            itemTypes,
            patronCategories,
            lastEditedTriggerNumber,
        } = storeToRefs(circRulesStore);
        return {
            libraries,
            itemTypes,
            patronCategories,
            lastEditedTriggerNumber,
            handleContext,
            handleNotice,
            handleTransport,
            getSelectedRuleSet,
            formatTriggerSpecificRuleSetForDisplay,
            deleteRuleSet,
            handleRestrictions,
            computeDeletionImpact,
            setAllFormattedRuleSets,
        };
    },
    data() {
        return {
            alertMessage: null,
            initialized: false,
            library_id: "*",
            item_type_id: "*",
            patron_category_id: "*",
            triggerNumber: null,
            ruleSet: null,
            currentRuleSet: null,
            fallbackRuleSet: null,
            effectiveRuleSet: null,
            dependentRuleSets: [],
            projectedDependentEffectiveRuleSets: [],
        };
    },
    beforeRouteEnter(to, from, next) {
        next(async vm => {
            vm.setContext(to.query);
            await vm.loadModalData();
        });
    },
    computed: {
        // a trigger with no delay is never processed, so a reset that would
        // leave an inheriting set without one is not allowed
        resetWouldLeaveRuleSetWithoutDelay() {
            const delayName = `overdue_${this.triggerNumber}_delay`;
            return this.projectedDependentEffectiveRuleSets.some(
                ruleSet =>
                    ruleSet[delayName]?.value === "" ||
                    ruleSet[delayName]?.value == null
            );
        },
    },
    methods: {
        async loadModalData() {
            await this.setAllFormattedRuleSets();

            this.currentRuleSet = await this.getSelectedRuleSet(
                {
                    library_id: this.library_id,
                    patron_category_id: this.patron_category_id,
                    item_type_id: this.item_type_id,
                },
                false
            );
            this.effectiveRuleSet = this.formatTriggerSpecificRuleSetForDisplay(
                this.currentRuleSet.context,
                this.triggerNumber
            );

            const { dependentRuleSets, projectedDependentEffectiveRuleSets } =
                await this.computeDeletionImpact(
                    [this.currentRuleSet],
                    this.triggerNumber
                );
            this.dependentRuleSets = dependentRuleSets;
            this.projectedDependentEffectiveRuleSets =
                projectedDependentEffectiveRuleSets;

            if (this.dependentRuleSets.length > 0) {
                this.alertMessage = this.$__(
                    "Some sets inherit one or more fields from this rule set. After the reset, those fields will fall through to a less specific rule set or be left empty. See the preview below."
                );
            }

            if (this.resetWouldLeaveRuleSetWithoutDelay) {
                this.alertMessage = this.$__(
                    "This rule set cannot be reset. One or more sets that inherit from it would be left without a delay, which stops that trigger and every higher numbered trigger from being processed. See the preview below."
                );
            }

            this.initialized = true;
        },
        async resetCircRules(e) {
            e.preventDefault();
            try {
                await this.deleteRuleSet(
                    this.currentRuleSet,
                    this.triggerNumber
                );
            } catch (e) {
                this.alertMessage = e;
                await this.loadModalData();
                return;
            }
            this.lastEditedTriggerNumber = this.triggerNumber;
            await this.$router.push({
                name: "CirculationTriggersList",
                query: { refresh: Date.now() },
            });
        },
        setContext(query) {
            this.library_id = query.library_id ?? "*";
            this.item_type_id = query.item_type_id ?? "*";
            this.patron_category_id = query.patron_category_id ?? "*";
            this.triggerNumber = parseInt(query.triggerNumber);
        },
    },
    components: { ButtonSubmit, CirculationTriggersForm, TriggersTable },
};
</script>

<style scoped>
#circulation-trigger-form-confirm-reset {
    max-height: 90vh;
}

form ol li {
    display: flex;
    align-items: center;
}

.page-section ul li {
    float: none;
}

.dialog.alert
    fieldset:not(.bg-danger):not(.bg-warning):not(.bg-info):not(
        .bg-success
    ):not(.bg-primary):not(.action),
.dialog.error
    fieldset:not(.bg-danger):not(.bg-warning):not(.bg-info):not(
        .bg-success
    ):not(.bg-primary):not(.action) {
    margin: 0;
    background-color: rgba(255, 255, 255, 1);
}

.router-link-active {
    margin-left: 10px;
}
.modal-header {
    display: flex;
    justify-content: space-between;
}
</style>
