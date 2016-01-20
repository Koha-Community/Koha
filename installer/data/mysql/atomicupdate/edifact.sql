-- Holds details for vendors supplying goods by EDI
CREATE TABLE IF NOT EXISTS vendor_edi_accounts (
  id int(11) NOT NULL auto_increment,
  description text NOT NULL,
  host varchar(40),
  username varchar(40),
  password varchar(40),
  last_activity date,
  vendor_id int(11) references aqbooksellers( id ),
  download_directory text,
  upload_directory text,
  san varchar(20),
  id_code_qualifier varchar(3) default '14',
  transport varchar(6) default 'FTP',
  quotes_enabled tinyint(1) not null default 0,
  invoices_enabled tinyint(1) not null default 0,
  orders_enabled tinyint(1) not null default 0,
  responses_enabled tinyint(1) not null default 0,
  auto_orders tinyint(1) not null default 0,
  shipment_budget integer(11) references aqbudgets( budget_id ),
  PRIMARY KEY  (id),
  KEY vendorid (vendor_id),
  KEY shipmentbudget (shipment_budget),
  CONSTRAINT vfk_vendor_id FOREIGN KEY ( vendor_id ) REFERENCES aqbooksellers ( id ),
  CONSTRAINT vfk_shipment_budget FOREIGN KEY ( shipment_budget ) REFERENCES aqbudgets ( budget_id )
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Hold the actual edifact messages with links to associated baskets
CREATE TABLE IF NOT EXISTS edifact_messages (
  id int(11) NOT NULL auto_increment,
  message_type varchar(10) NOT NULL,
  transfer_date date,
  vendor_id int(11) references aqbooksellers( id ),
  edi_acct  integer references vendor_edi_accounts( id ),
  status text,
  basketno int(11) REFERENCES aqbasket( basketno),
  raw_msg mediumtext,
  filename text,
  deleted boolean not null default 0,
  PRIMARY KEY  (id),
  KEY vendorid ( vendor_id),
  KEY ediacct (edi_acct),
  KEY basketno ( basketno),
  CONSTRAINT emfk_vendor FOREIGN KEY ( vendor_id ) REFERENCES aqbooksellers ( id ),
  CONSTRAINT emfk_edi_acct FOREIGN KEY ( edi_acct ) REFERENCES vendor_edi_accounts ( id ),
  CONSTRAINT emfk_basketno FOREIGN KEY ( basketno ) REFERENCES aqbasket ( basketno )
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- invoices link back to the edifact message it was generated from
ALTER TABLE aqinvoices ADD COLUMN message_id INT(11) REFERENCES edifact_messages( id );

-- clean up link on deletes
ALTER TABLE aqinvoices ADD CONSTRAINT edifact_msg_fk FOREIGN KEY ( message_id ) REFERENCES edifact_messages ( id ) ON DELETE SET NULL;

-- Hold the supplier ids from quotes for ordering
-- although this is an EAN-13 article number the standard says 35 characters ???
ALTER TABLE aqorders ADD COLUMN line_item_id varchar(35);

-- The suppliers unique reference usually a quotation line number ('QLI')
-- Otherwise Suppliers unique orderline reference ('SLI')
ALTER TABLE aqorders ADD COLUMN suppliers_reference_number varchar(35);
ALTER TABLE aqorders ADD COLUMN suppliers_reference_qualifier varchar(3);
ALTER TABLE aqorders ADD COLUMN suppliers_report text;

-- hold the EAN/SAN used in ordering
CREATE TABLE IF NOT EXISTS edifact_ean (
  ee_id integer(11) unsigned not null auto_increment primary key,
  branchcode VARCHAR(10) NOT NULL REFERENCES branches (branchcode),
  ean varchar(15) NOT NULL,
  id_code_qualifier VARCHAR(3) NOT NULL DEFAULT '14',
  CONSTRAINT efk_branchcode FOREIGN KEY ( branchcode ) REFERENCES branches ( branchcode )
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Syspref budget to hold shipping costs
INSERT INTO systempreferences (variable, explanation, type) VALUES('EDIInvoicesShippingBudget','The budget code used to allocate shipping charges to when processing EDI Invoice messages',  'free');

-- Add a permission for managing EDI
INSERT INTO permissions (module_bit, code, description) values (11, 'edi_manage', 'Manage EDIFACT transmissions');
