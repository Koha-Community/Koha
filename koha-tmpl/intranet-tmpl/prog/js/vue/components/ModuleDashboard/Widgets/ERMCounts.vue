<template>
    <WidgetWrapper v-bind="widgetWrapperProps">
        <template #default>
            <p class="text-left">
                {{ $__("There are") }}
                <template
                    v-for="(definition, index) in countDefinitions"
                    :key="index"
                >
                    <strong>
                        <router-link
                            v-if="definition.page"
                            :to="{ name: definition.page }"
                        >
                            {{ createCountText(definition) }}
                        </router-link>
                        <span v-else class="inactive-link">
                            {{ createCountText(definition) }}
                        </span>
                    </strong>
                    <template v-if="index < countDefinitions.length - 1"
                        >,&nbsp;</template
                    >
                    <template v-else>.</template>
                </template>
            </p>
        </template>
    </WidgetWrapper>
</template>
<script>
import { reactive } from "vue";
import { useBaseWidget } from "../../../composables/base-widget.js";
import { APIClient } from "../../../fetch/api-client.js";
import WidgetWrapper from "../WidgetWrapper.vue";
import { useRouter } from "vue-router";
import { $__ } from "@koha-vue/i18n";

export default {
    name: "ERMCounts",
    components: { WidgetWrapper },
    props: {
        display: String,
        dashboardColumn: String,
    },
    emits: ["removed", "added", "moveWidget"],
    setup(props, { emit }) {
        const router = useRouter();
        const baseWidget = useBaseWidget(
            {
                id: "ERMCounts",
                name: $__("Counts"),
                icon: "fas fa-chart-bar",
                description: $__(
                    "Shows the number of ERM related resources such as agreements, licenses, local packages, local titles, documents, etc."
                ),
                ...props,
            },
            emit
        );
        const countDefinitions = reactive([
            {
                page: "AgreementsList",
                name: "agreements_count",
                labelSingular: __("agreement"),
                labelPlural: __("agreements"),
                count: 0,
            },
            {
                page: "LicensesList",
                name: "licenses_count",
                labelSingular: __("license"),
                labelPlural: __("licenses"),
                count: 0,
            },
            {
                name: "documents_count",
                labelSingular: __("document"),
                labelPlural: __("documents"),
                count: 0,
            },
            {
                page: "EHoldingsLocalPackagesList",
                name: "eholdings_packages_count",
                labelSingular: __("local package"),
                labelPlural: __("local packages"),
                count: 0,
            },
            {
                page: "EHoldingsLocalTitlesList",
                name: "eholdings_titles_count",
                labelSingular: __("local title"),
                labelPlural: __("local titles"),
                count: 0,
            },
            {
                page: "UsageStatisticsDataProvidersList",
                name: "usage_data_providers_count",
                labelSingular: __("usage data provider"),
                labelPlural: __("usage data providers"),
                count: 0,
            },
        ]);

        const createCountText = definition => {
            if (definition.count === 1) {
                return `${definition.count} ${definition.labelSingular}`;
            } else {
                return `${definition.count} ${definition.labelPlural}`;
            }
        };

        async function getCounts() {
            try {
                const response = await APIClient.erm.counts.get();

                Object.keys(response.counts).forEach(key => {
                    const item = countDefinitions.find(i => i.name === key);
                    if (item) {
                        item.count = response.counts[key];
                    }
                });

                baseWidget.loading.value = false;
            } catch (error) {
                console.error(error);
            }
        }

        baseWidget.onDashboardMounted(() => {
            getCounts();
        });

        function goToPage(page) {
            router.push({ name: page });
        }

        return {
            ...baseWidget,
            createCountText,
            countDefinitions,
            goToPage,
        };
    },
};
</script>
