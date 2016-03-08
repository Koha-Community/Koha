ALTER TABLE items CHANGE new new_status VARCHAR(32) NULL;
ALTER TABLE deleteditems CHANGE new new_status VARCHAR(32) NULL;
UPDATE systempreferences SET value=REPLACE(value, '"items.new"', '"items.new_status"') WHERE variable="automatic_item_modification_by_age_configuration";
