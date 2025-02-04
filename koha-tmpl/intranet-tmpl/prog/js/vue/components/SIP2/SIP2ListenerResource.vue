<script>
import BaseResource from "./../BaseResource.vue";
import { inject } from "vue";
import { APIClient } from "../../fetch/api-client.js";

export default {
    extends: BaseResource,
    props: {
        routeAction: String,
    },
    setup(props) {
        const { setMessage } = inject("mainStore");

        setMessage(
            __(
                "Please note: Changes to listeners require a SIP server restart"
            ),
            true
        );

        return {
            ...BaseResource.setup({
                resourceName: "listener",
                nameAttr: "port",
                idAttr: "sip_listener_id",
                showComponent: "SIP2ListenersShow",
                listComponent: "SIP2ListenersList",
                addComponent: "SIP2ListenersFormAdd",
                editComponent: "SIP2ListenersFormAddEdit",
                apiClient: APIClient.sip2.listeners,
                resourceTableUrl: APIClient.sip2._baseURL + "listeners",
                i18n: {
                    displayName: __("Listener"),
                    displayNameLowerCase: __("listener"),
                    displayNamePlural: __("listeners"),
                },
            }),
        };
    },
    data() {
        return {
            resourceAttrs: [
                {
                    name: "port",
                    required: true,
                    type: "text",
                    label: __("Port"),
                    placeholder: "127.0.0.1:8023/tcp/IPv4",
                },
                {
                    name: "client_timeout",
                    type: "number",
                    label: __("Client timeout"),
                    placeholder: "600",
                    toolTip: "Client timeout in seconds",
                    defaultValue: 600,
                },
                {
                    name: "protocol",
                    required: true,
                    type: "text",
                    label: __("Protocol"),
                    placeholder: "SIP/2.00",
                    defaultValue: "SIP/2.00",
                },
                {
                    name: "timeout",
                    type: "number",
                    label: __("Timeout"),
                    placeholder: "60",
                    toolTip: "Timeout in seconds",
                    defaultValue: 60,
                },
                {
                    name: "transport",
                    required: true,
                    type: "select",
                    options: [
                        { value: "RAW", description: "RAW" },
                        { value: "telnet", description: "telnet" },
                    ],
                    requiredKey: "value",
                    selectLabel: "description",
                    label: __("Transport"),
                    defaultValue: "RAW",
                },
            ],
            tableOptions: {
                columns: this.getTableColumns(),
                url: () => this.resourceTableUrl,
                table_settings: this.listeners_table_settings,
                actions: {
                    0: ["show"],
                    "-1": this.embedded
                        ? [
                              {
                                  select: {
                                      text: this.$__("Select"),
                                      icon: "fa fa-check",
                                  },
                              },
                          ]
                        : ["edit", "delete"],
                },
            },
        };
    },
    methods: {
        getTableColumns: function () {
            return [
                {
                    title: __("Port"),
                    data: "port",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return (
                            '<a role="button" class="show">' +
                            escape_str(`${row.port}`) +
                            "</a>"
                        );
                    },
                },
                {
                    title: __("Client timeout"),
                    data: "client_timeout",
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("Protocol"),
                    data: "protocol",
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("Timeout"),
                    data: "timeout",
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("Transport"),
                    data: "transport",
                    searchable: true,
                    orderable: true,
                },
            ];
        },
        onSubmit(e, listenerToSave) {
            e.preventDefault();

            let listener = JSON.parse(JSON.stringify(listenerToSave)); // copy
            let sip_listener_id = listener.sip_listener_id;

            delete listener.sip_listener_id;

            const client = APIClient.sip2;
            if (sip_listener_id) {
                client.listeners.update(listener, sip_listener_id).then(
                    success => {
                        this.setMessage(this.$__("Listener updated"));
                        this.$router.push({ name: "SIP2ListenersList" });
                    },
                    error => {}
                );
            } else {
                client.listeners.create(listener).then(
                    success => {
                        this.setMessage(this.$__("Listener created"));
                        this.$router.push({ name: "SIP2ListenersList" });
                    },
                    error => {}
                );
            }
        },
    },
    name: "SIP2ListenerResource",
};
</script>
