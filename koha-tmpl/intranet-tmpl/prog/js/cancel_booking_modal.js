(() => {
    document
        .getElementById("cancelBookingModal")
        ?.addEventListener("show.bs.modal", handleShowBsModal);
    document
        .getElementById("cancelBookingForm")
        ?.addEventListener("submit", handleSubmit);

    async function handleSubmit(e) {
        e.preventDefault();

        const bookingIdInput = document.getElementById("cancel_booking_id");
        if (!bookingIdInput) {
            return;
        }

        const bookingId = bookingIdInput.value;
        if (!bookingId) {
            return;
        }

        let [error, response] = await catchError(
            fetch(`/api/v1/bookings/${bookingId}`, {
                method: "PATCH",
                body: JSON.stringify({ status: "cancelled" }),
                headers: {
                    "Content-Type": "application/json",
                },
            })
        );
        if (error || !response.ok) {
            const alertContainer = document.getElementById(
                "cancel_booking_result"
            );
            alertContainer.outerHTML = `
                <div id="booking_result" class="alert alert-danger">
                    ${__("Failure")}
                </div>
            `;

            return;
        }

        cancel_success = true;
        bookings_table?.api().ajax.reload();
        timeline?.itemsData.remove(Number(booking_id));

        $("#cancelBookingModal").modal("hide");

        const bookingsCount = document.querySelector(".bookings_count");
        if (!bookingsCount) {
            return;
        }

        bookingsCount.innerHTML = parseInt(bookingsCount.innerHTML, 10) - 1;
    }

    function handleShowBsModal(e) {
        const button = e.relatedTarget;
        if (!button) {
            return;
        }

        const booking = button.dataset.booking;
        if (!booking) {
            return;
        }

        const bookingIdInput = document.getElementById("cancel_booking_id");
        if (!bookingIdInput) {
            return;
        }

        bookingIdInput.value = booking;
    }

    function catchError(promise) {
        return promise.then(data => [undefined, data]).catch(error => [error]);
    }
})();
