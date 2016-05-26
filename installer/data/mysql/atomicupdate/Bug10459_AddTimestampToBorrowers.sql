ALTER TABLE borrowers
    ADD COLUMN updated_on timestamp NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP
    AFTER privacy_guarantor_checkouts;
ALTER TABLE deletedborrowers
    ADD COLUMN updated_on timestamp NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP
    AFTER privacy_guarantor_checkouts;
