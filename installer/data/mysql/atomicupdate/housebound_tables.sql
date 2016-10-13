CREATE TABLE IF NOT EXISTS `housebound_profile` (
  `borrowernumber` int(11) NOT NULL, -- Number of the borrower associated with this profile.
  `day` text NOT NULL,  -- The preferred day of the week for delivery.
  `frequency` text NOT NULL, -- The Authorised_Value definining the pattern for delivery.
  `fav_itemtypes` text default NULL, -- Free text describing preferred itemtypes.
  `fav_subjects` text default NULL, -- Free text describing preferred subjects.
  `fav_authors` text default NULL, -- Free text describing preferred authors.
  `referral` text default NULL, -- Free text indicating how the borrower was added to the service.
  `notes` text default NULL, -- Free text for additional notes.
  PRIMARY KEY  (`borrowernumber`),
  CONSTRAINT `housebound_profile_bnfk`
    FOREIGN KEY (`borrowernumber`)
    REFERENCES `borrowers` (`borrowernumber`)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `housebound_visit` (
  `id` int(11) NOT NULL auto_increment, -- ID of the visit.
  `borrowernumber` int(11) NOT NULL, -- Number of the borrower, & the profile, linked to this visit.
  `appointment_date` date default NULL, -- Date of visit.
  `day_segment` varchar(10),  -- Rough time frame: 'morning', 'afternoon' 'evening'
  `chooser_brwnumber` int(11) default NULL, -- Number of the borrower to choose items  for delivery.
  `deliverer_brwnumber` int(11) default NULL, -- Number of the borrower to deliver items.
  PRIMARY KEY  (`id`),
  CONSTRAINT `houseboundvisit_bnfk`
    FOREIGN KEY (`borrowernumber`)
    REFERENCES `housebound_profile` (`borrowernumber`)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `houseboundvisit_bnfk_1`
    FOREIGN KEY (`chooser_brwnumber`)
    REFERENCES `borrowers` (`borrowernumber`)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `houseboundvisit_bnfk_2`
    FOREIGN KEY (`deliverer_brwnumber`)
    REFERENCES `borrowers` (`borrowernumber`)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `housebound_role` (
  `borrowernumber_id` int(11) NOT NULL, -- borrowernumber link
  `housebound_chooser` tinyint(1) NOT NULL DEFAULT 0, -- set to 1 to indicate this patron is a housebound chooser volunteer
  `housebound_deliverer` tinyint(1) NOT NULL DEFAULT 0, -- set to 1 to indicate this patron is a housebound deliverer volunteer
  PRIMARY KEY (`borrowernumber_id`),
  CONSTRAINT `houseboundrole_bnfk`
    FOREIGN KEY (`borrowernumber_id`)
    REFERENCES `borrowers` (`borrowernumber`)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT IGNORE INTO systempreferences
       (variable,value,options,explanation,type) VALUES
       ('HouseboundModule',0,'',
       'If ON, enable housebound module functionality.','YesNo');

-- Install in new authorised value category table

INSERT IGNORE INTO authorised_value_categories( category_name ) VALUES
    ('HSBND_FREQ');

-- Then add mandatory authorised values

INSERT IGNORE INTO authorised_values (category, authorised_value, lib) VALUES
       ('HSBND_FREQ','EW','Every week');
