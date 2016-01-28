ALTER TABLE aqbasket ADD COLUMN create_items ENUM('ordering', 'receiving', 'cataloguing') DEFAULT NULL;
