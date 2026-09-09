<template>
    <div ref="rootRef" class="booking-flatpickr-wrapper">
        <input
            id="booking_period"
            ref="inputRef"
            type="text"
            class="booking-flatpickr-input form-control"
            :placeholder="$__('Booking period')"
            required
            aria-required="true"
            :disabled="inputDisabled"
            readonly
        />
        <slot name="clear-button"></slot>
        <slot name="required"></slot>
        <slot name="legend"></slot>
    </div>
</template>

<script setup lang="ts">
import {
    ref,
    shallowRef,
    computed,
    watch,
    onMounted,
    onBeforeUnmount,
} from "vue";
import type { Instance, DayElement } from "flatpickr/dist/types/instance";
import type { Options } from "flatpickr/dist/types/options";
import { $__ } from "@koha-vue/i18n";

type YMD = string;

export interface DisabledSpec {
    reason: string;
    severity?: "hard" | "soft";
}

export interface BookingMarker {
    kind: string;
    className?: string;
    tooltip?: string;
}

export type DisabledInput =
    | Map<YMD, DisabledSpec>
    | ((date: Date) => DisabledSpec | null);
export type SelectedRange = Date[] | null;

interface Viewport {
    year: number;
    month: number;
}

const props = withDefaults(
    defineProps<{
        modelValue?: SelectedRange;
        viewport?: Viewport | null;
        minDate?: Date | string | null;
        disabled?: DisabledInput;
        markersByDate?: Map<YMD, BookingMarker[]>;
        classByDate?: Map<YMD, string>;
        inputDisabled?: boolean;
    }>(),
    {
        modelValue: null,
        viewport: null,
        minDate: null,
        disabled: () => new Map(),
        markersByDate: () => new Map(),
        classByDate: () => new Map(),
        inputDisabled: false,
    }
);

const emit = defineEmits<{
    (e: "update:modelValue", value: SelectedRange): void;
    (e: "update:viewport", value: Viewport): void;
    (
        e: "day-hover",
        payload: {
            date: Date;
            ymd: YMD;
            disabled?: DisabledSpec;
            element?: HTMLElement | null;
            trigger?: "pointer" | "focus";
        }
    ): void;
    (
        e: "select-attempt-blocked",
        payload: { date: Date; reason: string }
    ): void;
    (e: "ready", instance: Instance): void;
    (e: "day-leave"): void;
}>();

type FlatpickrBoundInput = HTMLInputElement & { _flatpickr?: Instance };

const rootRef = ref<HTMLElement | null>(null);
const inputRef = ref<HTMLInputElement | null>(null);
const fpInstance = shallowRef<Instance | null>(null);
let keyboardInputElement: HTMLInputElement | null = null;

// Two months when two .dayContainer grids fit the wrapper, otherwise
// one; starts at two, corrected from the measured width below.
const showMonths = ref(2);
let availableWidthObserver: ResizeObserver | null = null;

let hoverRafScheduled = false;
let latestHoverDate: Date | null = null;
let latestHoverElement: HTMLElement | null = null;
let latestInteractionTrigger: "pointer" | "focus" = "pointer";

/**
 * Format a browser-local date as a booking calendar key.
 *
 * @param {Date} d Date to format.
 * @returns {YMD} Local YYYY-MM-DD value.
 */
function ymdKey(d: Date): YMD {
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, "0");
    const day = String(d.getDate()).padStart(2, "0");
    return `${y}-${m}-${day}`;
}

/**
 * Resolve booking disable metadata for a calendar date.
 *
 * @param {Date} date Date to inspect.
 * @returns {DisabledSpec|null} Disable metadata, or null when enabled.
 */
function disabledSpecFor(date: Date): DisabledSpec | null {
    const d = props.disabled;
    if (typeof d === "function") return d(date);
    if (d instanceof Map) return d.get(ymdKey(date)) ?? null;
    return null;
}

/**
 * Keep the currently selected edit range visible while rules refresh.
 *
 * @param {Date} date Date to inspect.
 * @returns {boolean} Whether the date is in the selected range.
 */
function isSelectedRangeDate(date: Date): boolean {
    const range = props.modelValue;
    if (!Array.isArray(range) || range.length === 0 || range[0] == null) {
        return false;
    }

    /**
     * Convert a valid date to a calendar key.
     *
     * @param {Date} value Date to convert.
     * @returns {YMD|null} Calendar key, or null for an invalid date.
     */
    const toKey = (value: Date): YMD | null =>
        Number.isNaN(value.getTime()) ? null : ymdKey(value);
    const start = toKey(range[0]);
    const end = toKey(range[1] ?? range[0]);
    if (!start || !end) return false;

    const key = ymdKey(date);
    return key >= start && key <= end;
}

const hardDisableConfig = computed<Options["disable"] | undefined>(() => {
    const d = props.disabled;
    if (typeof d === "function") {
        return [
            (date: Date) => {
                const spec = d(date);
                return (
                    !!spec &&
                    spec.severity !== "soft" &&
                    !isSelectedRangeDate(date)
                );
            },
        ];
    }
    if (d instanceof Map) {
        const hardSet = new Set<YMD>();
        d.forEach((spec, key) => {
            if (spec.severity !== "soft") hardSet.add(key);
        });
        if (hardSet.size === 0) return undefined;
        return [
            (date: Date) =>
                hardSet.has(ymdKey(date)) && !isSelectedRangeDate(date),
        ];
    }
    return undefined;
});

/**
 * Apply booking accessibility, disable, class, and marker state to a day.
 *
 * @param {Date[]} _selectedDates Flatpickr selection supplied to the hook.
 * @param {string} _dateStr Flatpickr date string supplied to the hook.
 * @param {Instance} _instance Flatpickr instance supplied to the hook.
 * @param {DayElement} dayElem Newly rendered day element.
 * @returns {void}
 */
function onDayCreate(
    _selectedDates: Date[],
    _dateStr: string,
    _instance: Instance,
    dayElem: DayElement
): void {
    if (!dayElem.dateObj) return;
    const date = dayElem.dateObj;
    const key = ymdKey(date);

    const disabled = disabledSpecFor(date);
    const soft = disabled?.severity === "soft" ? disabled : null;

    // Flatpickr's day elements are spans and disabled days do not receive a
    // tab index. Give every day button semantics so the roving keyboard focus
    // implemented below can include conflict days and announce their state.
    dayElem.tabIndex = -1;
    dayElem.setAttribute("role", "button");
    dayElem.setAttribute(
        "aria-pressed",
        dayElem.classList.contains("selected") ? "true" : "false"
    );
    if (disabled || dayElem.classList.contains("flatpickr-disabled")) {
        dayElem.setAttribute("aria-disabled", "true");
    }
    if (disabled) {
        dayElem.setAttribute(
            "data-booking-fp-disabled-reason",
            disabled.reason || ""
        );
    }

    if (soft) {
        dayElem.classList.add("booking-fp-soft-disabled");
        // flatpickr binds `click` on daysContainer to run selectDate. A
        // capture-phase listener on the day itself runs first and blocks
        // it, preserving the day's enabled-for-range-validation status.
        dayElem.addEventListener(
            "click",
            (e: Event) => {
                e.preventDefault();
                e.stopPropagation();
                (
                    e as Event & {
                        stopImmediatePropagation: () => void;
                    }
                ).stopImmediatePropagation();
                emit("select-attempt-blocked", {
                    date,
                    reason: soft.reason,
                });
            },
            { capture: true }
        );
    }

    const cls = props.classByDate?.get(key);
    if (cls) {
        cls.split(/\s+/).forEach(c => {
            if (c) dayElem.classList.add(c);
        });
    }

    const markers = props.markersByDate?.get(key);
    if (markers && markers.length > 0) {
        const tooltips: string[] = [];
        markers.forEach(marker => {
            // className may itself be space-separated (e.g. a run-start/
            // run-end modifier alongside the base class) - classList.add
            // rejects a single token containing whitespace, so split it.
            if (marker.className) {
                dayElem.classList.add(...marker.className.split(/\s+/));
            }
            if (marker.tooltip) tooltips.push(marker.tooltip);
        });
        if (tooltips.length > 0) {
            dayElem.setAttribute("title", [...new Set(tooltips)].join("\n"));
        }
    }
}

/**
 * Return the visible day cells in the current calendar viewport.
 *
 * @param {Instance} fp Active Flatpickr instance.
 * @returns {DayElement[]} Visible calendar day elements.
 */
function calendarDays(fp: Instance): DayElement[] {
    return Array.from(
        fp.calendarContainer?.querySelectorAll<DayElement>(
            ".flatpickr-day:not(.hidden)"
        ) ?? []
    );
}

/**
 * Move the calendar's roving tab stop to one day.
 *
 * @param {Instance} fp Active Flatpickr instance.
 * @param {DayElement} day Day that receives the tab stop.
 * @returns {void}
 */
function setRovingDay(fp: Instance, day: DayElement): void {
    calendarDays(fp).forEach(candidate => {
        candidate.tabIndex = candidate === day ? 0 : -1;
    });
}

/**
 * Move the calendar's roving tab stop and DOM focus to one day.
 *
 * @param {Instance} fp Active Flatpickr instance.
 * @param {DayElement} day Day to focus.
 * @returns {void}
 */
function focusDayElement(fp: Instance, day: DayElement): void {
    setRovingDay(fp, day);
    day.focus();
}

/**
 * Find the rendered day cell for a local calendar date.
 *
 * @param {Instance} fp Active Flatpickr instance.
 * @param {Date} date Date to find.
 * @returns {DayElement|null} Matching rendered day.
 */
function dayElementForDate(fp: Instance, date: Date): DayElement | null {
    const key = ymdKey(date);
    return (
        calendarDays(fp).find(
            day => day.dateObj && ymdKey(day.dateObj) === key
        ) ?? null
    );
}

/**
 * Navigate when needed and focus a requested local calendar date.
 *
 * @param {Instance} fp Active Flatpickr instance.
 * @param {Date} date Date to focus.
 * @returns {void}
 */
function focusCalendarDate(fp: Instance, date: Date): void {
    const targetMonth = date.getFullYear() * 12 + date.getMonth();
    const firstMonth = fp.currentYear * 12 + fp.currentMonth;
    const lastMonth = firstMonth + Math.max(fp.config.showMonths, 1) - 1;

    if (targetMonth < firstMonth || targetMonth > lastMonth) {
        fp.changeMonth(targetMonth - firstMonth, true);
    }

    const target = dayElementForDate(fp, date);
    if (target) focusDayElement(fp, target);
}

/**
 * Focus the selected, current, or first available day after opening.
 *
 * @param {Instance} fp Active Flatpickr instance.
 * @returns {void}
 */
function focusInitialCalendarDay(fp: Instance): void {
    const days = calendarDays(fp);
    const selected = fp.selectedDateElem as DayElement | undefined;
    const today = fp.todayDateElem as DayElement | undefined;
    const target =
        (selected && fp.calendarContainer.contains(selected)
            ? selected
            : undefined) ??
        (today &&
        fp.calendarContainer.contains(today) &&
        !today.classList.contains("flatpickr-disabled")
            ? today
            : undefined) ??
        days.find(
            day =>
                !day.classList.contains("prevMonthDay") &&
                !day.classList.contains("nextMonthDay") &&
                !day.classList.contains("flatpickr-disabled")
        ) ??
        days[0];

    if (target) focusDayElement(fp, target);
}

/**
 * Prevent Flatpickr's built-in handler from duplicating a handled key.
 *
 * @param {KeyboardEvent} e Keyboard event to stop.
 * @returns {void}
 */
function stopKeyboardEvent(e: KeyboardEvent): void {
    e.preventDefault();
    e.stopPropagation();
    e.stopImmediatePropagation();
}

/**
 * Shift a date by whole months while clamping its day within the month.
 *
 * @param {Date} date Date to shift.
 * @param {number} monthDelta Number of months to move.
 * @returns {Date} Shifted local date.
 */
function shiftedMonthDate(date: Date, monthDelta: number): Date {
    const targetMonth = date.getMonth() + monthDelta;
    const lastDay = new Date(date.getFullYear(), targetMonth + 1, 0).getDate();
    return new Date(
        date.getFullYear(),
        targetMonth,
        Math.min(date.getDate(), lastDay),
        12
    );
}

/**
 * Transfer keyboard focus from the (always-visible) input into the grid.
 *
 * @param {KeyboardEvent} e Input keyboard event.
 * @returns {void}
 */
function onInputKeyDown(e: KeyboardEvent): void {
    const fp = fpInstance.value;
    if (!fp || props.inputDisabled) return;

    if (
        e.key !== "Enter" &&
        e.key !== " " &&
        e.key !== "Spacebar" &&
        e.key !== "ArrowDown"
    ) {
        return;
    }

    stopKeyboardEvent(e);
    requestAnimationFrame(() => {
        if (fpInstance.value === fp) focusInitialCalendarDay(fp);
    });
}

/**
 * Handle date movement, selection, month movement, and dismissal.
 *
 * @param {KeyboardEvent} e Calendar keyboard event.
 * @returns {void}
 */
function onCalendarKeyDown(e: KeyboardEvent): void {
    const fp = fpInstance.value;
    if (!fp) return;

    if (e.key === "Escape") {
        stopKeyboardEvent(e);
        // Nothing to close (the calendar is always visible) - just return
        // keyboard focus to the input, a reasonable "step back out" gesture.
        keyboardInputElement?.focus();
        return;
    }

    const target = e.target as HTMLElement | null;
    const monthControl = target?.closest<HTMLElement>(
        ".flatpickr-prev-month, .flatpickr-next-month"
    );
    if (
        monthControl &&
        (e.key === "Enter" || e.key === " " || e.key === "Spacebar")
    ) {
        stopKeyboardEvent(e);
        if (!monthControl.classList.contains("flatpickr-disabled")) {
            monthControl.click();
        }
        return;
    }

    const day = target?.closest<DayElement>(".flatpickr-day");
    if (!day?.dateObj) return;

    if (e.key === "Enter" || e.key === " " || e.key === "Spacebar") {
        stopKeyboardEvent(e);
        if (day.classList.contains("flatpickr-disabled")) {
            const reason = day.dataset.bookingFpDisabledReason || "";
            if (reason) {
                emit("select-attempt-blocked", {
                    date: day.dateObj,
                    reason,
                });
            }
            return;
        }
        day.click();
        return;
    }

    const dayOffsets: Record<string, number> = {
        ArrowLeft: -1,
        ArrowRight: 1,
        ArrowUp: -7,
        ArrowDown: 7,
    };
    const dayOffset = dayOffsets[e.key];
    if (dayOffset) {
        stopKeyboardEvent(e);
        const targetDate = new Date(day.dateObj);
        targetDate.setDate(targetDate.getDate() + dayOffset);
        focusCalendarDate(fp, targetDate);
        return;
    }

    if (e.key === "PageUp" || e.key === "PageDown") {
        stopKeyboardEvent(e);
        const direction = e.key === "PageDown" ? 1 : -1;
        focusCalendarDate(
            fp,
            shiftedMonthDate(day.dateObj, direction * (e.shiftKey ? 12 : 1))
        );
    }
}

/**
 * Apply accessible dialog and month-control semantics after redraws.
 *
 * @param {Instance} fp Active Flatpickr instance.
 * @returns {void}
 */
function syncCalendarKeyboardSemantics(fp: Instance): void {
    const calendar = fp.calendarContainer;
    // Not role="dialog" - that implies a modal-like popup window with its
    // own focus-trap expectations, which doesn't fit a calendar that's
    // permanently part of the page's normal content.
    calendar.setAttribute("role", "group");
    calendar.setAttribute("aria-label", $__("Choose date"));

    const controls: Array<[HTMLElement, string]> = [
        [fp.prevMonthNav, $__("Previous month")],
        [fp.nextMonthNav, $__("Next month")],
    ];
    controls.forEach(([control, label]) => {
        control.tabIndex = 0;
        control.setAttribute("role", "button");
        control.setAttribute("aria-label", label);
        if (control.classList.contains("flatpickr-disabled")) {
            control.setAttribute("aria-disabled", "true");
        } else {
            control.removeAttribute("aria-disabled");
        }
    });
}

/**
 * Coalesce pointer or focus interaction into one day-hover event per frame.
 *
 * @param {HTMLElement|null} target Interaction target within the calendar.
 * @param {"pointer"|"focus"} trigger Interaction source.
 * @returns {void}
 */
function queueDayInteraction(
    target: HTMLElement | null,
    trigger: "pointer" | "focus"
): void {
    const dayEl = target?.closest<HTMLElement>(".flatpickr-day") as
        | DayElement
        | undefined;
    if (!dayEl?.dateObj) return;

    latestHoverDate = dayEl.dateObj;
    latestHoverElement = dayEl as HTMLElement;
    latestInteractionTrigger = trigger;
    if (hoverRafScheduled) return;
    hoverRafScheduled = true;
    requestAnimationFrame(() => {
        hoverRafScheduled = false;
        if (!latestHoverDate || !fpInstance.value) return;

        const hover = latestHoverDate;
        const spec = disabledSpecFor(hover);
        emit("day-hover", {
            date: hover,
            ymd: ymdKey(hover),
            disabled: spec ?? undefined,
            element: latestHoverElement,
            trigger: latestInteractionTrigger,
        });
    });
}

/**
 * Queue pointer feedback for the calendar day under the mouse.
 *
 * @param {MouseEvent} e Calendar mouse event.
 * @returns {void}
 */
function onCalendarMouseOver(e: MouseEvent): void {
    queueDayInteraction(e.target as HTMLElement | null, "pointer");
}

/**
 * Update roving focus and queue feedback for a focused day.
 *
 * @param {FocusEvent} e Calendar focus event.
 * @returns {void}
 */
function onCalendarFocusIn(e: FocusEvent): void {
    const fp = fpInstance.value;
    const day = (e.target as HTMLElement | null)?.closest<DayElement>(
        ".flatpickr-day"
    );
    if (fp && day) setRovingDay(fp, day);
    queueDayInteraction(e.target as HTMLElement | null, "focus");
}

/**
 * Announce day departure when focus leaves the calendar.
 *
 * @param {FocusEvent} e Calendar focus event.
 * @returns {void}
 */
function onCalendarFocusOut(e: FocusEvent): void {
    const calendar = e.currentTarget as HTMLElement;
    const next = e.relatedTarget as Node | null;
    if (!next || !calendar.contains(next)) emit("day-leave");
}

/**
 * Announce day departure when the pointer leaves an unfocused calendar.
 *
 * @param {MouseEvent} e Calendar mouse event.
 * @returns {void}
 */
function onCalendarMouseLeave(e: MouseEvent): void {
    const calendar = e.currentTarget as HTMLElement;
    if (!calendar.contains(document.activeElement)) emit("day-leave");
}

/**
 * Build booking-specific Flatpickr options over Koha's ambient defaults.
 *
 * @returns {Partial<Options>} Flatpickr options owned by the calendar.
 */
function buildConfig(): Partial<Options> {
    // calendar.inc owns the translated locale, display format, arrows, and
    // other Koha page defaults. This component only supplies booking-range
    // behavior.
    //
    // inline: true renders the calendar permanently in normal document
    // flow, right after the input, instead of a floating popup that opens
    // on click - the input itself becomes a read-only display of the
    // current selection (see the greyed styling below), all the actual
    // interaction happening in the always-visible grid. This also sidesteps
    // the Bootstrap modal focus-trap issue the previous popup-mode config
    // worked around (appendTo/position, now removed): there's no floating
    // element under <body> to redirect focus away from any more.
    //
    // animate: false avoids flatpickr's default fade-in-down entrance
    // animation, which would otherwise still fire once against the
    // permanently-forced .open class below (its .animate.open CSS keyframe
    // doesn't check for inline mode).
    const cfg: Partial<Options> = {
        mode: "range",
        allowInput: false,
        dateFormat: "Y-m-d",
        inline: true,
        showMonths: showMonths.value,
        animate: false,
        // Koha's page defaults add Yesterday/Today/Tomorrow shortcuts.
        // They bypass booking range constraints, so omit them entirely.
        plugins: [],
        disable: hardDisableConfig.value ?? [],
        onChange: handleChange,
        onReady: handleReady,
        onClose: handleClose,
        onMonthChange: handleMonthChange,
        onYearChange: handleMonthChange,
        onDayCreate,
    };

    if (props.minDate != null) cfg.minDate = props.minDate;
    return cfg;
}

/**
 * Apply required and stable-ID semantics to Flatpickr's visible input.
 *
 * @param {Instance} fp Initialized Flatpickr instance.
 * @returns {void}
 */
function syncInputSemantics(fp: Instance): void {
    const original = inputRef.value;
    const visible = fp.altInput ?? original;
    if (!original || !visible) return;

    if (fp.altInput) {
        original.id = "booking_period_value";
        fp.altInput.id = "booking_period";
        // Browser automation and page integrations address the visible
        // booking-period control and expect Flatpickr's instance there.
        (fp.altInput as FlatpickrBoundInput)._flatpickr = fp;
        original.removeAttribute("required");
        original.removeAttribute("aria-required");
    }

    visible.required = true;
    visible.setAttribute("aria-required", "true");
}

/**
 * Complete keyboard and accessibility setup after Flatpickr initialization.
 *
 * @param {Date[]} _d Initial Flatpickr dates.
 * @param {string} _s Initial Flatpickr date string.
 * @param {Instance} fp Initialized Flatpickr instance.
 * @returns {void}
 */
function handleReady(_d: Date[], _s: string, fp: Instance): void {
    syncInputSemantics(fp);
    syncCalendarKeyboardSemantics(fp);
    keyboardInputElement = fp.altInput ?? inputRef.value;
    fp.calendarContainer.id = "booking_period_calendar";
    keyboardInputElement?.setAttribute(
        "aria-controls",
        fp.calendarContainer.id
    );
    keyboardInputElement?.addEventListener("keydown", onInputKeyDown, true);

    // The calendar is permanently visible now (inline), never a popup that
    // opens/closes - keep .flatpickr-day's own .open CSS class present too
    // (harmless alongside .inline, see buildConfig's comment on `animate`)
    // since existing Cypress specs already wait on it. onClose re-adds it
    // defensively: flatpickr's own internal logic still calls close() from
    // a few code paths regardless of config.inline (e.g. after a completed
    // range selection), and unlike open(), close() has no inline guard.
    fp.calendarContainer.classList.add("open");

    const cal = fp.calendarContainer;
    if (cal) {
        cal.addEventListener("keydown", onCalendarKeyDown, true);
        cal.addEventListener("mouseover", onCalendarMouseOver);
        cal.addEventListener("mouseleave", onCalendarMouseLeave);
        cal.addEventListener("focusin", onCalendarFocusIn);
        cal.addEventListener("focusout", onCalendarFocusOut);
    }
    emit("ready", fp);
}

/**
 * Publish selected dates.
 *
 * Deliberately does not also report the viewport: onMonthChange/
 * onYearChange (handleMonthChange, below) already cover every actual
 * navigation, and mode is hardcoded to "range" in buildConfig, where
 * Flatpickr's own selectDate() forces shouldChangeMonth to false - a
 * date pick never moves the visible months in this component, so a
 * second, independent viewport emit here would always report an
 * unchanged value. That used to happen on every single date pick
 * regardless, needlessly re-triggering the parent's viewport-driven
 * availability/holidays refetch (see BookingPeriodStep.vue's
 * onUpdateViewport) moments after the pick was already done.
 *
 * @param {Date[]} selectedDates Flatpickr's current selection.
 * @param {string} _dateStr Flatpickr's formatted selection.
 * @param {Instance} _fp Active Flatpickr instance.
 * @returns {void}
 */
function handleChange(
    selectedDates: Date[],
    _dateStr: string,
    _fp: Instance
): void {
    emit("update:modelValue", normalizeOutput(selectedDates));
}

/**
 * Keep the calendar's .open class present even if Flatpickr's own internal
 * logic calls close() (it has no config.inline guard, unlike open()) - the
 * calendar never actually closes in this always-visible design.
 *
 * @param {Date[]} _d Flatpickr's selected dates.
 * @param {string} _s Flatpickr's formatted selection.
 * @param {Instance} fp Active Flatpickr instance.
 * @returns {void}
 */
function handleClose(_d: Date[], _s: string, fp: Instance): void {
    fp.calendarContainer.classList.add("open");
}

/**
 * Refresh semantics and publish the viewport after month or year navigation.
 *
 * @param {Date[]} _d Flatpickr's selected dates.
 * @param {string} _s Flatpickr's formatted selection.
 * @param {Instance} fp Active Flatpickr instance.
 * @returns {void}
 */
function handleMonthChange(_d: Date[], _s: string, fp: Instance): void {
    syncCalendarKeyboardSemantics(fp);
    emit("update:viewport", {
        year: fp.currentYear,
        month: fp.currentMonth,
    });
}

/**
 * Normalize Flatpickr's mutable date array to the component range contract.
 *
 * @param {Date[]} dates Flatpickr's current selected dates.
 * @returns {SelectedRange} Normalized selected range.
 */
function normalizeOutput(dates: Date[]): SelectedRange {
    if (dates.length === 0) return null;
    // Anchor-only state (one date picked, awaiting end) remains observable so
    // the store can recalculate lead/trail and maximum-period constraints.
    if (dates.length === 1) return [dates[0]];
    return [dates[0], dates[1]];
}

/**
 * Apply an external model value while preserving focused-day context.
 *
 * @param {SelectedRange} v Range supplied by the parent workflow.
 * @returns {void}
 */
function applyExternalValue(v: SelectedRange): void {
    const fp = fpInstance.value;
    if (!fp) return;
    const focusedDay = fp.calendarContainer.contains(document.activeElement)
        ? (document.activeElement as HTMLElement).closest<DayElement>(
              ".flatpickr-day"
          )
        : null;
    const focusedDate = focusedDay?.dateObj
        ? new Date(focusedDay.dateObj)
        : null;
    if (v == null || (Array.isArray(v) && (v.length === 0 || v[0] == null))) {
        fp.clear(false, false);
        return;
    }

    const dateInput = v.filter(date => date != null);
    fp.setDate(dateInput as Parameters<Instance["setDate"]>[0], false);
    // focusedDate is only non-null when the calendar already had focus
    // (computed above) - restoring it there is the relevant guard now,
    // not fp.isOpen (always visible, so no longer a meaningful signal).
    if (focusedDate) {
        const restoredDay = dayElementForDate(fp, focusedDate);
        if (restoredDay) focusDayElement(fp, restoredDay);
    }
}

/**
 * Move the active Flatpickr instance to a requested month and year.
 *
 * @param {Viewport} vp Target calendar viewport.
 * @returns {void}
 */
function navigateToViewport(vp: Viewport): void {
    const fp = fpInstance.value;
    if (!fp) return;
    if (fp.currentYear !== vp.year) fp.changeYear(vp.year);
    if (fp.currentMonth !== vp.month) {
        fp.changeMonth(vp.month - fp.currentMonth, true);
    }
}

/**
 * Create and initialize the Flatpickr instance for the input.
 *
 * @returns {void}
 */
function createInstance(): void {
    if (!inputRef.value) return;
    fpInstance.value = window.flatpickr(
        inputRef.value,
        buildConfig() as Options
    );
    if (props.modelValue != null) {
        applyExternalValue(props.modelValue);
    }
    if (props.viewport) {
        navigateToViewport(props.viewport);
    }
}

/**
 * Remove listeners, compatibility state, and the Flatpickr instance.
 *
 * @returns {void}
 */
function destroyInstance(): void {
    const fp = fpInstance.value;
    if (!fp) return;
    const cal = fp.calendarContainer;
    if (cal) {
        cal.removeEventListener("keydown", onCalendarKeyDown, true);
        cal.removeEventListener("mouseover", onCalendarMouseOver);
        cal.removeEventListener("mouseleave", onCalendarMouseLeave);
        cal.removeEventListener("focusin", onCalendarFocusIn);
        cal.removeEventListener("focusout", onCalendarFocusOut);
    }
    keyboardInputElement?.removeEventListener("keydown", onInputKeyDown, true);
    keyboardInputElement = null;
    if (fp.altInput) {
        delete (fp.altInput as FlatpickrBoundInput)._flatpickr;
    }
    fp.destroy();
    if (inputRef.value) {
        inputRef.value.id = "booking_period";
        inputRef.value.required = true;
        inputRef.value.setAttribute("aria-required", "true");
    }
    fpInstance.value = null;
}

/**
 * Clear the current Flatpickr selection through the exposed form API.
 *
 * @returns {void}
 */
function clear(): void {
    fpInstance.value?.clear();
}

defineExpose({ clear });

/**
 * Months (1 or 2) that fit side by side in `width`, measured against
 * the live .dayContainer ($daysWidth in _flatpickr.scss) plus the
 * calendar's borders; without an instance the current count stands.
 *
 * @param {number} width Available wrapper width in px.
 * @returns {number} 1 or 2.
 */
function monthsThatFit(width: number): number {
    const fp = fpInstance.value;
    if (!fp) return showMonths.value;
    const calendar = fp.calendarContainer;
    const grid = calendar.querySelector<HTMLElement>(".dayContainer");
    if (!grid?.offsetWidth) return showMonths.value;
    const borders = calendar.offsetWidth - calendar.clientWidth;
    return width >= grid.offsetWidth * 2 + borders ? 2 : 1;
}

/**
 * Rebuild the calendar when the wrapper's width crosses the two-month
 * threshold: Flatpickr builds its grids once at init, so a new
 * showMonths needs a new instance (createInstance re-applies model
 * value and viewport). Rebuilt on the next frame: resizing the observed
 * element from inside the callback triggers the browser's
 * ResizeObserver loop error.
 *
 * @returns {void}
 */
function observeAvailableWidth(): void {
    if (!rootRef.value || typeof ResizeObserver === "undefined") return;
    let rebuildScheduled = false;
    availableWidthObserver = new ResizeObserver(entries => {
        const width = entries[0]?.contentRect.width ?? 0;
        // display: none measures 0; nothing to decide until shown.
        if (!width) return;
        showMonths.value = monthsThatFit(width);
        if (rebuildScheduled) return;
        rebuildScheduled = true;
        requestAnimationFrame(() => {
            rebuildScheduled = false;
            const fp = fpInstance.value;
            if (!fp || fp.config.showMonths === showMonths.value) return;
            destroyInstance();
            createInstance();
        });
    });
    availableWidthObserver.observe(rootRef.value);
}

onMounted(() => {
    createInstance();
    // Settle the count synchronously so a narrow mount never paints two
    // months first; the observer handles later resizes.
    const width = rootRef.value?.clientWidth ?? 0;
    if (width) {
        const months = monthsThatFit(width);
        if (months !== showMonths.value) {
            showMonths.value = months;
            destroyInstance();
            createInstance();
        }
    }
    observeAvailableWidth();
});

onBeforeUnmount(() => {
    availableWidthObserver?.disconnect();
    availableWidthObserver = null;
    destroyInstance();
});

// Coalesce flatpickr.set/redraw calls into a single rAF tick. Without
// coalescing, rapid prop changes during modal hydration trigger one
// synchronous redraw per change, saturating the microtask queue and
// starving other components' render effects (notably vue-select dropdowns).
let redrawScheduled = false;

/**
 * Coalesce booking marker and constraint redraws into one animation frame.
 *
 * @returns {void}
 */
function scheduleRedraw(): void {
    if (redrawScheduled) return;
    redrawScheduled = true;
    requestAnimationFrame(() => {
        redrawScheduled = false;
        const fp = fpInstance.value;
        if (!fp) return;
        const activeDay = fp.calendarContainer.contains(document.activeElement)
            ? (document.activeElement as HTMLElement).closest<DayElement>(
                  ".flatpickr-day"
              )
            : null;
        const focusedDate = activeDay?.dateObj
            ? new Date(activeDay.dateObj)
            : null;
        fp.set("disable", hardDisableConfig.value ?? []);
        // Flatpickr may clear selectedDates while replacing its disable
        // rules. The prop remains the source of truth, especially in edit
        // mode where the existing range must stay visible during contextual
        // refreshes.
        applyExternalValue(props.modelValue ?? null);
        fp.redraw();
        syncCalendarKeyboardSemantics(fp);
        const restoredDay = focusedDate
            ? dayElementForDate(fp, focusedDate)
            : null;
        if (restoredDay) focusDayElement(fp, restoredDay);
    });
}

watch(
    [() => props.disabled, () => props.markersByDate, () => props.classByDate],
    () => scheduleRedraw(),
    { flush: "post" }
);

// minDate gets its own watcher because flatpickr's set("minDate") snaps the
// visible month back to contain the new bound; folding it into the redraw path
// above would undo every user-driven month navigation.
watch(
    () => props.minDate,
    v => {
        const fp = fpInstance.value;
        if (!fp) return;
        fp.set("minDate", (v ?? null) as string | Date | null);
    }
);
// flatpickr's altInput clones the original input's state once at init;
// the :disabled binding only reaches the original input, so the visible
// alt input needs explicit syncing afterwards.
watch(
    () => props.inputDisabled,
    v => {
        const alt = fpInstance.value?.altInput;
        if (alt) alt.disabled = v;
    }
);

watch(
    () => props.modelValue,
    v => {
        if (!fpInstance.value) return;
        applyExternalValue(v ?? null);
    },
    { deep: false }
);

watch(
    () => props.viewport,
    vp => {
        if (!vp || !fpInstance.value) return;
        navigateToViewport(vp);
    }
);
</script>

<style>
/* Flatpickr always inserts its inline calendar right after the bound
   input (self._input.nextSibling), so DOM order is fixed as input,
   calendar, then whatever the required/legend slots render (they exist
   as the input's next siblings before Flatpickr's one-time insertion,
   so the calendar lands between the input and them). The explicit order
   values below are what actually put the required hint and legend
   visually between the input and the calendar, regardless of that DOM
   order - clear-button isn't among them since it's positioned out of
   the flex flow entirely, overlaid on the input itself (below). */
.booking-flatpickr-wrapper {
    position: relative;
    display: flex;
    flex-direction: column;
}
.booking-flatpickr-input {
    order: 0;
    /* Room for the overlaid clear button, see [slot="clear-button"]. */
    padding-right: 2.25rem;
}
.booking-period-required {
    order: 1;
}
.calendar-legend {
    order: 2;
}
/* align-self: center, not the wrapper's default align-items: stretch -
   stretch would otherwise force the calendar to the wrapper's full
   cross-axis width (matching the full-width input above it) rather than
   its own natural, fixed 2-month content width. */
.flatpickr-calendar {
    order: 3;
    align-self: center;
}
/* Embedded like the closed-days calendar (calendar.scss): no popup drop
   shadow, a plain border in the modal's neutral instead. */
.booking-flatpickr-wrapper > .flatpickr-calendar {
    box-shadow: none;
    border: var(--booking-border-width) solid var(--booking-neutral-300);
    border-radius: var(--booking-border-radius-sm);
}
/* The clear button lives in BookingPeriodStep.vue (clearing dates has
   store-level side effects beyond the picker's own state) but renders
   here, overlaid on the input rather than beside it, so the input's own
   width and styling match every other .form-control in the modal - a
   separate flex sibling used to force the input to share row space with
   the button. top: 0 relies on the input being this wrapper's first
   flex item (order: 0, no margin), so it starts flush with the
   wrapper's own top edge; the fixed height/offset below approximates
   Bootstrap's own .form-control box (padding-y 0.375rem, line-height
   1.5, 1px borders) since nothing here can measure the input's actual
   rendered height in pure CSS. */
.booking-clear-overlay {
    position: absolute;
    top: 0;
    right: 0.25rem;
    height: 2.375rem;
    display: flex;
    align-items: center;
}
/* _flatpickr.scss hardcodes .flatpickr-calendar/.flatpickr-days to one
   month's fixed pixel width with overflow: hidden - correct for the
   single-month popup every other flatpickr instance in Koha uses, but it
   silently clips the second month's .dayContainer entirely out of view
   for showMonths: 2 (the elements exist in the DOM, they're just hidden).
   Letting these size to their content instead - each .dayContainer still
   carries its own fixed width - is the general fix for any N months, not
   just 2, and the overflow:hidden these rules also drop existed to hide
   the month-to-month slide transition, which animate: false disables.

   !important is load-bearing here, not decorative: Flatpickr's own
   setCalendarWidth() runs once, one rAF after init(), and sets
   calendarContainer/daysContainer width as an inline style computed from
   .dayContainer's measured offsetWidth at that instant - inline styles
   always beat stylesheet rules regardless of selector specificity. Worse,
   that one-shot measurement is unreliable early in an inline calendar's
   life (it has measured 0, baking in a ~2px width forever, with nothing
   ever re-running setCalendarWidth to correct it) - so this can't be
   fixed by only winning the specificity fight, since there's no stylesheet
   specificity high enough to out-rank an inline style at all. */
.flatpickr-calendar.multiMonth,
.flatpickr-calendar.multiMonth .flatpickr-innerContainer,
.flatpickr-calendar.multiMonth .flatpickr-days {
    width: auto !important;
    overflow: visible;
}
/* Read-only display of the current selection - the actual interaction
   happens in the always-visible calendar below, not by typing or
   clicking into this field. Muted rather than fully disabled-looking,
   since the clear (x) button next to it stays fully active. */
.booking-flatpickr-input[readonly] {
    background-color: var(--booking-neutral-100, #f8f9fa);
    color: var(--booking-neutral-600, #6c757d);
    cursor: default;
}
.flatpickr-day:focus-visible,
.flatpickr-prev-month:focus-visible,
.flatpickr-next-month:focus-visible {
    outline: 2px solid var(--booking-fp-focus-color, currentColor);
    outline-offset: 2px;
}
.flatpickr-day.booking-fp-soft-disabled {
    opacity: 0.55;
    text-decoration: line-through;
    cursor: not-allowed;
}
</style>
