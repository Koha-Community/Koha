/* global __ */

(() => {
    const island = document.querySelector("booking-modal");
    if (!island) return;

    /** @type {Promise<Element|null>} Booking island after custom-element registration. */
    const islandReady = (async () => {
        await customElements.whenDefined("booking-modal");
        return document.querySelector("booking-modal");
    })();

    /**
     * Render patron content for the bookings timeline.
     *
     * @param {Object|null} bookingPatron
     * @returns {string}
     */
    const renderPatronContent = bookingPatron => {
        try {
            const patronRenderer = window.$patron_to_html;
            if (typeof patronRenderer === "function" && bookingPatron) {
                return patronRenderer(bookingPatron, {
                    display_cardnumber: true,
                    url: true,
                });
            }
        } catch (error) {
            console.error("Failed to render patron content", {
                error,
                bookingPatron,
            });
        }

        if (!bookingPatron) return "";
        const fallbackLabel =
            bookingPatron.label ||
            [
                bookingPatron.surname,
                bookingPatron.firstname,
                bookingPatron.cardnumber ? `(${bookingPatron.cardnumber})` : "",
            ]
                .filter(Boolean)
                .join(" ")
                .trim();
        const fallback = document.createElement("span");
        fallback.textContent = fallbackLabel;
        return fallback.outerHTML;
    };

    /**
     * Update the bookings timeline when the current page provides one.
     *
     * @param {Object} booking
     * @param {Object|null} bookingPatron
     * @param {boolean} isUpdate
     * @returns {void}
     */
    const updateTimeline = (booking, bookingPatron, isUpdate) => {
        const timeline = window.timeline;
        if (!timeline) return;

        try {
            const dayjs = window.dayjs;
            const timezone =
                typeof window.$timezone === "function"
                    ? window.$timezone()
                    : null;
            const start =
                timezone && dayjs.tz
                    ? dayjs(booking.start_date).tz(timezone)
                    : dayjs(booking.start_date);
            const end =
                timezone && dayjs.tz
                    ? dayjs(booking.end_date).tz(timezone)
                    : dayjs(booking.end_date);
            /**
             * Convert a timeline date through the page display helper.
             *
             * @param {Object} date Day.js-compatible date.
             * @returns {Date|string} Timeline display date.
             */
            const toDisplayDate = date =>
                typeof window.$toDisplayDate === "function"
                    ? window.$toDisplayDate(date)
                    : date.toDate();
            const itemData = {
                id: booking.booking_id,
                booking: booking.booking_id,
                patron: booking.patron_id,
                pickup_library: booking.pickup_library_id,
                start: toDisplayDate(start),
                end: toDisplayDate(end),
                content: renderPatronContent(bookingPatron),
                editable: { remove: true, updateTime: true },
                type: "range",
                group: booking.item_id || 0,
            };

            if (isUpdate) {
                timeline.itemsData.update(itemData);
            } else {
                timeline.itemsData.add(itemData);
            }
            timeline.focus(booking.booking_id);
        } catch (error) {
            console.error("Failed to update timeline", { error, booking });
        }
    };

    /**
     * Reload the bookings table when the current page provides one.
     *
     * @returns {void}
     */
    const updateBookingsTable = () => {
        try {
            window.bookings_table?.api().ajax.reload();
        } catch (error) {
            console.error("Failed to update bookings table", { error });
        }
    };

    /**
     * Increment active-booking counts after a booking is created.
     *
     * @param {boolean} isUpdate
     * @returns {void}
     */
    const updateBookingCounts = isUpdate => {
        if (isUpdate) return;

        try {
            document.querySelectorAll(".bookings_count").forEach(element => {
                const current = element.textContent.match(/(\d+)/);
                if (!current) return;
                element.textContent = element.textContent.replace(
                    /(\d+)/,
                    String(parseInt(current[1], 10) + 1)
                );
            });
        } catch (error) {
            console.error("Failed to update booking counts", { error });
        }
    };

    /**
     * Show the page-owned success message for a saved booking.
     *
     * @param {boolean} isUpdate
     * @returns {void}
     */
    const showTransientSuccess = isUpdate => {
        try {
            const result = document.querySelector("#transient_result");
            if (!result) return;

            const alert = document.createElement("div");
            alert.className = "alert alert-success alert-dismissible fade show";
            alert.setAttribute("role", "alert");
            alert.textContent = isUpdate
                ? __("Booking successfully updated")
                : __("Booking successfully placed");

            const closeButton = document.createElement("button");
            closeButton.type = "button";
            closeButton.className = "btn-close";
            closeButton.setAttribute("data-bs-dismiss", "alert");
            closeButton.setAttribute("aria-label", __("Close"));
            alert.appendChild(closeButton);
            result.replaceChildren(alert);
        } catch (error) {
            console.error("Failed to show transient success", { error });
        }
    };

    /**
     * Synchronize page-owned booking displays after the island saves.
     *
     * @param {CustomEvent} event
     * @returns {void}
     */
    const handleBookingSaved = event => {
        const [detail] = event.detail || [];
        if (!detail?.booking) return;

        updateTimeline(detail.booking, detail.bookingPatron, detail.isUpdate);
        updateBookingsTable();
        updateBookingCounts(detail.isUpdate);
        showTransientSuccess(detail.isUpdate);
    };

    /**
     * Map booking prefill values onto the island element's camelCase
     * properties; accepts both the trigger-dataset naming (booking,
     * itemnumber, pickup_library, ...) and camelCase prop names.
     * @param {HTMLElement|null} targetIsland - The booking-modal element
     * @param {Object} source - Trigger dataset or explicit prop object
     * @returns {void}
     */
    const normalizeProps = (targetIsland, source) => {
        if (!targetIsland || !source) return;

        const bookingId = source.booking ?? source.bookingId ?? null;
        const itemId = source.itemnumber ?? source.itemId ?? null;
        const patronId = source.patron ?? source.patronId ?? null;
        const pickupLibraryId =
            source.pickup_library ?? source.pickupLibraryId ?? null;
        const startDate = source.start_date ?? source.startDate ?? null;
        const endDate = source.end_date ?? source.endDate ?? null;
        const itemtypeId =
            source.item_type_id ??
            source.itemtypeId ??
            source.itemTypeId ??
            null;
        const biblionumber =
            source.biblionumber ?? source.biblio_id ?? source.biblioId;

        targetIsland.bookingId = bookingId;
        targetIsland.itemId = itemId;
        targetIsland.patronId = patronId;
        targetIsland.pickupLibraryId = pickupLibraryId;
        targetIsland.startDate = startDate;
        targetIsland.endDate = endDate;
        targetIsland.itemtypeId = itemtypeId;

        if (biblionumber) {
            targetIsland.biblionumber = biblionumber;
        }
    };

    /**
     * Open the booking modal with the passed prefill values; exposed as
     * window.openBookingModal for callers outside the island.
     * @param {Object} [props] - Booking prefill values (see normalizeProps)
     * @returns {Promise<void>}
     */
    const openModal = async props => {
        const targetIsland = await islandReady;
        if (!targetIsland) return;
        normalizeProps(targetIsland, props || {});
        targetIsland.open = true;
    };

    island.addEventListener("close", () => {
        island.open = false;
    });
    island.addEventListener("booking-saved", handleBookingSaved);
    /* This might need to be optimised if we ever
     * run into noticeable lag on click events. */
    document.addEventListener(
        "click",
        e => {
            const trigger = e.target.closest("[data-booking-modal]");
            if (!trigger) return;
            openModal(trigger.dataset);
        },
        { passive: true }
    );

    if (typeof window.openBookingModal !== "function") {
        window.openBookingModal = openModal;
    }
})();
