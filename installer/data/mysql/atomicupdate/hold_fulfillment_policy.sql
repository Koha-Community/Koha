ALTER TABLE branch_item_rules         ADD COLUMN hold_fulfillment_policy ENUM('any', 'homebranch', 'holdingbranch') NOT NULL DEFAULT 'any' AFTER holdallowed;
ALTER TABLE default_branch_circ_rules ADD COLUMN hold_fulfillment_policy ENUM('any', 'homebranch', 'holdingbranch') NOT NULL DEFAULT 'any' AFTER holdallowed;
ALTER TABLE default_branch_item_rules ADD COLUMN hold_fulfillment_policy ENUM('any', 'homebranch', 'holdingbranch') NOT NULL DEFAULT 'any' AFTER holdallowed;
ALTER TABLE default_circ_rules        ADD COLUMN hold_fulfillment_policy ENUM('any', 'homebranch', 'holdingbranch') NOT NULL DEFAULT 'any' AFTER holdallowed;
