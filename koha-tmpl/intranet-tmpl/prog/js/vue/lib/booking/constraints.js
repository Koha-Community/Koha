/**
 * Constraint filtering functions for the booking system.
 *
 * This module handles filtering of pickup locations, bookable items,
 * and item types based on selection constraints.
 *
 * @module constraints
 */

import { idsEqual, includesId } from "../../utils/functions.js";

/**
 * Resolve the item type an item is treated as for booking purposes.
 * Items on biblio-level itype systems (or with a NULL itype) carry their
 * type in effective_item_type_id; itemtype options and auto-derivation
 * are built from this value, so constraints must match against it too.
 *
 * @param {import('./types/bookings.d.ts').BookableItem} item
 * @returns {string|number|null|undefined}
 */
function effectiveItemTypeId(item) {
    return item.effective_item_type_id || item.item_type_id;
}

/**
 * Helper to standardize constraint function return shape
 * @template T
 * @param {T[]} filtered - The filtered array
 * @param {number} total - Total count before filtering
 * @returns {import('./types/bookings.d.ts').ConstraintResult<T>}
 */
function buildConstraintResult(filtered, total) {
    const filteredOutCount = total - filtered.length;
    return {
        filtered,
        filteredOutCount,
        total,
        constraintApplied: filtered.length !== total,
    };
}

/**
 * Generic constraint application function.
 * Filters items using an array of predicates with AND logic.
 *
 * @template T
 * @param {T[]} items - Items to filter
 * @param {Array<(item: T) => boolean>} predicates - Filter predicates (AND logic)
 * @returns {import('./types/bookings.d.ts').ConstraintResult<T>}
 */
export function applyConstraints(items, predicates) {
    if (predicates.length === 0) {
        return buildConstraintResult(items, items.length);
    }

    const filtered = items.filter(item =>
        predicates.every(predicate => predicate(item))
    );

    return buildConstraintResult(filtered, items.length);
}

/**
 * Constrain pickup locations based on selected itemtype or item
 * Returns { filtered, filteredOutCount, total, constraintApplied }
 *
 * @param {Array<import('./types/bookings.d.ts').PickupLocation>} pickupLocations
 * @param {Array<import('./types/bookings.d.ts').BookableItem>} bookableItems
 * @param {string|number|null} bookingItemtypeId
 * @param {string|number|null} bookingItemId
 * @returns {import('./types/bookings.d.ts').ConstraintResult<import('./types/bookings.d.ts').PickupLocation>}
 */
export function constrainPickupLocations(
    pickupLocations,
    bookableItems,
    bookingItemtypeId,
    bookingItemId
) {
    const predicates = [];

    // When a specific item is selected, location must allow pickup of that item
    if (bookingItemId) {
        predicates.push(
            loc =>
                loc.pickup_items && includesId(loc.pickup_items, bookingItemId)
        );
    }
    // When an itemtype is selected, location must allow pickup of at least one item of that type
    else if (bookingItemtypeId) {
        predicates.push(
            loc =>
                loc.pickup_items &&
                bookableItems.some(
                    item =>
                        idsEqual(
                            effectiveItemTypeId(item),
                            bookingItemtypeId
                        ) && includesId(loc.pickup_items, item.item_id)
                )
        );
    }

    return applyConstraints(pickupLocations, predicates);
}

/**
 * Constrain bookable items based on selected pickup location and/or itemtype
 * Returns { filtered, filteredOutCount, total, constraintApplied }
 *
 * @param {Array<import('./types/bookings.d.ts').BookableItem>} bookableItems
 * @param {Array<import('./types/bookings.d.ts').PickupLocation>} pickupLocations
 * @param {string|null} pickupLibraryId
 * @param {string|number|null} bookingItemtypeId
 * @returns {import('./types/bookings.d.ts').ConstraintResult<import('./types/bookings.d.ts').BookableItem>}
 */
export function constrainBookableItems(
    bookableItems,
    pickupLocations,
    pickupLibraryId,
    bookingItemtypeId
) {
    const predicates = [];

    // When a pickup location is selected, item must be pickable at that location
    if (pickupLibraryId) {
        predicates.push(item =>
            pickupLocations.some(
                loc =>
                    idsEqual(loc.library_id, pickupLibraryId) &&
                    loc.pickup_items &&
                    includesId(loc.pickup_items, item.item_id)
            )
        );
    }

    // When an itemtype is selected, item must match that type
    if (bookingItemtypeId) {
        predicates.push(item =>
            idsEqual(effectiveItemTypeId(item), bookingItemtypeId)
        );
    }

    return applyConstraints(bookableItems, predicates);
}

/**
 * Constrain item types based on selected pickup location or item
 * Returns { filtered, filteredOutCount, total, constraintApplied }
 * @param {Array<import('./types/bookings.d.ts').ItemType>} itemTypes
 * @param {Array<import('./types/bookings.d.ts').BookableItem>} bookableItems
 * @param {Array<import('./types/bookings.d.ts').PickupLocation>} pickupLocations
 * @param {string|null} pickupLibraryId
 * @param {string|number|null} bookingItemId
 * @returns {import('./types/bookings.d.ts').ConstraintResult<import('./types/bookings.d.ts').ItemType>}
 */
export function constrainItemTypes(
    itemTypes,
    bookableItems,
    pickupLocations,
    pickupLibraryId,
    bookingItemId
) {
    const predicates = [];

    // When a specific item is selected, only show its itemtype
    if (bookingItemId) {
        predicates.push(type =>
            bookableItems.some(
                item =>
                    idsEqual(item.item_id, bookingItemId) &&
                    idsEqual(effectiveItemTypeId(item), type.item_type_id)
            )
        );
    }
    // When a pickup location is selected, only show itemtypes that have items pickable there
    else if (pickupLibraryId) {
        predicates.push(type =>
            bookableItems.some(
                item =>
                    idsEqual(effectiveItemTypeId(item), type.item_type_id) &&
                    pickupLocations.some(
                        loc =>
                            idsEqual(loc.library_id, pickupLibraryId) &&
                            loc.pickup_items &&
                            includesId(loc.pickup_items, item.item_id)
                    )
            )
        );
    }

    return applyConstraints(itemTypes, predicates);
}
