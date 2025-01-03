$(document).ready(function () {
    let auto_ill_el = "#confirmautoill-form #autoillbackends";
    let auto_ill_message_el = "#confirmautoill-form #autoillbackend-message";

    confirmAutoInit();
    getBackendsAvailability(auto_backends, metadata);

    /**
     * Retrieves the backend availability for a given auto backend and metadata.
     *
     * @param {Object} auto_backend - The auto backend object.
     * @param {string} metadata - The metadata string.
     * @return {Promise} A Promise that resolves to the JSON response.
     */
    async function getBackendAvailability(auto_backend, metadata) {
        return $.ajax({
            url: auto_backend.endpoint + metadata,
            type: "GET",
            dataType: "json",
            beforeSend: function () {
                _addBackendPlaceholderEl(auto_backend.name);
                _addBackendOption(auto_backend.name);
                _addVerifyingMessage(auto_backend.name);
                auto_backend.available = 0;
            },
            success: function (data) {
                _addSuccessMessage(auto_backend.name, data);
                auto_backend.available = 1;
            },
            error: function (request, textstatus) {
                if (textstatus === "timeout") {
                    _addErrorMessage(
                        auto_backend.name,
                        __("Verification timed out.")
                    );
                } else {
                    let message = __("Error");
                    if (request.hasOwnProperty("responseJSON")) {
                        if (request.responseJSON.error) {
                            message = request.responseJSON.error;
                        } else if (request.responseJSON.errors) {
                            message = request.responseJSON.errors
                                .map(error => error.message)
                                .join(", ");
                        }
                    }
                    _addErrorMessage(auto_backend.name, message);
                }
            },
            timeout: 10000,
        });
    }

    /**
     * Asynchronously checks the availability of multiple auto backends.
     *
     * @param {Array} auto_backends - An array of auto backends to check availability for.
     * @param {Object} metadata - Additional metadata for the availability check.
     * @return {void}
     */
    function getBackendsAvailability(auto_backends, metadata) {
        let promises = [];
        for (const auto_backend of auto_backends) {
            const prom = getBackendAvailability(auto_backend, metadata);
            promises.push(prom);
        }
        Promise.allSettled(promises).then(() => {
            let auto_backend = auto_backends.find(backend => backend.available);
            if (typeof auto_backend === "undefined") {
                _setAutoBackend("Standard");
            } else {
                _setAutoBackend(auto_backend.name);
            }
            $('#confirmautoill-form .action input[type="submit"]').prop(
                "disabled",
                false
            );
            $("#confirm-auto-migrate").removeClass("disabled");
        });
        _addBackendPlaceholderEl("Standard");
        _addBackendOption("Standard");
    }

    function _addSuccessMessage(auto_backend_name, data) {
        _removeVerifyingMessage(auto_backend_name);
        $(
            auto_ill_el + " > #backend-" + auto_backend_name + " #backendcol"
        ).append(
            '<div class="text-success mb-2"><i class="fa-solid fa-check"></i> ' +
                "<strong>" +
                __("Available.") +
                "</strong><br>" +
                data.success +
                "</div>"
        );
    }

    function _addErrorMessage(auto_backend_name, message) {
        _removeVerifyingMessage(auto_backend_name);
        $(
            auto_ill_el + " > #backend-" + auto_backend_name + " #backendcol"
        ).append(
            '<div class="text-danger mb-2"> <i class="fa-solid fa-xmark"></i> ' +
                "<strong>" +
                __("Not readily available:") +
                "</strong><br>" +
                message +
                "</div>"
        );
        $(
            auto_ill_el +
                " > #backend-" +
                auto_backend_name +
                ' input[type="radio"]'
        ).prop("disabled", true);
    }

    function _addBackendOption(auto_backend_name) {
        $(auto_ill_el + " > #backend-" + auto_backend_name).append(
            `<label style="text-align:left; width:100%;font-weight:normal;" for="${auto_backend_name}">
                <li class="list-group-item">
                    <div class="row">
                        <div class="col-sm-auto">
                            <input id="${auto_backend_name}" type="radio" name="backend" value="${auto_backend_name}" aria-label="${auto_backend_name}">
                        </div>
                        <div id="backendcol" class="col">
                            <div class="mb-2 fs-3"><strong>${auto_backend_name}</strong></div>
                        </div>
                    </div>
                </li>
            </label>`
        );
    }

    function _addVerifyingMessage(auto_backend_name) {
        $(
            auto_ill_el + " > #backend-" + auto_backend_name + " #backendcol"
        ).append(
            '<div id="verifying-availabilty" class="text-info mb-2"><i id="issues-table-load-delay-spinner" class="fa fa-spinner fa-pulse fa-fw"></i> ' +
                __("Verifying availability...") +
                "</div>"
        );
    }
    function _removeVerifyingMessage(auto_backend_name) {
        $(
            auto_ill_el +
                " #backend-" +
                auto_backend_name +
                " #verifying-availabilty"
        ).remove();
    }

    function _setAutoBackend(auto_backend_name) {
        $(
            '#confirmautoill-form #autoillbackends input[id="' +
                auto_backend_name +
                '"]'
        )
            .prop("checked", true)
            .trigger("change");
        $(auto_ill_message_el).html(
            __(
                "The recommended backend for your request is <strong>%s</strong>."
            ).format(auto_backend_name)
        );
    }

    function _addBackendPlaceholderEl(auto_backend_name) {
        $(auto_ill_el).append('<div id="backend-' + auto_backend_name + '">');
    }

    function confirmAutoInit() {
        $('#confirmautoill-form .action input[name="backend"]').remove();
        $('#confirmautoill-form .action input[type="submit"]').prop(
            "disabled",
            true
        );
        $(auto_ill_message_el).html(__("Fetching backends availability..."));
    }

    $("#confirmautoill-form").on(
        "change",
        'input[name="backend"]',
        function () {
            $('input[name="backend"]')
                .closest(".list-group-item")
                .removeClass("bg-success")
                .css({
                    "background-color": "",
                    border: "",
                });
            $(this).closest(".list-group-item").css({
                "background-color": "rgba(0, 128, 0, 0.1)",
                border: "1px solid rgba(0, 128, 0, 0.7)",
            });
        }
    );

    $("#confirm-auto-migrate").on("click", function () {
        let backend = $('input[name="backend"]:checked').val();
        let requestId = $(this).data("illrequest_id");
        let url = `/cgi-bin/koha/ill/ill-requests.pl?op=migrate&illrequest_id=${encodeURIComponent(requestId)}&backend=${encodeURIComponent(backend)}`;
        window.location.href = url;
    });
});
