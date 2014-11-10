ALTER TABLE borrowers
    ADD COLUMN timestamp timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP
    AFTER privacy_guarantor_checkouts;
ALTER TABLE deletedborrowers
    ADD COLUMN timestamp timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP
    AFTER privacy_guarantor_checkouts;
