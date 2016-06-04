ALTER TABLE marc_tag_structure
ADD COLUMN ind2_defaultvalue VARCHAR(1) NOT NULL DEFAULT '' AFTER authorised_value,
ADD COLUMN ind1_defaultvalue VARCHAR(1) NOT NULL DEFAULT '' AFTER authorised_value;
