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
                i18nLabel: count =>
                    __n("%s agreement", "%s agreements", count).format(count),
                count: 0,
            },
            {
                page: "LicensesList",
                name: "licenses_count",
                i18nLabel: count =>
                    __n("%s license", "%s licenses", count).format(count),
                count: 0,
            },
            {
                name: "documents_count",
                i18nLabel: count =>
                    __n("%s document", "%s documents", count).format(count),
                count: 0,
            },
            {
                page: "EHoldingsLocalPackagesList",
                name: "eholdings_packages_count",
                i18nLabel: count =>
                    __n("%s local package", "%s local packages", count).format(
                        count
                    ),
                count: 0,
            },
            {
                page: "EHoldingsLocalTitlesList",
                name: "eholdings_titles_count",
                i18nLabel: count =>
                    __n("%s local title", "%s local titles", count).format(
                        count
                    ),
                count: 0,
            },
            {
                page: "UsageStatisticsDataProvidersList",
                name: "usage_data_providers_count",
                i18nLabel: count =>
                    __n(
                        "%s usage data provider",
                        "%s usage data providers",
                        count
                    ).format(count),
                count: 0,
            },
        ]);

        const createCountText = definition => {
            return definition.i18nLabel(definition.count);
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
