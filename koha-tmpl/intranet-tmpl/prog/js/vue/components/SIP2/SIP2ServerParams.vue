<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="serverparams">
        <h2>
            {{ $__("Edit server params") }}
        </h2>
        <div>
            <form @submit="onSubmit($event)">
                <fieldset class="rows">
                    <ol>
                        <li
                            v-for="(param, index) in this
                                .server_params_definitions"
                            v-bind:key="index"
                        >
                            <FormElement
                                :resource="this.server_params"
                                :attr="param"
                                :index="index"
                            />
                        </li>
                    </ol>
                </fieldset>
                <fieldset class="action">
                    <ButtonSubmit />
                </fieldset>
            </form>
        </div>
    </div>
</template>

<script>
import { inject } from "vue";
import { APIClient } from "../../fetch/api-client.js";
import FormElement from "../FormElement.vue";
import ButtonSubmit from "../ButtonSubmit.vue";

export default {
    setup() {
        const { setMessage } = inject("mainStore");

        setMessage(
            __(
                "Please note: Changes to server params require a SIP server restart"
            ),
            true
        );

        return {
            setMessage,
        };
    },
    data() {
        return {
            initialized: false,
            server_params_definitions: [
                {
                    name: "min_servers",
                    required: true,
                    type: "number",
                    label: "min_servers",
                },
                {
                    name: "min_spare_servers",
                    required: true,
                    type: "number",
                    label: "min_spare_servers",
                },
                {
                    name: "max_servers",
                    required: true,
                    type: "number",
                    label: "max_servers",
                },
                {
                    name: "setsid",
                    required: true,
                    type: "number",
                    label: "setsid",
                },
                {
                    name: "user",
                    required: true,
                    type: "text",
                    label: "user",
                },
                {
                    name: "group",
                    required: true,
                    type: "text",
                    label: "group",
                },
                {
                    name: "pid_file",
                    required: true,
                    type: "text",
                    label: "pid_file",
                },
                {
                    name: "custom_tcp_keepalive",
                    required: true,
                    type: "number",
                    label: "custom_tcp_keepalive",
                },
                {
                    name: "custom_tcp_keepalive_time",
                    required: true,
                    type: "number",
                    label: "custom_tcp_keepalive_time",
                },
                {
                    name: "custom_tcp_keepalive_intvl",
                    required: true,
                    type: "number",
                    label: "custom_tcp_keepalive_intvl",
                },
            ],
            server_params: {
                min_servers: "1",
                min_spare_servers: "0",
                max_servers: "1",
                setsid: "1",
                user: "koha",
                group: "koha",
                pid_file: "/var/run/sipserver.pid",
                custom_tcp_keepalive: "0",
                custom_tcp_keepalive_time: "7200",
                custom_tcp_keepalive_intvl: "75",
            },
        };
    },
    created() {
        this.getServerParams();
    },
    methods: {
        async getServerParams() {
            const client = APIClient.sip2;
            client.serverparams.getAll().then(
                returned_server_params => {
                    returned_server_params.forEach(server_param => {
                        this.server_params[server_param.key] =
                            server_param.value;
                    });
                    this.initialized = true;
                },
                error => {}
            );
        },
        onSubmit(e) {
            e.preventDefault();

            const client = APIClient.sip2;
            const updatedParams = Object.keys(this.server_params).map(key => {
                return { key: key, value: this.server_params[key] };
            });

            client.serverparams.updateAll(updatedParams).then(
                success => {
                    this.setMessage(
                        this.$__(
                            "Server parameters updated. Please restart the SIP server."
                        ),
                        true
                    );
                },
                error => {}
            );
        },
    },
    components: {
        ButtonSubmit,
        FormElement,
    },
    name: "SIP2ServerParams",
};
</script>

<style scoped>
:deep(fieldset.rows) label {
    width: 15rem;
}
</style>