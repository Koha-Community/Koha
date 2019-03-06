UPDATE accountlines SET description=REGEXP_REPLACE(description, '^Lost Item ', '') WHERE accounttype="PF";
