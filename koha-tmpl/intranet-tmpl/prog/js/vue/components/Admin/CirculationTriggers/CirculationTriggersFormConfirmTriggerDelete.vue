<template>
    <CirculationTriggersForm
        :submitAction="deleteTrigger"
        :formTitle="
            initialized
                ? $__x(
                      'Confirm deletion of trigger {triggerNumber} for {library}',
                      {
                          triggerNumber,
                          library: handleContext(
                              library_id,
                              libraries,
                              'library_id'
                          ),
                      }
                  )
                : $__('Confirm circulation trigger deletion')
        "
        :buttonText="$__('Confirm deletion')"
        :disabled="deletionWouldLeaveRuleSetWithoutDelay"
    >
        <fieldset class="rows">
            <TriggersTable
                :triggerNumber="triggerNumber"
                :modal="false"
                :displayActions="false"
                :enableActions="false"
                :ruleSets="formattedEffectiveRuleSets"
                :title="$__('Rule sets to be deleted')"
            />
        </fieldset>
        <fieldset class="rows">
            <div class="page-section bg-info">
                <p>
                    {{
                        $__(
                            "Deleting this trigger will delete every rule set listed above, and therefore completely remove this trigger for the library selected."
                        )
                    }}
                </p>
            </div>
            <div class="alert alert-warning" v-if="alertMessage">
                {{ alertMessage }}
            </div>
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
                        $__('Affected rule sets preview: state after deletion')
                    "
                />
            </div>
        </fieldset>
    </CirculationTriggersForm>
</template>
<script>
import TriggersTable from "./TriggersTable.vue";
import CirculationTriggersForm from "./CirculationTriggersForm.vue";
import { inject } from "vue";
import { storeToRefs } from "pinia";

export default {
    setup() {
        const circRulesStore = inject("circRulesStore");
        const {
            handleContext,
            findEffectiveRule,
            deleteRuleSet,
            hasExplicitRulesForTrigger,
            computeDeletionImpact,
            setAllFormattedRuleSets,
        } = circRulesStore;
        const {
            libraries,
            itemTypes,
            patronCategories,
            allCurrentLibraryRawRuleSets,
            ruleSuffixes,
        } = storeToRefs(circRulesStore);
        return {
            libraries,
            itemTypes,
            patronCategories,
            handleContext,
            findEffectiveRule,
            allCurrentLibraryRawRuleSets,
            ruleSuffixes,
            deleteRuleSet,
            hasExplicitRulesForTrigger,
            computeDeletionImpact,
            setAllFormattedRuleSets,
        };
    },
    data() {
        return {
            alertMessage: null,
            initialized: false,
            library_id: "*",
            triggerNumber: null,
            formattedEffectiveRuleSets: [],
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
        // a trigger with no delay is never processed, so a deletion that would
        // leave an inheriting set without one is not allowed
        deletionWouldLeaveRuleSetWithoutDelay() {
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
            this.setFormattedEffectiveRuleSets();

            const deletedRuleSets = this.allCurrentLibraryRawRuleSets.filter(
                rs => this.hasExplicitRulesForTrigger(rs, this.triggerNumber)
            );
            const { dependentRuleSets, projectedDependentEffectiveRuleSets } =
                await this.computeDeletionImpact(
                    deletedRuleSets,
                    this.triggerNumber
                );
            this.dependentRuleSets = dependentRuleSets;
            this.projectedDependentEffectiveRuleSets =
                projectedDependentEffectiveRuleSets;

            if (this.dependentRuleSets.length > 0) {
                this.alertMessage = this.$__(
                    "Some rule sets inherit one or more fields from the default trigger being deleted. After deletion, those fields will fall through to a less specific rule set or be left empty. See the preview below."
                );
            }

            if (this.deletionWouldLeaveRuleSetWithoutDelay) {
                this.alertMessage = this.$__(
                    "This trigger cannot be deleted. One or more sets that inherit from it would be left without a delay, which stops that trigger and every higher numbered trigger from being processed. See the preview below."
                );
            }

            this.initialized = true;
        },
        async deleteTrigger(e) {
            e.preventDefault();
            const failures = [];
            for (const ruleSet of this.allCurrentLibraryRawRuleSets) {
                try {
                    await this.deleteRuleSet(ruleSet, this.triggerNumber);
                } catch (e) {
                    failures.push(e);
                }
            }
            if (failures.length > 0) {
                this.alertMessage = failures[0];
                await this.loadModalData();
                return;
            }
            await this.$router.push({
                name: "CirculationTriggersList",
                query: { refresh: Date.now() },
            });
        },
        setFormattedEffectiveRuleSets() {
            this.formattedEffectiveRuleSets = [];
            this.allCurrentLibraryRawRuleSets.forEach(ruleSet => {
                const effectiveRuleSet = {
                    context: { ...ruleSet.context },
                };

                if (
                    !this.hasExplicitRulesForTrigger(
                        ruleSet,
                        this.triggerNumber
                    )
                ) {
                    return;
                }
                this.ruleSuffixes.forEach(ruleSuffix => {
                    effectiveRuleSet[
                        `overdue_${this.triggerNumber}_${ruleSuffix}`
                    ] = this.findEffectiveRule(
                        ruleSet.context,
                        ruleSuffix,
                        this.triggerNumber
                    );
                });
                effectiveRuleSet[`overdue_${this.triggerNumber}_has_rules`] =
                    this.findEffectiveRule(
                        ruleSet.context,
                        "has_rules",
                        this.triggerNumber
                    );
                this.formattedEffectiveRuleSets.push(effectiveRuleSet);
            });
        },
        setContext(query) {
            this.library_id = query.library_id ?? "*";
            this.triggerNumber = parseInt(query.triggerNumber);
        },
    },
    components: { TriggersTable, CirculationTriggersForm },
};
</script>

<style scoped>
#circulation-trigger-form-confirm-trigger-delete {
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
