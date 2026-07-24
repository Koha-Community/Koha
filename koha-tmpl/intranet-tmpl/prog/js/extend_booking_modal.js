/* global __ $date $datetime $timezone $toDisplayDate dayjs flatpickr bookings_table timeline */

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

        // Work in the library's configured timezone throughout so the day
        // boundaries match the dates staff see (see Bug 42868); an extension
        // must end after the current due date, and an overdue checkout can
        // still be extended from today onwards
        const libraryTz = $timezone();
        const today = dayjs().tz(libraryTz).startOf("day");
        const dueFloor = dueDate
            ? dayjs(dueDate).tz(libraryTz).add(1, "day").startOf("day")
            : today;
        const minDate = dueFloor.isAfter(today) ? dueFloor : today;

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
                    from: $toDisplayDate(
                        dayjs(booking.start_date).tz(libraryTz).startOf("day")
                    ),
                    to: $toDisplayDate(
                        dayjs(booking.end_date).tz(libraryTz).endOf("day")
                    ),
                }));

                let maxDate;
                bookings.forEach(booking => {
                    const bookingStart = dayjs(booking.start_date).tz(
                        libraryTz
                    );
                    if (
                        bookingStart.isAfter(dayjs(endDate).tz(libraryTz)) &&
                        (!maxDate || bookingStart.isBefore(maxDate))
                    ) {
                        maxDate = bookingStart;
                    }
                });

                extendPicker = flatpickr("#extend_new_end_date", {
                    minDate: $toDisplayDate(minDate),
                    ...(maxDate
                        ? {
                              maxDate: $toDisplayDate(
                                  maxDate.subtract(1, "day").endOf("day")
                              ),
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

        // Anchor the selected day in the library's timezone so the booking
        // ends at the end of that day as the library sees it (see Bug 42868)
        const dueDate = dayjs
            .tz(dayjs(newEndDate).format("YYYY-MM-DD"), $timezone())
            .endOf("day");

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
