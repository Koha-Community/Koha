// Follow-up actions require the token returned for them in the checkin's
// action_tokens attribute
const withActionToken = (endpoint, action_token) =>
    `${endpoint}?action_token=${encodeURIComponent(action_token || "")}`;

// The check-in page presents errors itself (in context, translated): the
// thrown error carries the status, the error_code and the response body
const config = { suppressDefaultErrorDialog: true };

export class CheckinAPIClient {
    constructor(HttpClient) {
        this.httpClient = new HttpClient({
            baseURL: "/api/v1/",
        });
    }

    get checkins() {
        return {
            create: (body, params = {}) =>
                this.httpClient.post({
                    endpoint:
                        "checkins" +
                        (params.confirmation
                            ? `?confirmation=${encodeURIComponent(params.confirmation)}`
                            : ""),
                    body,
                    headers: {
                        "x-koha-embed":
                            "item+strings,item.biblio,checkout,checkout.patron,checkout.patron.checkouts+count,hold,hold.patron+strings,hold.patron.notification_summary,transfer,recall,recall.patron+strings,recall.patron.notification_summary",
                        "x-koha-override": "not_issued",
                    },
                    mark_submitting: false,
                    config,
                }),
            confirmHold: (checkin_id, { action_token } = {}) =>
                this.httpClient.post({
                    endpoint: withActionToken(
                        `checkins/${checkin_id}/hold_confirmation`,
                        action_token
                    ),
                    headers: {
                        "x-koha-embed": "item,hold,hold.patron,transfer",
                    },
                    config,
                }),
            cancelHold: (
                checkin_id,
                { reason, forgive_hold_fees, action_token } = {}
            ) =>
                this.httpClient.post({
                    endpoint: withActionToken(
                        `checkins/${checkin_id}/hold_cancellation`,
                        action_token
                    ),
                    body: {
                        ...(reason ? { reason } : {}),
                        ...(forgive_hold_fees
                            ? { forgive_hold_fees: true }
                            : {}),
                    },
                    headers: {
                        "x-koha-embed": "item,hold",
                    },
                    config,
                }),
            confirmTransfer: (
                checkin_id,
                { to_library_id, reason, action_token } = {}
            ) =>
                this.httpClient.post({
                    endpoint: withActionToken(
                        `checkins/${checkin_id}/transfer_confirmation`,
                        action_token
                    ),
                    body: {
                        ...(to_library_id ? { to_library_id } : {}),
                        ...(reason ? { reason } : {}),
                    },
                    headers: {
                        "x-koha-embed": "item,transfer,transfer.to_library",
                    },
                    config,
                }),
            cancelTransfer: (checkin_id, { action_token } = {}) =>
                this.httpClient.post({
                    endpoint: withActionToken(
                        `checkins/${checkin_id}/transfer_cancellation`,
                        action_token
                    ),
                    headers: {
                        "x-koha-embed": "item",
                    },
                    config,
                }),
            confirmRecall: (checkin_id, { action_token } = {}) =>
                this.httpClient.post({
                    endpoint: withActionToken(
                        `checkins/${checkin_id}/recall_confirmation`,
                        action_token
                    ),
                    headers: {
                        "x-koha-embed": "item,recall,recall.patron",
                    },
                    config,
                }),
        };
    }
}

export default CheckinAPIClient;
