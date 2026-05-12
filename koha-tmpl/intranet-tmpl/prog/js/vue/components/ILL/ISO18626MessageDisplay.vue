<template>
    <FormElement
        :resource="messageFilterOptions"
        :attr="{
            label: $__('Show confirmations'),
            name: 'showConfirmationRows',
            type: 'checkbox',
        }"
    />
    <table id="iso18626_messages">
        <thead>
            <tr>
                <th>{{ $__("Type") }}</th>
                <th>{{ $__("Information") }}</th>
                <th>{{ $__("Timestamp") }}</th>
                <th>{{ $__("Content") }}</th>
            </tr>
        </thead>
        <tbody>
            <tr
                v-for="message in filteredMessages"
                v-bind:key="message.iso18626_message_id"
            >
                <td>
                    <i
                        v-if="message.type.includes('request')"
                        class="fas fa-download"
                        aria-hidden="true"
                    ></i>
                    <i v-else class="fas fa-upload" aria-hidden="true"></i>
                    &nbsp;
                    {{ message.type }}
                </td>
                <td>
                    {{ getMessageData(message.content) }}
                </td>
                <td>
                    {{ new Date(message.timestamp).toLocaleString() }}
                </td>
                <td>
                    <button
                        class="btn btn-default"
                        @click="openModal(message.content)"
                    >
                        <i class="fas fa-envelope" aria-hidden="true"></i>
                        &nbsp; {{ $__("View message") }}
                    </button>
                </td>
            </tr>
        </tbody>
    </table>
</template>

<script>
import FormElement from "../FormElement.vue";
import { inject, ref, computed } from "vue";
import { $__ } from "@koha-vue/i18n";

export default {
    props: {
        iso18626_request: Object,
    },
    setup(props) {
        const modalVisible = ref(false);
        const messageFilterOptions = ref({
            showConfirmationRows: false,
        });
        const prettifiedMessage = ref(null);
        const { setConfirmationDialog, setMessage, setError } =
            inject("mainStore");

        const filteredMessages = computed(() => {
            return props.iso18626_request.messages.filter(message => {
                if (messageFilterOptions.value.showConfirmationRows) {
                    return true;
                }
                return !message.type.toLowerCase().includes("confirmation");
            });
        });

        const getMessageData = (message, type) => {
            const parsedMessage = Object.values(JSON.parse(message))[0];
            let message_data;
            message_data =
                parsedMessage?.action !== undefined &&
                parsedMessage?.action !== null
                    ? parsedMessage?.action
                    : null;
            if (message_data === null) {
                message_data =
                    parsedMessage?.messageInfo?.reasonForMessage !==
                        undefined &&
                    parsedMessage?.messageInfo?.reasonForMessage !== null
                        ? parsedMessage?.messageInfo?.reasonForMessage
                        : null;
                if (message_data !== null) {
                    message_data = $__("Reason: %s").format(message_data);
                }
            } else {
                message_data = $__("Action: %s").format(message_data);
            }
            return message_data;
        };

        function openModal(message) {
            const messageObj = Object.values(JSON.parse(message))[0];
            const container = document.createElement("div");
            container.classList.add("accordion");
            generateCollapsibleTabs(messageObj, container);
            const message_type = Object.keys(JSON.parse(message))[0];
            setConfirmationDialog({
                title: $__("ISO18626 message: %s").format(message_type),
                message: container.outerHTML,
                size: "modal-lg",
            });
        }

        function generateCollapsibleTabs(obj, parent) {
            const sortedKeys = Object.keys(obj).sort((a, b) => {
                const order = [
                    "action",
                    "header",
                    "confirmationHeader",
                    "bibliographicInfo",
                    "messageInfo",
                    "statusInfo",
                ];
                const indexA =
                    order.indexOf(a) !== -1 ? order.indexOf(a) : Infinity;
                const indexB =
                    order.indexOf(b) !== -1 ? order.indexOf(b) : Infinity;
                return indexA - indexB;
            });

            const top_level_key_number = Object.keys(obj).length;
            for (const key of sortedKeys) {
                if (typeof obj[key] === "object") {
                    const details = document.createElement("fieldset");
                    details.classList.add("rows");

                    const summary = document.createElement("legend");
                    const keySpan = document.createElement("span");
                    keySpan.textContent =
                        key.charAt(0).toUpperCase() + key.slice(1);
                    summary.appendChild(keySpan);
                    summary.setAttribute("data-bs-toggle", "collapse");
                    summary.setAttribute("data-bs-target", "#collapse_" + key);

                    if (key === "header") {
                        summary.setAttribute("aria-expanded", "false");
                        summary.classList.add("collapsed");
                    }
                    summary.classList.add("expanded");

                    summary.setAttribute("aria-controls", "collapseExample");
                    summary.innerHTML =
                        '<i class="fa fa-caret-down"></i> ' + summary.innerHTML;

                    const nestedContainer = document.createElement("ol");
                    nestedContainer.setAttribute("id", "collapse_" + key);
                    nestedContainer.classList.add("collapse");
                    if (key !== "header") {
                        nestedContainer.classList.add("show");
                    }
                    const nestedTable = document.createElement("table");

                    // Call generateTableRows for the nested object
                    generateTableRows(obj[key], nestedTable);

                    nestedContainer.appendChild(nestedTable);
                    details.appendChild(summary);
                    details.appendChild(nestedContainer);

                    parent.appendChild(details);
                } else {
                    // Handle regular top-level items
                    const div = document.createElement("div");
                    div.textContent =
                        key.charAt(0).toUpperCase() +
                        key.slice(1) +
                        ": " +
                        obj[key];
                    div.classList.add("fs-2", "fw-bold", "p-2");
                    parent.appendChild(div);
                }
            }
        }

        function generateTableRows(obj, parent) {
            for (const key in obj) {
                if (typeof obj[key] === "object") {
                    const tr = document.createElement("tr");
                    const th = document.createElement("th");
                    th.textContent = key;
                    tr.appendChild(th);

                    const td = document.createElement("td");
                    tr.appendChild(td);

                    const nestedTable = document.createElement("table");
                    nestedTable.classList.add("nested-table");
                    nestedTable.style.paddingLeft = "20px";
                    nestedTable.style.borderLeft = "1px solid #ccc";

                    generateTableRows(obj[key], nestedTable);

                    td.appendChild(nestedTable);

                    parent.appendChild(tr);
                } else {
                    const tr = document.createElement("tr");
                    const th = document.createElement("th");
                    th.textContent = key;
                    tr.appendChild(th);

                    const td = document.createElement("td");
                    td.textContent = obj[key];
                    tr.appendChild(td);

                    parent.appendChild(tr);
                }
            }
        }

        return {
            modalVisible,
            prettifiedMessage,
            openModal,
            filteredMessages,
            messageFilterOptions,
            getMessageData,
        };
    },
    components: {
        FormElement,
    },
    name: "ResourceFormSave",
};
</script>
