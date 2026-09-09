/**
 * Physical item that can be booked (minimum shape used across the UI).
 */
export type BookableItem = {
    /** Internal item identifier */
    item_id: Id;
    /** Koha item type code */
    item_type_id: string;
    /** Effective type after MARC policies (when present) */
    effective_item_type_id?: string;
    /** Owning or home library id */
    home_library_id: string;
    /** Optional descriptive fields used in UI/logs */
    title?: string;
    barcode?: string;
    external_id?: string;
    /** Localized strings container (when available) */
    _strings?: { item_type_id?: { str?: string } };
};

/**
 * Library that can serve as pickup location with optional item whitelist.
 */
export type PickupLocation = {
    library_id: string;
    name: string;
    /** Allowed item ids for pickup at this location (when restricted) */
    pickup_items?: Array<Id>;
};

/**
 * Subset of circulation rules used by bookings logic (from backend API).
 */
export type CirculationRule = {
    /** Max booking length in days (effective, UI-enforced) */
    maxPeriod?: number;
    /** Base issue length in days (backend rule) */
    issuelength?: number;
    /** Renewal policy: length per renewal (days) */
    renewalperiod?: number;
    /** Renewal policy: number of renewals allowed */
    renewalsallowed?: number;
    /** Optional calculated due date from backend (ISO) */
    calculated_due_date?: string;
    /** Optional calculated period in days (from backend) */
    calculated_period_days?: number;
    /** Constraint mode selection */
    booking_constraint_mode?: "range" | "end_date_only";
};

/** Visual marker type used in calendar tooltip and markers grid. */
export type MarkerType =
    | "booked"
    | "checked-out"
    | "lead"
    | "lead-floor"
    | "lead-theoretical"
    | "trail"
    | "holiday";

/**
 * Marker used by calendar code (tooltips + aggregation).
 * Contains a human-readable display label (itemName) and resolved barcode
 * (or external id). The internal item identifier is never a display fallback.
 */
export type CalendarMarker = {
    type: MarkerType;
    item: string;
    itemName: string;
    barcode: string | null;
};

/**
 * A single per-(date, item) availability result. `blockers` prevent a new
 * booking; `warnings` are advisory context only; `confirms` is always empty
 * for bookings. Each is a snake_case reason code mapped to a truthy marker (1).
 */
export type BookingAvailabilityCell = {
    blockers: Record<string, number>;
    confirms: Record<string, number>;
    warnings: Record<string, number>;
};

/**
 * Raw payload of GET /biblios/{biblio_id}/booking_availability. `availability`
 * is a sparse date → item id → cell matrix; an item absent from a date is
 * bookable that day. serverMapToUnavailableByDate flattens the blocker and
 * warning codes into the client's UnavailableByDate shape.
 */
export type BookingAvailabilityResponse = {
    item_ids: number[];
    availability: Record<string, Record<string, BookingAvailabilityCell>>;
};

/**
 * Canonical map of daily unavailability across items.
 *
 * Keys:
 * - Outer key: date in YYYY-MM-DD (calendar day)
 * - Inner key: item id as string
 * - Value: set of reasons for unavailability on that day
 */
export type UnavailableByDate = Record<
    string,
    Record<string, Set<UnavailabilityReason>>
>;

/** Enumerates reasons an item is not bookable on a specific date.
 *
 * Lead variants distinguish the origin of a lead-period block:
 * - "lead": this date is in the lead window of an existing booking.
 * - "lead-floor": this date is within the minimum lead time from today
 *   (the floor applied before any new booking can start).
 * - "lead-theoretical": this date is within the lead time a hypothetical
 *   follow-up booking would need after an existing booking's trail.
 *
 * Hover feedback uses the distinction to attribute the block accurately.
 */
export type UnavailabilityReason =
    | "booking"
    | "checkout"
    | "lead"
    | "lead-floor"
    | "lead-theoretical"
    | "trail"
    | string;

/** Options affecting constraint calculations (UI + rules composition). */
export type ConstraintOptions = {
    dateRangeConstraint?: string | null;
    maxBookingPeriod?: number | null;
};

/** Patron data from API with display metadata added by the booking store. */
export type PatronOption = {
    patron_id?: Id;
    category_id?: Id;
    library_id?: string;
    cardnumber?: string;
    surname?: string;
    firstname?: string;
    /** Display label formatted as "surname firstname (cardnumber)" */
    label: string;
    library?: {
        library_id: string;
        name: string;
    };
    _age?: number | null;
    _libraryName?: string | null;
};

/** Common result shape for `constrain*` helpers. */
export type ConstraintResult<T> = {
    filtered: T[];
    filteredOutCount: number;
    total: number;
    constraintApplied: boolean;
};

/**
 * Common identifier type used across UI (string or number).
 */
export type Id = string | number;

/** Minimal item type shape used in constraints and selection UI. */
export type ItemType = {
    item_type_id: string;
    /** Display description (used by v-select label) */
    description?: string;
};
