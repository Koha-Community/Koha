<template>
    <WidgetWrapper v-bind="widgetWrapperProps">
        <template #default>
            <ul class="count-list">
                <li v-for="def in countDefinitions" :key="def.name">
                    <strong>
                        <router-link v-if="def.page" :to="{ name: def.page }">
                            {{ createCountText(def) }}
                        </router-link>
                        <span v-else class="inactive-link">{{
                            createCountText(def)
                        }}</span>
                    </strong>
                </li>
            </ul>
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
                labelSingular: __("1 agreement"),
                labelPlural: __("%s agreements"),
                count: 0,
            },
            {
                page: "LicensesList",
                name: "licenses_count",
                labelSingular: __("1 license"),
                labelPlural: __("%s licenses"),
                count: 0,
            },
            {
                name: "documents_count",
                labelSingular: __("1 document"),
                labelPlural: __("%s documents"),
                count: 0,
            },
            {
                page: "EHoldingsLocalPackagesList",
                name: "eholdings_packages_count",
                labelSingular: __("1 local package"),
                labelPlural: __("%s local packages"),
                count: 0,
            },
            {
                page: "EHoldingsLocalTitlesList",
                name: "eholdings_titles_count",
                labelSingular: __("1 local title"),
                labelPlural: __("%s local titles"),
                count: 0,
            },
            {
                page: "UsageStatisticsDataProvidersList",
                name: "usage_data_providers_count",
                labelSingular: __("1 usage data provider"),
                labelPlural: __("%s usage data providers"),
                count: 0,
            },
        ]);

        const createCountText = definition => {
            if (definition.count === 1) {
                return definition.labelSingular;
            } else {
                return definition.labelPlural.format(definition.count);
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
<style scoped>
.count-list {
    list-style: none;
    padding: 0;
    display: flex;
    gap: 0.75rem;
    flex-wrap: wrap;
}
.count-list li {
    background: #eee;
    padding: 0.3em 0.8em;
    border-radius: 12px;
}
.inactive-link {
    color: #888;
}
.count-list a {
    text-decoration: none;
}
.count-list a:hover {
    text-decoration: underline;
}
</style>
