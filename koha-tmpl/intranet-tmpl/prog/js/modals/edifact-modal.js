// EDIFACT modal JavaScript functionality
// This script handles the EDIFACT message modal interactions
// Include this after the edifact-modal.inc template

/* global __ interface theme */
$(document).ready(function () {
    // Initialize modal elements
    var EDIModal = $("#EDI_modal");
    var EDIModalBody = $("#EDI_modal .modal-body");
    var EDIErrorsModal = $("#EDI_errors_modal");

    // Handle view EDIFACT message button clicks
    $("body").on("click", ".view_edifact_message", function (e) {
        e.preventDefault();
        var message_id = $(this).data("message-id");
        var page =
            "/cgi-bin/koha/acqui/edimsg.pl?id=" +
            encodeURIComponent(message_id);
        EDIModalBody.load(page + " #edimsg");
        EDIModal.modal("show");
    });

    // Handle view_message button clicks (for compatibility with existing code)
    $("body").on("click", ".view_message", function (e) {
        e.preventDefault();
        var page = $(this).attr("href");
        EDIModalBody.load(page + " #edimsg");
        EDIModal.modal("show");
    });

    // Handle modal close button
    EDIModal.on("click", ".btn-close", function (e) {
        e.preventDefault();
        EDIModal.modal("hide");
    });

    // Reset modal content when hidden
    EDIModal.on("hidden.bs.modal", function () {
        EDIModalBody.html(
            "<div id='edi_loading'><img style='display:inline-block' src='" +
                interface +
                "/" +
                theme +
                "/img/spinner-small.gif' alt='' /> Loading</div>"
        );
    });

    // Handle EDIFACT errors modal
    const errorsModal = document.getElementById("EDI_errors_modal");
    if (errorsModal) {
        errorsModal.addEventListener("show.bs.modal", function (event) {
            // Link that triggered the modal
            const link = event.relatedTarget;

            // Extract info from data-bs-* attributes
            const filename = link.getAttribute("data-bs-filename");
            const errors = link.getAttribute("data-bs-errors");

            // Update the modal's title
            const modalTitleSpan = errorsModal.querySelector(
                ".modal-title #EDI_errors_filename"
            );
            modalTitleSpan.textContent = filename;

            // Update the modal's content
            const modalBody = errorsModal.querySelector(".modal-body");
            modalBody.innerHTML = errors;
        });
    }
});
