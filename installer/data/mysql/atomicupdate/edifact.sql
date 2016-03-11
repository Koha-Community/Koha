-- Holds details for vendors supplying goods by EDI
CREATE TABLE IF NOT EXISTS vendor_edi_accounts (
  id INT(11) NOT NULL auto_increment,
  description TEXT NOT NULL,
  host VARCHAR(40),
  username VARCHAR(40),
  password VARCHAR(40),
  last_activity DATE,
  vendor_id INT(11) REFERENCES aqbooksellers( id ),
  download_directory TEXT,
  upload_directory TEXT,
  san VARCHAR(20),
  id_code_qualifier VARCHAR(3) default '14',
  transport VARCHAR(6) default 'FTP',
  quotes_enabled TINYINT(1) not null default 0,
  invoices_enabled TINYINT(1) not null default 0,
  orders_enabled TINYINT(1) not null default 0,
  responses_enabled TINYINT(1) not null default 0,
  auto_orders TINYINT(1) not null default 0,
  shipment_budget INTEGER(11) REFERENCES aqbudgets( budget_id ),
  PRIMARY KEY  (id),
  KEY vendorid (vendor_id),
  KEY shipmentbudget (shipment_budget),
  CONSTRAINT vfk_vendor_id FOREIGN KEY ( vendor_id ) REFERENCES aqbooksellers ( id ),
  CONSTRAINT vfk_shipment_budget FOREIGN KEY ( shipment_budget ) REFERENCES aqbudgets ( budget_id )
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Hold the actual edifact messages with links to associated baskets
CREATE TABLE IF NOT EXISTS edifact_messages (
  id INT(11) NOT NULL auto_increment,
  message_type VARCHAR(10) NOT NULL,
  transfer_date DATE,
  vendor_id INT(11) REFERENCES aqbooksellers( id ),
  edi_acct  INTEGER REFERENCES vendor_edi_accounts( id ),
  status TEXT,
  basketno INT(11) REFERENCES aqbasket( basketno),
  raw_msg MEDIUMTEXT,
  filename TEXT,
  deleted BOOLEAN NOT NULL DEFAULT 0,
  PRIMARY KEY  (id),
  KEY vendorid ( vendor_id),
  KEY ediacct (edi_acct),
  KEY basketno ( basketno),
  CONSTRAINT emfk_vendor FOREIGN KEY ( vendor_id ) REFERENCES aqbooksellers ( id ),
  CONSTRAINT emfk_edi_acct FOREIGN KEY ( edi_acct ) REFERENCES vendor_edi_accounts ( id ),
  CONSTRAINT emfk_basketno FOREIGN KEY ( basketno ) REFERENCES aqbasket ( basketno )
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- invoices link back to the edifact message it was generated from
ALTER TABLE aqinvoices ADD COLUMN message_id INT(11) REFERENCES edifact_messages( id );

-- clean up link on deletes
ALTER TABLE aqinvoices ADD CONSTRAINT edifact_msg_fk FOREIGN KEY ( message_id ) REFERENCES edifact_messages ( id ) ON DELETE SET NULL;

-- Hold the supplier ids from quotes for ordering
-- although this is an EAN-13 article number the standard says 35 characters ???
ALTER TABLE aqorders ADD COLUMN line_item_id VARCHAR(35);

-- The suppliers unique reference usually a quotation line number ('QLI')
-- Otherwise Suppliers unique orderline reference ('SLI')
ALTER TABLE aqorders ADD COLUMN suppliers_reference_number VARCHAR(35);
ALTER TABLE aqorders ADD COLUMN suppliers_reference_qualifier VARCHAR(3);
ALTER TABLE aqorders ADD COLUMN suppliers_report text;

-- hold the EAN/SAN used in ordering
CREATE TABLE IF NOT EXISTS edifact_ean (
  ee_id int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  description VARCHAR(128) NULL DEFAULT NULL,
  branchcode VARCHAR(10) NOT NULL REFERENCES branches (branchcode),
  ean VARCHAR(15) NOT NULL,
  id_code_qualifier VARCHAR(3) NOT NULL DEFAULT '14',
  CONSTRAINT efk_branchcode FOREIGN KEY ( branchcode ) REFERENCES branches ( branchcode )
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Syspref budget to hold shipping costs
INSERT INTO systempreferences (variable, explanation, type) VALUES('EDIInvoicesShippingBudget','The budget code used to allocate shipping charges to when processing EDI Invoice messages',  'free');

-- Add a permission for managing EDI
INSERT INTO permissions (module_bit, code, description) values (11, 'edi_manage', 'Manage EDIFACT transmissions');
