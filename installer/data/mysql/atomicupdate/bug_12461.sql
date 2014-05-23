--
-- Table structure for table 'club_templates'
--

CREATE TABLE IF NOT EXISTS club_templates (
  id int(11) NOT NULL AUTO_INCREMENT,
  `name` tinytext NOT NULL,
  description text,
  is_enrollable_from_opac tinyint(1) NOT NULL DEFAULT '0',
  is_email_required tinyint(1) NOT NULL DEFAULT '0',
  branchcode varchar(10) NULL DEFAULT NULL,
  date_created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_updated timestamp NULL DEFAULT NULL,
  is_deletable tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (id),
  KEY ct_branchcode (branchcode),
  CONSTRAINT `club_templates_ibfk_1` FOREIGN KEY (branchcode) REFERENCES `branches` (branchcode) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Table structure for table 'clubs'
--

CREATE TABLE IF NOT EXISTS clubs (
  id int(11) NOT NULL AUTO_INCREMENT,
  club_template_id int(11) NOT NULL,
  `name` tinytext NOT NULL,
  description text,
  date_start date DEFAULT NULL,
  date_end date DEFAULT NULL,
  branchcode varchar(10) NULL DEFAULT NULL,
  date_created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_updated timestamp NULL DEFAULT NULL,
  PRIMARY KEY (id),
  KEY club_template_id (club_template_id),
  KEY branchcode (branchcode),
  CONSTRAINT clubs_ibfk_1 FOREIGN KEY (club_template_id) REFERENCES club_templates (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT clubs_ibfk_2 FOREIGN KEY (branchcode) REFERENCES branches (branchcode)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Table structure for table 'club_enrollments'
--

CREATE TABLE IF NOT EXISTS club_enrollments (
  id int(11) NOT NULL AUTO_INCREMENT,
  club_id int(11) NOT NULL,
  borrowernumber int(11) NOT NULL,
  date_enrolled timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_canceled timestamp NULL DEFAULT NULL,
  date_created timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  date_updated timestamp NULL DEFAULT NULL,
  branchcode varchar(10) NULL DEFAULT NULL,
  PRIMARY KEY (id),
  KEY club_id (club_id),
  KEY borrowernumber (borrowernumber),
  KEY branchcode (branchcode),
  CONSTRAINT club_enrollments_ibfk_1 FOREIGN KEY (club_id) REFERENCES clubs (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT club_enrollments_ibfk_2 FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT club_enrollments_ibfk_3 FOREIGN KEY (branchcode) REFERENCES branches (branchcode) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Table structure for table 'club_template_enrollment_fields'
--

CREATE TABLE IF NOT EXISTS club_template_enrollment_fields (
  id int(11) NOT NULL AUTO_INCREMENT,
  club_template_id int(11) NOT NULL,
  `name` tinytext NOT NULL,
  description text,
  authorised_value_category varchar(16) DEFAULT NULL,
  PRIMARY KEY (id),
  KEY club_template_id (club_template_id),
  CONSTRAINT club_template_enrollment_fields_ibfk_1 FOREIGN KEY (club_template_id) REFERENCES club_templates (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Table structure for table 'club_enrollment_fields'
--

CREATE TABLE IF NOT EXISTS club_enrollment_fields (
  id int(11) NOT NULL AUTO_INCREMENT,
  club_enrollment_id int(11) NOT NULL,
  club_template_enrollment_field_id int(11) NOT NULL,
  `value` text NOT NULL,
  PRIMARY KEY (id),
  KEY club_enrollment_id (club_enrollment_id),
  KEY club_template_enrollment_field_id (club_template_enrollment_field_id),
  CONSTRAINT club_enrollment_fields_ibfk_1 FOREIGN KEY (club_enrollment_id) REFERENCES club_enrollments (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT club_enrollment_fields_ibfk_2 FOREIGN KEY (club_template_enrollment_field_id) REFERENCES club_template_enrollment_fields (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Table structure for table 'club_template_fields'
--

CREATE TABLE IF NOT EXISTS club_template_fields (
  id int(11) NOT NULL AUTO_INCREMENT,
  club_template_id int(11) NOT NULL,
  `name` tinytext NOT NULL,
  description text,
  authorised_value_category varchar(16) DEFAULT NULL,
  PRIMARY KEY (id),
  KEY club_template_id (club_template_id),
  CONSTRAINT club_template_fields_ibfk_1 FOREIGN KEY (club_template_id) REFERENCES club_templates (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Table structure for table 'club_fields'
--

CREATE TABLE IF NOT EXISTS club_fields (
  id int(11) NOT NULL AUTO_INCREMENT,
  club_template_field_id int(11) NOT NULL,
  club_id int(11) NOT NULL,
  `value` text,
  PRIMARY KEY (id),
  KEY club_template_field_id (club_template_field_id),
  KEY club_id (club_id),
  CONSTRAINT club_fields_ibfk_3 FOREIGN KEY (club_template_field_id) REFERENCES club_template_fields (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT club_fields_ibfk_4 FOREIGN KEY (club_id) REFERENCES clubs (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT IGNORE INTO userflags (bit, flag, flagdesc, defaulton) VALUES (21, 'clubs', 'Patron clubs', '0');

INSERT IGNORE INTO permissions (module_bit, code, description) VALUES
   (21, 'edit_templates', 'Create and update club templates'),
   (21, 'edit_clubs', 'Create and update clubs'),
   (21, 'enroll', 'Enroll patrons in clubs')
;
