<template>
    <fieldset class="rows" id="agreement_periods">
        <legend>{{ $__("Periods") }}</legend>
        <fieldset
            :id="`agreement_period_${counter}`"
            class="rows"
            v-for="(period, counter) in periods"
            v-bind:key="counter"
        >
            <legend>
                {{ $__("Agreement period %s").format(counter + 1) }}
                <a href="#" @click.prevent="deletePeriod(counter)"
                    ><i class="fa fa-trash"></i>
                    {{ $__("Remove this period") }}</a
                >
            </legend>
            <ol>
                <li>
                    <label :for="`started_on_${counter}`" class="required"
                        >{{ $__("Start date") }}:
                    </label>
                    <flat-pickr
                        :id="`started_on_${counter}`"
                        v-model="period.started_on"
                        required
                        :config="fp_config"
                        :data-date_to="`ended_on_${counter}`"
                    />
                    <span class="required">{{ $__("Required") }}</span>
                </li>
                <li>
                    <label :for="`ended_on_${counter}`"
                        >{{ $__("End date") }}:</label
                    >
                    <flat-pickr
                        :id="`ended_on_${counter}`"
                        v-model="period.ended_on"
                        :config="fp_config"
                    />
                </li>
                <li>
                    <label :for="`cancellation_deadline_${counter}`"
                        >{{ $__("Cancellation deadline") }}:
                    </label>
                    <flat-pickr
                        :id="`cancellation_deadline_${counter}`"
                        v-model="period.cancellation_deadline"
                        :config="fp_config"
                    />
                </li>
                <li>
                    <label :for="`notes_${counter}`">{{ $__("Notes") }}:</label>
                    <input
                        :id="`notes_${counter}`"
                        type="text"
                        class="notes"
                        :name="`notes_${counter}`"
                        v-model="period.notes"
                    />
                </li>
            </ol>
        </fieldset>
        <a class="btn btn-default" @click="addPeriod"
            ><font-awesome-icon icon="plus" /> {{ $__("Add new period") }}</a
        >
    </fieldset>
</template>

<script>
import flatPickr from "vue-flatpickr-component";
export default {
    name: "AgreementPeriods",
    data() {
        return {
            fp_config: flatpickr_defaults,
        };
    },
    props: {
        periods: Array,
    },
    methods: {
        addPeriod() {
            this.periods.push({
                started_on: null,
                ended_on: null,
                cancellation_deadline: null,
                notes: null,
            });
        },
        deletePeriod(counter) {
            this.periods.splice(counter, 1);
        },
    },
    components: {
        flatPickr,
    },
};
</script>
