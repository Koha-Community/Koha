(() => {
    document
        .getElementById("cancelBookingModal")
        ?.addEventListener("show.bs.modal", handleShowBsModal);
    document
        .getElementById("cancelBookingForm")
        ?.addEventListener("submit", handleSubmit);

    document
        .getElementById("cancelBookingModal")
        ?.addEventListener("hide.bs.modal", () => {
            $("#cancellation-reason").comboBox("reset");
        });

    async function handleSubmit(e) {
        e.preventDefault();

        const target = e.target;
        if (!(target instanceof HTMLFormElement)) {
            return;
        }

        const formData = new FormData(target);
        const bookingId = formData.get("booking_id");
        if (!bookingId) {
            return;
        }

        let [error, response] = await catchError(
            fetch(`/api/v1/bookings/${bookingId}`, {
                method: "PATCH",
                body: JSON.stringify({
                    status: "cancelled",
                    cancellation_reason: formData.get("cancellation_reason"),
                }),
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
        try {
            timeline?.itemsData.remove(Number(bookingId));
        } catch {
            console.info("Timeline component not found. Skipping...");
        }

        $("#cancelBookingModal").modal("hide");

        const bookingsCount = document.querySelector(".bookings_count");
        if (!bookingsCount) {
            return;
        }

        bookingsCount.innerHTML = bookingsCount.innerHTML.replace(
            /\d+/,
            match => parseInt(match, 10) - 1
        );
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
