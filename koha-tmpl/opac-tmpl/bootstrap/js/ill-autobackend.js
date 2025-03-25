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
                _addSuccessMessage(auto_backend.name);
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
        });
        _addBackendPlaceholderEl("Standard");
        _addBackendOption("Standard");
    }

    function _addSuccessMessage(auto_backend_name) {
        _removeVerifyingMessage(auto_backend_name);
        $(auto_ill_el + " > #backend-" + auto_backend_name).append(
            '<span class="text-success"><i class="fa-solid fa-check"></i> ' +
                __("Available.").format(auto_backend_name) +
                "</span>"
        );
    }

    function _addErrorMessage(auto_backend_name, message) {
        _removeVerifyingMessage(auto_backend_name);
        $(auto_ill_el + " > #backend-" + auto_backend_name).append(
            '<span class="text-danger"> <i class="fa-solid fa-xmark"></i> ' +
                __("Not readily available:").format(auto_backend_name) +
                " " +
                message +
                "</span>"
        );
    }

    function _addBackendOption(auto_backend_name) {
        $(auto_ill_el + " > #backend-" + auto_backend_name).append(
            ' <input type="radio" id="' +
                auto_backend_name +
                '" name="backend" value="' +
                auto_backend_name +
                '">' +
                ' <label for="' +
                auto_backend_name +
                '" class="radio">' +
                auto_backend_name +
                "</label> "
        );
    }

    function _addVerifyingMessage(auto_backend_name) {
        $(auto_ill_el + " > #backend-" + auto_backend_name).append(
            '<span id="verifying-availabilty" class="text-info"><i id="issues-table-load-delay-spinner" class="fa fa-spinner fa-pulse fa-fw"></i> ' +
                __("Verifying availability...").format(auto_backend_name) +
                "</span>"
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
        ).prop("checked", true);
        $("#confirmautoill-form").submit();
    }

    function _addBackendPlaceholderEl(auto_backend_name) {
        $(auto_ill_el)
            .append('<div id="backend-' + auto_backend_name + '">')
            .hide();
    }

    function confirmAutoInit() {
        $('#confirmautoill-form .action input[name="backend"]').remove();
        $(auto_ill_message_el).html(
            '<span id="verifying-availabilty" class="text-info"><i id="issues-table-load-delay-spinner" class="fa fa-spinner fa-pulse fa-fw"></i> ' +
                __("Placing your request...") +
                "</span>"
        );
    }
});
