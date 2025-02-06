<template>
    <legend>{{ $__("Data provider") }}</legend>
    <fieldset class="rows">
        <ol>
            <li>
                <label>{{ $__("Data provider name") }}:</label>
                <span id="usage_data_provider_name">
                    {{ usage_data_provider.name }}
                </span>
            </li>
            <li>
                <label>{{ $__("Description") }}:</label>
                <span id="usage_data_provider_description">
                    {{ usage_data_provider.description }}
                </span>
            </li>
            <li>
                <label>{{ $__("Status") }}:</label>
                <span id="harvester_status">
                    {{
                        usage_data_provider.active
                            ? $__("Active")
                            : $__("Inactive")
                    }}
                </span>
            </li>
            <li>
                <label>{{ $__("Service type") }}:</label>
                <span id="usage_data_provider_service_type">
                    {{ usage_data_provider.service_type }}
                </span>
            </li>
            <li>
                <label>{{ $__("Report types") }}:</label>
                <span id="report_type">
                    {{ usage_data_provider.report_types }}
                </span>
            </li>
            <li>
                <label>{{ $__("Service platform") }}:</label>
                <span id="service_platform">
                    {{ usage_data_provider.service_platform }}
                </span>
            </li>
        </ol>
    </fieldset>
    <legend>{{ $__("SUSHI credentials") }}</legend>
    <fieldset class="rows">
        <ol>
            <li>
                <label>{{ $__("Service URL") }}:</label>
                <span id="usage_data_provider_service_url">
                    {{ usage_data_provider.service_url }}
                </span>
            </li>
            <li>
                <label>{{ $__("Report release") }}:</label>
                <span id="usage_data_provider_report_release">
                    {{ usage_data_provider.report_release }}
                </span>
            </li>
            <li>
                <label>{{ $__("Customer ID") }}:</label>
                <span id="usage_data_provider_customer_id">
                    {{ usage_data_provider.customer_id }}
                </span>
            </li>
            <li>
                <label>{{ $__("Requestor ID") }}:</label>
                <span id="usage_data_provider_requestor_id">
                    {{ usage_data_provider.requestor_id }}
                </span>
            </li>
            <li>
                <label>{{ $__("API key") }}:</label>
                <span id="usage_data_provider_api_key">
                    {{ usage_data_provider.api_key }}
                </span>
            </li>
            <li>
                <label>{{ $__("Requestor name") }}:</label>
                <span id="usage_data_provider_requestor_name">
                    {{ usage_data_provider.requestor_name }}
                </span>
            </li>
            <li>
                <label>{{ $__("Requestor email") }}:</label>
                <span id="usage_data_provider_requestor_email">
                    {{ usage_data_provider.requestor_email }}
                </span>
            </li>
        </ol>
    </fieldset>
</template>

<script>
export default {
    props: ["usage_data_provider"],
    name: "UsageStatisticsDataProviderDetails",
};
</script>

<style scoped>
.rows {
    float: none;
}
</style>
