/* global __ $date $datetime dayjs flatpickr bookings_table timeline */

(() => {
    let extendPicker;

    document
        .getElementById("extendBookingModal")
        ?.addEventListener("show.bs.modal", handleShowBsModal);
    document
        .getElementById("extendBookingModal")
        ?.addEventListener("hide.bs.modal", handleHideBsModal);
    document
        .getElementById("extendBookingForm")
        ?.addEventListener("submit", handleSubmit);

    function handleShowBsModal(e) {
        const button = e.relatedTarget;
        if (!button) {
            return;
        }

        const bookingId = button.dataset.booking;
        const checkoutId = button.dataset.checkout_id;
        const itemId = button.dataset.item_id;
        const endDate = button.dataset.end_date;
        const dueDate = button.dataset.due_date;

        document.getElementById("extend_booking_id").value = bookingId;
        document.getElementById("extend_checkout_id").value = checkoutId;
        document.getElementById("extend_current_end_date").textContent =
            $date(endDate);
        document.getElementById("extend_current_due_date").textContent = dueDate
            ? $datetime(dueDate)
            : __("Not found");

        // Block dates where another new or issued booking exists for this
        // item, and cap the selectable range at the earliest subsequent
        // booking start date
        const query = {
            "me.item_id": itemId,
            "me.status": { "-in": ["new", "issued"] },
            "me.booking_id": { "!=": bookingId },
        };
        fetch(
            "/api/v1/bookings?_per_page=-1&q=" +
                encodeURIComponent(JSON.stringify(query))
        )
            .then(response => (response.ok ? response.json() : []))
            .then(bookings => {
                const disable = bookings.map(booking => ({
                    from: dayjs(booking.start_date).startOf("day").toDate(),
                    to: dayjs(booking.end_date).endOf("day").toDate(),
                }));

                let maxDate;
                bookings.forEach(booking => {
                    const bookingStart = dayjs(booking.start_date);
                    if (
                        bookingStart.isAfter(dayjs(endDate)) &&
                        (!maxDate || bookingStart.isBefore(maxDate))
                    ) {
                        maxDate = bookingStart;
                    }
                });

                extendPicker = flatpickr("#extend_new_end_date", {
                    minDate: dayjs().startOf("day").toDate(),
                    ...(maxDate
                        ? {
                              maxDate: maxDate
                                  .subtract(1, "day")
                                  .endOf("day")
                                  .toDate(),
                          }
                        : {}),
                    disable,
                });
            });
    }

    function handleHideBsModal() {
        extendPicker?.destroy();
        extendPicker = null;
        document.getElementById("extend_booking_result").innerHTML = "";
        document.getElementById("extendBookingForm").reset();
    }

    function showError(message) {
        document.getElementById("extend_booking_result").innerHTML = `
            <div class="alert alert-danger">${message}</div>
        `;
    }

    async function handleSubmit(e) {
        e.preventDefault();

        const checkoutId = document.getElementById("extend_checkout_id").value;
        const newEndDate = extendPicker?.selectedDates[0];
        if (!checkoutId || !newEndDate) {
            showError(__("Please select a new end date"));
            return;
        }

        const dueDate = dayjs(newEndDate).endOf("day");

        // The extension is a staff authorised renewal of the linked
        // checkout; the booking end_date is kept in sync server-side
        const response = await fetch(
            `/api/v1/checkouts/${checkoutId}/renewal`,
            {
                method: "POST",
                body: JSON.stringify({ due_date: dueDate.toISOString() }),
                headers: {
                    "Content-Type": "application/json",
                    "x-koha-override": "renewal_limit",
                },
            }
        ).catch(() => null);

        if (!response || !response.ok) {
            const errorMessages = {
                booked: __(
                    "The new end date would conflict with another booking for this item"
                ),
                too_many: __(
                    "Renewal count limit reached and renewal limit overrides are disabled"
                ),
            };
            const result = response
                ? await response.json().catch(() => null)
                : null;
            showError(
                (result && errorMessages[result.error_code]) ||
                    (result && result.error) ||
                    __("Failure: the booking could not be extended")
            );
            return;
        }

        const checkout = await response.json();

        bookings_table?.api().ajax.reload();
        try {
            timeline?.itemsData.update({
                id: Number(document.getElementById("extend_booking_id").value),
                end: checkout.due_date,
            });
        } catch {
            console.info("Timeline component not found. Skipping...");
        }

        $("#extendBookingModal").modal("hide");
    }
})();
