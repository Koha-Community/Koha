-- Rename 'Reserve slip' to 'Holds slip' to match Koha's terminology
UPDATE letter SET name = "Hold Slip" WHERE name = "Reserve Slip";
UPDATE letter SET title = "Hold Slip" WHERE title = "Reserve Slip";
