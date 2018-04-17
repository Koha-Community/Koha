UPDATE letter SET code = "SERIAL_ALERT" WHERE code = "RLIST";
UPDATE letter SET name = "New serial issue" WHERE name = "Routing List";
UPDATE subscription SET letter = "SERIAL_ALERT" WHERE letter = "RLIST";
-- print Bug 19794: Rename RLIST notice to SERIAL_ALERT
