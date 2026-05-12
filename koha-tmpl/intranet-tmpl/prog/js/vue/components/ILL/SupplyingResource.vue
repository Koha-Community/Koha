<template>
    <BaseResource
        :routeAction="routeAction"
        :instancedResource="this"
    ></BaseResource>
</template>
<script>
import { useRouter } from "vue-router";
import { ISO18626 } from "./ISO18626.js";
import BaseResource from "../BaseResource.vue";
import { useBaseResource } from "../../composables/base-resource.js";
import { inject, ref } from "vue";
import { APIClient } from "../../fetch/api-client.js";
import { $__ } from "@koha-vue/i18n";

export default {
    props: {
        routeAction: String,
    },

    setup(props) {
        const router = useRouter();
        const { getCodesForElement } = ISO18626();

        const {
            setConfirmationDialog,
            setMessage,
            updateConfirmationDialogInputs,
            submitting,
            submitted,
        } = inject("mainStore");

        const conditionalInputs = ref([]);
        const isActionPending = ref(false);

        const statuses = ref([
            {
                id: "RequestReceived",
                next_actions: [
                    "PlaceHold",
                    "ExpectToSupply",
                    "CopyCompleted",
                    "Loaned",
                    "RetryPossible",
                    "WillSupply",
                    "Unfilled",
                    "Cancelled",
                ],
            },
            {
                id: "ExpectToSupply",
                confirm_message: $__(
                    "Supplying library expects to fill the request, based on e.g. information in the local OPAC. The message may include the ExpectedDeliveryDate"
                ),
                dont_show: resource =>
                    resource.service_type === "Loan" ||
                    resource.status !== "RequestReceived",
                button_label: $__("Expect to supply copy"),
                icon: "fa-calendar-days",
                btn_class: "btn btn-primary",
                next_actions: [
                    "CopyCompleted",
                    "Loaned",
                    "WillSupply",
                    "RetryPossible",
                    "Unfilled",
                    "Cancelled",
                ],
                action_inputs: [
                    {
                        name: "expectedDeliveryDate",
                        label: $__("Expected delivery date"),
                        type: "date",
                        toolTip: $__(
                            "Date and time the supplying library expects to deliver the item."
                        ),
                    },
                ],
            },
            {
                id: "PlaceHold",
                dont_show: resource =>
                    resource.service_type === "Copy" ||
                    resource.hold_id ||
                    resource.status !== "RequestReceived",
                button_label: resource =>
                    resource.biblio_id
                        ? $__("Expect to supply (Place hold)")
                        : $__("Expect to supply (Search to hold)"),
                icon: resource =>
                    resource.biblio_id ? "fa-calendar-days" : "fa-search",
                btn_class: "btn btn-primary",
                next_actions: [
                    "CopyCompleted",
                    "Loaned",
                    "WillSupply",
                    "RetryPossible",
                    "Unfilled",
                    "Cancelled",
                ],

                onClick: resource => {
                    const date = new Date();
                    date.setTime(date.getTime() + 10 * 60 * 1000);

                    Cookies.set(
                        "holdfor",
                        resource.requesting_agency.patron_id,
                        {
                            path: "/",
                            expires: date,
                            sameSite: "Lax",
                        }
                    );
                    Cookies.set(
                        "holdforsupplyill",
                        resource.iso18626_request_id,
                        {
                            path: "/",
                            expires: date,
                            sameSite: "Lax",
                        }
                    );

                    if (resource.biblio_id) {
                        getPatron(resource.requesting_agency.patron_id).then(
                            patron => {
                                location.href =
                                    `/cgi-bin/koha/reserve/request.pl?` +
                                    `biblionumber=${resource.biblio_id}` +
                                    `&findborrower=${patron.cardnumber}` +
                                    `&supplyill=${resource.iso18626_request_id}`;
                            }
                        );
                    } else {
                        location.href =
                            `/cgi-bin/koha/catalogue/search.pl?context=supplyill:` +
                            resource.iso18626_request_id;
                    }
                },
            },
            {
                id: "WillSupply",
                dont_show: resource => {
                    return !(
                        resource.status === "ExpectToSupply" &&
                        resource.biblio_id &&
                        resource.hold_id &&
                        !resource.hold?.item_id
                    );
                },
                button_label: $__("Will supply (Assign item)"),
                icon: "fa-download",
                btn_class: "btn btn-primary",
                next_actions: [
                    "Loaned",
                    "RetryPossible",
                    "CopyCompleted",
                    "Unfilled",
                ],
                onClick: resource => {
                    getBiblioItems(resource.biblio_id).then(result => {
                        let tableHtml = `
                            <p>${$__("An item must be associated with this hold. Check in any of the following items and confirm the hold.")}</p>
                            <table class="table table-bordered table-striped" style="width:100%; margin-top:10px;">
                                <thead>
                                    <tr>
                                        <th>${$__("Barcode")}</th>
                                        <th>${$__("Home Library")}</th>
                                        <th>${$__("Holding Library")}</th>
                                        <th>${$__("Action")}</th>
                                    </tr>
                                </thead>
                                <tbody>`;

                        result.forEach(item => {
                            const barcode =
                                item.external_id || $__("No Barcode");
                            const home_library =
                                item.home_library_id?.name ||
                                item.home_library_id ||
                                $__("Unknown");
                            const holding_library =
                                item.holding_library_id?.name ||
                                item.holding_library_id ||
                                $__("Unknown");
                            const link = `/cgi-bin/koha/catalogue/detail.pl?biblionumber=${resource.biblio_id}`;
                            const checkinAction = renderCheckinForm(
                                item.external_id
                            );

                            tableHtml += `
                                <tr>
                                    <td><a href="${link}" target="_blank"><strong>${barcode}</strong></a></td>
                                    <td>${home_library}</td>
                                    <td>${holding_library}</td>
                                    <td>${checkinAction}</td>
                                </tr>`;
                        });
                        tableHtml += `</tbody></table>`;

                        setConfirmationDialog({
                            size: "modal-lg",
                            title: $__(
                                "Update this request's status to <strong>WillSupply</strong>?"
                            ),
                            message: tableHtml,
                            cancel_label: $__("Cancel"),
                        });
                    });
                },
            },
            {
                id: "Loaned",
                dont_show: iso18626_request => !iso18626_request?.hold?.item_id,
                button_label: $__("Mark as loaned (Check out)"),
                icon: "fa-box",
                btn_class: "btn btn-primary",
                next_actions: ["LoanCompleted", "CompletedWithoutReturn"],
                onClick: resource => {
                    getItem(resource.hold.item_id).then(result => {
                        performCheckout({
                            borrowernumber:
                                resource.requesting_agency.patron_id,
                            branch: userenv?.branch,
                            barcode: result.external_id,
                        });
                    });
                },
            },
            // TODO: 'Overdue' should automatically be set by a cron?
            // {
            //     id: "Overdue",
            //     confirm_message: $__(
            //         "The item currently on loan to the requesting library for this request is now overdue"
            //     ),
            //     button_label: $__("Mark as ovedue"),
            //     icon: "fa-box",
            //     next_actions: ["LoanCompleted", "CompletedWithoutReturn"], //[ 'Recalled', 'HoldReturn', 'LoanCompleted' ]
            //     action_inputs: [],
            // },
            {
                id: "Recalled",
                confirm_message: $__(
                    "The item currently on loan to the requesting library for this request has been recalled"
                ),
                button_label: $__("Ask for recall"),
                icon: "fa-box",
                next_actions: ["LoanCompleted", "CompletedWithoutReturn"],
                action_inputs: [],
            },
            {
                id: "RetryPossible",
                confirm_message: $__(
                    "The supplying library cannot fill the request based on information provided or may be able to supply at a later date. Additional information is provided in the RetryInfo section. The requesting library may submit a Retry request which may include updated information"
                ),
                button_label: $__("Ask for retry"),
                btn_class: "btn btn-danger",
                icon: "fa-repeat",
                next_actions: [],
                action_inputs: [
                    {
                        name: "retryBefore",
                        label: $__("Retry before"),
                        type: "date",
                        toolTip: $__(
                            "Specify that a retry should be attempted before the specified date."
                        ),
                    },
                    {
                        name: "retryAfter",
                        label: $__("Retry after"),
                        type: "date",
                        toolTip: $__(
                            "Specify that a retry should be attempted only after the specified date."
                        ),
                    },
                    {
                        name: "reasonRetry",
                        label: $__("Reason for retry"),
                        required: true,
                        toolTip: $__(
                            "Specify the reason why a retry from the requesting agency is necessary"
                        ),
                        type: "select",
                        onSelected: resource => {
                            conditionalInputs.value = [];
                            if (resource.reasonRetry == "CostExceedsMaxCost") {
                                conditionalInputs.value.push({
                                    name: "offeredCostsCurrencyCode",
                                    type: "select",
                                    label: $__("Currency code"),
                                    required: true,
                                    toolTip: $__(
                                        "Specify the currency code for the offered costs"
                                    ),
                                    options: [
                                        {
                                            value: "USD",
                                            description: $__("USD"),
                                        },
                                        {
                                            value: "EUR",
                                            description: $__("EUR"),
                                        },
                                        {
                                            value: "GBP",
                                            description: $__("GBP"),
                                        },
                                        {
                                            value: "AUD",
                                            description: $__("AUD"),
                                        },
                                        {
                                            value: "SEK",
                                            description: $__("SEK"),
                                        },
                                    ],
                                    requiredKey: "value",
                                    selectLabel: "description",
                                });
                                conditionalInputs.value.push({
                                    name: "offeredCostsMonetaryValue",
                                    type: "number",
                                    label: $__("Monetary value"),
                                    required: true,
                                    toolTip: $__(
                                        "Specify the monetary value for the offered costs"
                                    ),
                                });
                            } else if (
                                resource.reasonRetry == "MultiVolAvail"
                            ) {
                                conditionalInputs.value.push({
                                    name: "volume",
                                    type: "text",
                                    label: $__("Volume(s)"),
                                    required: true,
                                    placeholder: "14,15",
                                    toolTip: $__(
                                        "Specify which volume(s) are available, separated by comma ','"
                                    ),
                                });
                            } else if (
                                resource.reasonRetry == "MustMeetLoanCondition"
                            ) {
                                conditionalInputs.value.push({
                                    name: "loanCondition",
                                    label: $__("Loan condition(s)"),
                                    required: true,
                                    type: "select",
                                    toolTip: $__(
                                        "Specify the condition(s) of use that need to be met once the requested item is delivered"
                                    ),
                                    allowMultipleChoices: true,
                                    options:
                                        getCodesForElement("loanCondition"),
                                    requiredKey: "value",
                                    selectLabel: "description",
                                });
                            } else if (
                                resource.reasonRetry == "ReqDelMethodNotSupp"
                            ) {
                                conditionalInputs.value.push({
                                    name: "deliveryMethod",
                                    type: "select",
                                    vselectStyle: {
                                        dropdownMaxHeight: "150px",
                                    },
                                    toolTip: $__(
                                        "Specify which delivery method(s) can be supplied"
                                    ),
                                    allowMultipleChoices: true,
                                    label: $__("Delivery method(s)"),
                                    required: true,
                                    options:
                                        getCodesForElement("deliveryMethod"),
                                    requiredKey: "value",
                                    selectLabel: "description",
                                    onUpdated: inputValues => {
                                        const deliveryMethods =
                                            inputValues.deliveryMethod;
                                        if (
                                            deliveryMethods &&
                                            deliveryMethods.includes("Courier")
                                        ) {
                                            const existingInput =
                                                conditionalInputs.value.find(
                                                    input =>
                                                        input.name ===
                                                        "courierName"
                                                );
                                            if (!existingInput) {
                                                conditionalInputs.value.push({
                                                    name: "courierName",
                                                    type: "select",
                                                    vselectStyle: {
                                                        dropdownMaxHeight:
                                                            "150px",
                                                    },
                                                    allowMultipleChoices: true,
                                                    toolTip: $__(
                                                        "Specify which courier(s) can be used"
                                                    ),
                                                    label: $__(
                                                        "Courier name(s)"
                                                    ),
                                                    required: true,
                                                    options:
                                                        getCodesForElement(
                                                            "courierName"
                                                        ),
                                                    requiredKey: "value",
                                                    selectLabel: "description",
                                                });
                                                updateConfirmationDialogInputs(
                                                    getDialogInputs(inputValues)
                                                );
                                            }
                                        } else {
                                            const existingInput =
                                                conditionalInputs.value.find(
                                                    input =>
                                                        input.name ===
                                                        "courierName"
                                                );
                                            if (existingInput) {
                                                const index =
                                                    conditionalInputs.value.indexOf(
                                                        existingInput
                                                    );
                                                if (index > -1) {
                                                    conditionalInputs.value.splice(
                                                        index,
                                                        1
                                                    );
                                                    updateConfirmationDialogInputs(
                                                        getDialogInputs(
                                                            inputValues
                                                        )
                                                    );
                                                }
                                            }
                                        }
                                    },
                                });
                            } else if (
                                resource.reasonRetry == "ReqEditionNotPossible"
                            ) {
                                conditionalInputs.value.push({
                                    name: "edition",
                                    type: "text",
                                    toolTip: $__(
                                        "Specify which edition(s) are available, separated by comma ','"
                                    ),
                                    label: $__("Edition(s)"),
                                    required: true,
                                    placeholder: "14,15",
                                });
                            } else if (
                                resource.reasonRetry == "ReqFormatNotPossible"
                            ) {
                                conditionalInputs.value.push({
                                    name: "itemFormat",
                                    type: "select",
                                    vselectStyle: {
                                        dropdownMaxHeight: "150px",
                                    },
                                    toolTip: $__(
                                        "Specify which format(s) can be supplied"
                                    ),
                                    allowMultipleChoices: true,
                                    label: $__("Item format(s)"),
                                    required: true,
                                    options: getCodesForElement("itemFormat"),
                                    requiredKey: "value",
                                    selectLabel: "description",
                                });
                            } else if (
                                resource.reasonRetry ==
                                "ReqPayMethodNotSupported"
                            ) {
                                conditionalInputs.value.push({
                                    name: "paymentMethod",
                                    type: "select",
                                    toolTip: $__(
                                        "Specify which payment method(s) can be used"
                                    ),
                                    allowMultipleChoices: true,
                                    label: $__("Payment method(s)"),
                                    required: true,
                                    options:
                                        getCodesForElement("paymentMethod"),
                                    requiredKey: "value",
                                    selectLabel: "description",
                                });
                            } else if (
                                resource.reasonRetry == "ReqServLevelNotSupp"
                            ) {
                                conditionalInputs.value.push({
                                    name: "serviceLevel",
                                    type: "select",
                                    toolTip: $__(
                                        "Select which service level(s) are supported"
                                    ),
                                    allowMultipleChoices: true,
                                    label: $__("Service level(s)"),
                                    required: true,
                                    options: getCodesForElement("serviceLevel"),
                                    requiredKey: "value",
                                    selectLabel: "description",
                                });
                            } else if (
                                resource.reasonRetry == "ReqServTypeNotPossible"
                            ) {
                                conditionalInputs.value.push({
                                    name: "serviceType",
                                    type: "select",
                                    toolTip: $__(
                                        "Select the service type which can be supplied"
                                    ),
                                    label: $__("Service type"),
                                    required: true,
                                    options: [
                                        //TODO: Only show the 2 options that dont match current resource's service_type
                                        {
                                            value: "Copy",
                                            description: $__("Copy"),
                                        },
                                        {
                                            value: "CopyOrLoan",
                                            description: $__("CopyOrLoan"),
                                        },
                                        {
                                            value: "Loan",
                                            description: $__("Loan"),
                                        },
                                    ],
                                    requiredKey: "value",
                                    selectLabel: "description",
                                });
                            }
                            updateConfirmationDialogInputs(
                                getDialogInputs(resource)
                            );
                        },
                        vselectStyle: {
                            dropdownMaxHeight: "150px",
                        },
                        options: getCodesForElement("reasonRetry"),
                        requiredKey: "value",
                        selectLabel: "description",
                    },
                ],
            },
            {
                id: "Unfilled",
                confirm_message: $__(
                    "The supplying library cannot fill the request. The explanation may be provided in the ReasonUnfilled data element"
                ),
                button_label: $__("Unfilled"),
                icon: "fa-ban",
                btn_class: "btn btn-danger",
                next_actions: [],
                action_inputs: [
                    {
                        name: "reasonUnfilled",
                        label: $__("Reason unfilled"),
                        required: true,
                        type: "select",
                        options: getCodesForElement("reasonUnfilled"),
                        requiredKey: "value",
                        selectLabel: "description",
                    },
                ],
            },
            //HoldReturn
            //ReleaseHoldReturn
            {
                id: "CopyCompleted",
                confirm_message: $__(
                    "The supplying library has sent the requested item (this status is used when there is no need to return the item supplied)"
                ),
                button_label: $__("Copy completed"),
                icon: "fa-check",
                btn_class: "btn btn-primary",
                next_actions: [],
                dont_show: iso18626_request =>
                    iso18626_request.service_type === "Loan" ||
                    iso18626_request.hold_id,
                index: -20,
                action_inputs: [],
            },
            {
                id: "LoanCompleted",
                dont_show: resource => !resource.issue_id,
                button_label: $__("Complete loan (Check in)"),
                icon: "fa-download",
                btn_class: "btn btn-primary",
                next_actions: [],
                onClick: resource => {
                    if (!resource.issue_id) return;

                    getCheckout(resource.issue_id).then(
                        result => {
                            const item_barcode = result.item.external_id;
                            performCheckin(item_barcode);
                        },
                        error => {
                            setMessage(
                                $__("Error fetching checkout details"),
                                false
                            );
                        }
                    );
                },
            },
            {
                id: "CompletedWithoutReturn",
                confirm_message: $__(
                    "The supplying library has closed the request without the return of supplied item, e.g. because of loss or damage"
                ),
                button_label: $__("Complete without return"),
                icon: "fa-check",
                btn_class: "btn btn-primary",
                next_actions: [],
                action_inputs: [],
            },
            {
                id: "Cancelled",
                confirm_message: $__(
                    "You are responding to this request's cancellation action (as indicated by the requesting library)"
                ),
                button_label: $__("Cancel"),
                icon: "fa-xmark",
                btn_class: "btn btn-danger",
                next_actions: [],
                action_inputs: [
                    {
                        name: "answerYesNo",
                        type: "boolean",
                        label: $__("Can cancel?"),
                        value: true,
                    },
                ],
                dont_show: iso18626_request =>
                    iso18626_request.pending_requesting_agency_action !==
                    "Cancel",
            },
        ]);

        const statusToUpdate = ref({});
        const action = ref();

        const progressRequest = (actionClicked, iso18626_request) => {
            conditionalInputs.value = [];
            statusToUpdate.value = statuses.value.find(
                status => status.id === actionClicked
            );
            action.value = actionClicked;
            setConfirmationDialog(
                {
                    size: "modal-lg",
                    title: $__(
                        "Update this request's status to <strong>%s</strong>?"
                    ).format(actionClicked),
                    message: statusToUpdate.value.confirm_message,
                    accept_label: $__("Confirm"),
                    cancel_label: $__("Cancel"),
                    inputs: getDialogInputs(),
                },
                (callback_result, inputFields) => {
                    const client = APIClient.ill.supplying;
                    inputFields.answerYesNo =
                        inputFields.answerYesNo === true
                            ? "Y"
                            : inputFields.answerYesNo === false
                              ? "N"
                              : undefined;

                    isActionPending.value = true;
                    submitting();
                    client
                        .patch(
                            inputFields,
                            iso18626_request.iso18626_request_id
                        )
                        .then(
                            success => {
                                isActionPending.value = false;
                                submitted();
                                for (const key in success) {
                                    if (iso18626_request.hasOwnProperty(key)) {
                                        iso18626_request[key] = success[key];
                                    }
                                }
                                setMessage(
                                    $__("ISO18626 request #%s updated").format(
                                        iso18626_request.iso18626_request_id
                                    ),
                                    true
                                );
                                baseResource.refreshTemplateState();
                            },
                            error => {
                                isActionPending.value = false;
                                submitted();
                            }
                        );
                }
            );
        };

        const getDialogInputs = inputValues => {
            if (inputValues && statusToUpdate.value.action_inputs) {
                for (const actionInput of statusToUpdate.value.action_inputs) {
                    if (
                        inputValues &&
                        inputValues.hasOwnProperty(actionInput.name)
                    ) {
                        actionInput.value = inputValues[actionInput.name];
                    }
                }
            }

            if (inputValues && conditionalInputs.value) {
                for (const conditionalInput of conditionalInputs.value) {
                    if (
                        inputValues &&
                        inputValues.hasOwnProperty(conditionalInput.name)
                    ) {
                        conditionalInput.value =
                            inputValues[conditionalInput.name];
                    }
                }
            }

            return [
                ...(statusToUpdate.value.action_inputs
                    ? statusToUpdate.value.action_inputs
                    : []),
                ...(conditionalInputs.value ? conditionalInputs.value : []),
                {
                    name: "messageInfoNote",
                    type: "textarea",
                    textAreaRows: 7,
                    label: $__("Message note"),
                    placeholder: $__(
                        "Note to be sent to the requesting agency"
                    ),
                    value:
                        inputValues &&
                        inputValues.hasOwnProperty("messageInfoNote")
                            ? inputValues.messageInfoNote
                            : "",
                    required: false,
                },
                {
                    name: "status",
                    type: "hidden",
                    value: action.value,
                },
            ];
        };

        const additionalToolbarButtons = resource => {
            const show_buttons = [];
            const currentStatus = statuses.value.find(
                status => status.id === resource.status
            );
            if (currentStatus) {
                currentStatus.next_actions.forEach(nextStatus => {
                    const nextStatusDef = statuses.value.find(
                        status => status.id === nextStatus
                    );

                    if (
                        nextStatusDef.dont_show &&
                        nextStatusDef.dont_show(resource)
                    ) {
                        return;
                    }

                    show_buttons.push({
                        cssClass: `${nextStatusDef.btn_class || "btn btn-default"}${isActionPending.value ? " disabled" : ""}`,
                        title:
                            typeof nextStatusDef.button_label === "function"
                                ? nextStatusDef.button_label(resource)
                                : nextStatusDef.button_label,
                        icon:
                            typeof nextStatusDef.icon === "function"
                                ? nextStatusDef.icon(resource)
                                : nextStatusDef.icon,
                        index: nextStatusDef.index,
                        onClick: nextStatusDef.onClick
                            ? () => {
                                  if (!isActionPending.value)
                                      nextStatusDef.onClick(resource);
                              }
                            : () => {
                                  if (!isActionPending.value)
                                      progressRequest(
                                          nextStatusDef.id,
                                          resource
                                      );
                              },
                    });
                });
            }

            return {
                show: show_buttons,
            };
        };

        const defaultToolbarButtons = () => {
            return {
                list: [],
                show: [],
            };
        };

        const performCheckout = params => {
            const url = "/cgi-bin/koha/circ/circulation.pl";
            const csrfMeta = document.querySelector('meta[name="csrf-token"]');
            params.csrf_token = csrfMeta
                ? csrfMeta.getAttribute("content")
                : "";
            params.op = "cud-checkout";

            const form = document.createElement("form");
            form.method = "POST";
            form.action = url;

            for (const key in params) {
                if (params.hasOwnProperty(key)) {
                    const hiddenField = document.createElement("input");
                    hiddenField.type = "hidden";
                    hiddenField.name = key;
                    hiddenField.value = params[key];
                    form.appendChild(hiddenField);
                }
            }

            document.body.appendChild(form);
            form.submit();
        };

        const getCheckinParams = barcode => {
            const csrfMeta = document.querySelector('meta[name="csrf-token"]');
            return {
                url: "/cgi-bin/koha/circ/returns.pl",
                params: {
                    barcode: barcode,
                    op: "cud-checkin",
                    csrf_token: csrfMeta
                        ? csrfMeta.getAttribute("content")
                        : "",
                },
            };
        };

        const performCheckin = barcode => {
            if (!barcode) return;
            const { url, params } = getCheckinParams(barcode);

            const form = document.createElement("form");
            form.method = "POST";
            form.action = url;

            Object.keys(params).forEach(key => {
                const input = document.createElement("input");
                input.type = "hidden";
                input.name = key;
                input.value = params[key];
                form.appendChild(input);
            });

            document.body.appendChild(form);
            form.submit();
        };

        const renderCheckinForm = barcode => {
            if (!barcode) return `<em>${$__("No barcode")}</em>`;
            const { url, params } = getCheckinParams(barcode);

            // Build the hidden inputs dynamically from the same params object
            const inputs = Object.entries(params)
                .map(
                    ([name, value]) =>
                        `<input type="hidden" name="${name}" value="${value}" />`
                )
                .join("");

            return `
                <form method="POST" action="${url}" style="display:inline;">
                    ${inputs}
                    <button type="submit" class="btn btn-default btn-sm">
                        <i class="fa fa-download"></i> ${$__("Check-in")}
                    </button>
                </form>
            `;
        };

        const baseResource = useBaseResource({
            resourceName: "iso18626_request",
            nameAttr: "iso18626_request_id",
            idAttr: "iso18626_request_id",
            components: {
                show: "SupplyingShow",
                list: "SupplyingList",
            },
            apiClient: APIClient.ill.supplying,
            additionalToolbarButtons,
            defaultToolbarButtons,
            i18n: {
                deleteConfirmationMessage: $__(
                    "Are you sure you want to remove this supplying ILL?"
                ),
                deleteSuccessMessage: $__("Supplying ILL %s deleted"),
                displayName: $__("Supplying ILL"),
                editLabel: $__("Edit supplying ILL #%s"),
                emptyListMessage: $__("There are no supplying ILLs defined"),
                newLabel: $__("New supplying ILL"),
            },
            table: {
                resourceTableUrl:
                    APIClient.ill.httpClient._baseURL + "iso18626_requests",
            },
            showGroupsDisplayMode: "splitScreen",
            splitScreenGroupings: [
                { name: $__("Request details"), pane: 1 },
                { name: $__("ISO18626 Messages"), pane: 1 },
                { name: $__("Circulation information"), pane: 2 },
                { name: $__("Specified by the requesting agency"), pane: 2 },
            ],
            resourceAttrs: [
                {
                    name: "iso18626_request_id",
                    label: $__("Supplying Agency Request ID"),
                    type: "text",
                    hideIn: ["Form"],
                    group: $__("Request details"),
                },
                {
                    name: "iso18626_requesting_agency_id",
                    label: $__("Requesting Agency"),
                    type: "relationshipSelect",
                    showElement: {
                        type: "text",
                        value: "requesting_agency.name",
                        link: {
                            href: "/cgi-bin/koha/ill/iso18626_requesting_agencies",
                            slug: "iso18626_requesting_agency_id",
                        },
                    },
                    relationshipAPIClient: APIClient.ill.requesting_agencies,
                    relationshipOptionLabelAttr: "name",
                    relationshipRequiredKey: "iso18626_requesting_agency_id",
                    group: $__("Request details"),
                },
                {
                    name: "status",
                    label: $__("Status"),
                    type: "text",
                    hideIn: ["Form"],
                    group: $__("Request details"),
                },
                {
                    name: "service_type",
                    label: $__("Service type"),
                    type: "text",
                    hideIn: ["Form"],
                    group: $__("Specified by the requesting agency"),
                },
                {
                    name: "pending_requesting_agency_action",
                    label: $__("Requesting agency has requested"),
                    type: "text",
                    hideIn: ["Form", "List"],
                    group: $__("Specified by the requesting agency"),
                    format: value => (value ? value : $__("N/A")),
                },
                {
                    name: "created_on",
                    label: $__("Created on"),
                    type: "date",
                    hideIn: ["Form"],
                    group: $__("Request details"),
                },
                {
                    name: "updated_on",
                    label: $__("Updated on"),
                    type: "date",
                    hideIn: ["Form"],
                    group: $__("Request details"),
                },
                {
                    name: "requestingAgencyRequestId",
                    label: $__("Requesting Agency Request ID"),
                    type: "text",
                    hideIn: ["List", "Form"],
                    group: $__("Request details"),
                },
                {
                    name: "biblio_id",
                    label: $__("Bibliographic record"),
                    type: "text",
                    hideIn: ["List", "Form"],
                    showElement: {
                        value: "biblio_id",
                        link: {
                            href: "/cgi-bin/koha/catalogue/detail.pl",
                            params: {
                                biblionumber: "biblio_id",
                            },
                        },
                    },
                    group: $__("Request details"),
                },
                {
                    name: "hold_id",
                    label: $__("Active hold on biblio"),
                    type: "text",
                    format: value => (value ? $__("Yes") : $__("No")),
                    hideIn: ["List", "Form"],
                    group: $__("Circulation information"),
                },
                {
                    name: "hold",
                    label: $__("Active hold on item"),
                    type: "text",
                    hideIn: ["List", "Form"],
                    format: value => (value?.item_id ? $__("Yes") : $__("No")),
                    group: $__("Circulation information"),
                },
                {
                    name: "issue_id",
                    label: $__("Active checkout"),
                    type: "text",
                    hideIn: ["List", "Form"],
                    format: value => (value ? $__("Yes") : $__("No")),
                    group: $__("Circulation information"),
                },
                {
                    group: $__("ISO18626 Messages"),
                    name: "messages",
                    label: "",
                    type: "relationshipWidget",
                    hideIn: ["List"],
                    type: "component",
                    columnData: "messages",
                    hidden: iso18626_request => 1,
                    showElement: {
                        componentPath:
                            "@koha-vue/components/ILL/ISO18626MessageDisplay.vue",
                        componentProps: {
                            iso18626_request: {
                                type: "resource",
                                value: null,
                            },
                        },
                    },
                },
            ],
            moduleStore: "ILLStore",
            props: props,
        });

        const tableOptions = {
            url: () => tableUrl(),
            options: { embed: "requesting_agency,messages" },
            table_settings: supplying_ill_table_settings,
            add_filters: true,
            filters_options: {
                status: statuses.value
                    .map(status => ({
                        _id: status.id,
                        _str: $__(status.id),
                    }))
                    .sort((a, b) => a._str.localeCompare(b._str)),
                service_type: [
                    {
                        _id: "Copy",
                        _str: $__("Copy"),
                    },
                    {
                        _id: "CopyOrLoan",
                        _str: $__("CopyOrLoan"),
                    },
                    {
                        _id: "Loan",
                        _str: $__("Loan"),
                    },
                ],
            },
            actions: {
                0: ["show"],
                1: [],
                "-1": [
                    {
                        receive: {
                            text: $__("Manage request"),
                            icon: "fa fa-pencil",
                            should_display: row => 1,
                            callback: ({ iso18626_request_id }, dt, event) => {
                                event.preventDefault();
                                router.push({
                                    name: "SupplyingShow",
                                    params: {
                                        iso18626_request_id:
                                            iso18626_request_id,
                                    },
                                });
                            },
                        },
                    },
                ],
            },
        };

        const getItem = async item_id => {
            const client = APIClient.item;
            return await client.items.get(item_id).then(
                result => {
                    return result;
                },
                error => {}
            );
        };

        const getPatron = async patron_id => {
            const client = APIClient.patron;
            return await client.patrons.get(patron_id).then(
                result => {
                    return result;
                },
                error => {}
            );
        };

        const getBiblioItems = async biblio_id => {
            const client = APIClient.biblio;
            return await client.items.get(biblio_id).then(
                result => {
                    return result;
                },
                error => {}
            );
        };

        const getCheckout = async checkout_id => {
            const client = APIClient.checkout;
            return await client.checkouts.get(checkout_id).then(
                result => {
                    return result;
                },
                error => {}
            );
        };

        const afterResourceFetch = (componentData, resource, caller) => {
            if (caller === "show") {
                resource.created_on = new Date(
                    resource.created_on
                ).toLocaleString();
                resource.updated_on = new Date(
                    resource.updated_on
                ).toLocaleString();
            }
        };

        const onFormSave = (e, supplyingILLToSave) => {
            e.preventDefault();
            // Nothing to do here
        };
        const tableUrl = filters => {
            return baseResource.getResourceTableUrl();
        };

        return {
            ...baseResource,
            tableOptions,
            onFormSave,
            tableUrl,
            afterResourceFetch,
        };
    },
    emits: ["select-resource"],
    name: "SupplyingResource",
    components: {
        BaseResource,
    },
};
</script>
