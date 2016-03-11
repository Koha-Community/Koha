INSERT INTO systempreferences (variable,value,options,explanation,type)
VALUES('CheckPrevCheckout','hardno','hardyes|softyes|softno|hardno','By default, for every item checked out, should we warn if the patron has checked out that item in the past?','Choice');

ALTER TABLE categories
ADD COLUMN `checkprevcheckout` varchar(7) NOT NULL default 'inherit'
AFTER `default_privacy`;

ALTER TABLE borrowers
ADD COLUMN `checkprevcheckout` varchar(7) NOT NULL default 'inherit'
AFTER `privacy_guarantor_checkouts`;

ALTER TABLE deletedborrowers
ADD COLUMN `checkprevcheckout` varchar(7) NOT NULL default 'inherit'
AFTER `privacy_guarantor_checkouts`;
