-- PostgreSQL kohastructure script
-- Initial port 2007/10/22 fbcit
-- This is very 'alpha' at this point since much of the source will have to be mod'd to do data manipulations before it can be fully tested.
-- Many tables lack a primary key and probably need one as that is generally a good db practice.
-- **This script requires plpgsql be loaded into the pg koha db PRIOR to executing.**
-- This could be done in this script. However, the user must have superuser priviledge. I'm not sure how the koha installer handles this.

--begin;

--
-- Function to generate populate timestamp fields on update
--

CREATE FUNCTION time_stamp() RETURNS trigger AS $time_stamp$
    BEGIN
        -- Update timestamp field on row insert or update
        NEW.timestamp := current_timestamp;
        RETURN NEW;
    END;
$time_stamp$ LANGUAGE plpgsql;

COMMENT ON FUNCTION time_stamp() IS $$ This function updates the timestamp field on an insert or update. It equates to mysql 'on update CURRENT_TIMESTAMP'. $$;

-- 
-- Table structure for table accountlines
-- 

--DROP TABLE accountlines;	--Left the DROP TABLE statements here if needed for some reason...

CREATE TABLE accountlines (
borrowernumber int NOT NULL default 0,
accountno int NOT NULL default 0,
itemnumber int default NULL,
date date default NULL,
amount decimal(28,6) default NULL,
description text,
dispute text,
accounttype varchar(5) default NULL,
amountoutstanding decimal(28,6) default NULL,
"timestamp" timestamp NOT NULL default (now()),
notify_id int NOT NULL default 0,
notify_level int NOT NULL default 0
);
CREATE INDEX accountlines_itemnumber_idx ON accountlines (itemnumber);	-- Indecies replace msyql 'enums' datatype. Pg 8.3 will have 'enums' so this may be changed back later...
CREATE INDEX accountlines_acctsborr_idx ON accountlines (borrowernumber);
CREATE INDEX accountlines_time_idx ON accountlines (timestamp);

--
-- Create timestamp trigger
--

CREATE TRIGGER time_stamp BEFORE INSERT OR UPDATE ON accountlines
    FOR EACH ROW EXECUTE PROCEDURE time_stamp();

-- 
-- Table structure for table accountoffsets
-- 

--DROP TABLE accountoffsets;

CREATE TABLE accountoffsets (
borrowernumber int NOT NULL default 0,
accountno int NOT NULL default 0,
offsetaccount int NOT NULL default 0,
offsetamount decimal(28,6) default NULL,
"timestamp" timestamp NOT NULL default (now())
);


--
-- Create timestamp trigger
--

CREATE TRIGGER time_stamp BEFORE INSERT OR UPDATE ON accountoffsets
    FOR EACH ROW EXECUTE PROCEDURE time_stamp();

-- 
-- Table structure for table action_logs
-- 

--DROP TABLE action_logs;

CREATE TABLE action_logs (
"timestamp" timestamp NOT NULL default (now()),
"user" int NOT NULL default 0,
module text,
"action" text,
"object" int default NULL,
info text,
PRIMARY KEY (timestamp,"user")
);

--
-- Create timestamp trigger
--

CREATE TRIGGER time_stamp BEFORE INSERT OR UPDATE ON action_logs
    FOR EACH ROW EXECUTE PROCEDURE time_stamp();

-- 
-- Table structure for table alert
-- 

--DROP TABLE alert;

CREATE TABLE alert (
alertid BIGSERIAL,
borrowernumber int NOT NULL default 0,
"type" varchar(10) NOT NULL default '',
externalid varchar(20) NOT NULL default '',
PRIMARY KEY (alertid)
);
CREATE INDEX alert_borrowernumber_idx ON alert (borrowernumber);
CREATE INDEX alert_type_idx ON alert (type,externalid);

-- 
-- Table structure for table aqbasket
-- 

--DROP TABLE aqbasket;

CREATE TABLE aqbasket (
basketno BIGSERIAL,
creationdate date default NULL,
closedate date default NULL,
booksellerid int NOT NULL default '1',
authorisedby varchar(10) default NULL,
booksellerinvoicenumber text,
PRIMARY KEY (basketno)
);
CREATE INDEX aqbasket_booksellerid_idx ON aqbasket (booksellerid);

-- 
-- Table structure for table aqbookfund
-- 

--DROP TABLE aqbookfund;

CREATE TABLE aqbookfund (
bookfundid varchar(10) UNIQUE NOT NULL default '',
bookfundname text,
bookfundgroup varchar(5) default NULL,
branchcode varchar(10) NOT NULL default '',
PRIMARY KEY (bookfundid,branchcode)
);

-- 
-- Table structure for table aqbooksellers
-- 

--DROP TABLE aqbooksellers;

CREATE TABLE aqbooksellers (
id BIGSERIAL,
name text,
address1 text,
address2 text,
address3 text,
address4 text,
phone varchar(30) default NULL,
accountnumber text,
othersupplier text,
currency varchar(3) NOT NULL default '',
deliverydays int default NULL,
followupdays int default NULL,
followupscancel int default NULL,
specialty text,
booksellerfax text,
notes text,
bookselleremail text,
booksellerurl text,
contact varchar(100) default NULL,
postal text,
url varchar(255) default NULL,
contpos varchar(100) default NULL,
contphone varchar(100) default NULL,
contfax varchar(100) default NULL,
contaltphone varchar(100) default NULL,
contemail varchar(100) default NULL,
contnotes text,
active int default NULL,
listprice varchar(10) default NULL,
invoiceprice varchar(10) default NULL,
gstreg int default NULL,
listincgst int default NULL,
invoiceincgst int default NULL,
discount numeric(6,4) default NULL,
fax varchar(50) default NULL,
nocalc int default NULL,
invoicedisc numeric(6,4) default NULL,
PRIMARY KEY (id)
);
CREATE INDEX aqbooksellers_invoiceprice_idx ON aqbooksellers (invoiceprice);
CREATE INDEX aqbooksellers_listprice_idx ON aqbooksellers (listprice);

-- 
-- Table structure for table aqbudget
-- 

--DROP TABLE aqbudget;

CREATE TABLE aqbudget (
bookfundid varchar(10) NOT NULL default '',
startdate date default NULL,
enddate date default NULL,
budgetamount decimal(13,2) default NULL,
aqbudgetid BIGSERIAL,
branchcode varchar(10) default NULL,
PRIMARY KEY (aqbudgetid)
);

-- 
-- Table structure for table aqorderbreakdown
-- 

--DROP TABLE aqorderbreakdown;

CREATE TABLE aqorderbreakdown (
ordernumber int default NULL,
"linenumber" int default NULL,
branchcode varchar(10) default NULL,
bookfundid varchar(10) NOT NULL default '',
allocation int default NULL
);
CREATE INDEX aqorderbreakdown_bookfundid_idx ON aqorderbreakdown (bookfundid);
CREATE INDEX aqorderbreakdown_ordernumber_idx ON aqorderbreakdown (ordernumber);

-- 
-- Table structure for table aqorderdelivery
-- 

--DROP TABLE aqorderdelivery;

CREATE TABLE aqorderdelivery (
ordernumber date default NULL,
deliverynumber int NOT NULL default 0,
deliverydate varchar(18) default NULL,
qtydelivered int default NULL,
deliverycomments text
);

-- 
-- Table structure for table aqorders
-- 

--DROP TABLE aqorders;

CREATE TABLE aqorders (
ordernumber BIGSERIAL,
biblionumber int default NULL,
title text,
entrydate date default NULL,
quantity int default NULL,
currency varchar(3) default NULL,
listprice decimal(28,6) default NULL,
totalamount decimal(28,6) default NULL,
datereceived date default NULL,
booksellerinvoicenumber text,
freight decimal(28,6) default NULL,
unitprice decimal(28,6) default NULL,
quantityreceived int default NULL,
cancelledby varchar(10) default NULL,
datecancellationprinted date default NULL,
notes text,
supplierreference text,
purchaseordernumber text,
subscription int default NULL,
serialid varchar(30) default NULL,
basketno int default NULL,
biblioitemnumber int default NULL,
"timestamp" timestamp NOT NULL default (now()),
rrp decimal(13,2) default NULL,
ecost decimal(13,2) default NULL,
gst decimal(13,2) default NULL,
budgetdate date default NULL,
sort1 varchar(80) default NULL,
sort2 varchar(80) default NULL,
PRIMARY KEY (ordernumber)
);
CREATE INDEX aqorders_biblionumber_idx ON aqorders (biblionumber);
CREATE INDEX aqorders_basketno_idx ON aqorders (basketno);

-- 
-- Table structure for table auth_header
-- 

--DROP TABLE auth_header;

CREATE TABLE auth_header (
authid BIGSERIAL NOT NULL,
authtypecode varchar(10) NOT NULL default '',
datecreated date default NULL,
datemodified date default NULL,
origincode varchar(20) default NULL,
authtrees text,
marc bytea,
linkid int default NULL,
marcxml text NOT NULL,
PRIMARY KEY (authid)
);
CREATE INDEX auth_header_origincode_idx ON auth_header (origincode);

-- 
-- Table structure for table auth_subfield_structure
-- 

--DROP TABLE auth_subfield_structure;

CREATE TABLE auth_subfield_structure (
authtypecode varchar(10) NOT NULL default '',
tagfield varchar(3) NOT NULL default '',
tagsubfield varchar(1) NOT NULL default '',
liblibrarian varchar(255) NOT NULL default '',
libopac varchar(255) NOT NULL default '',
"repeatable" int NOT NULL default 0,
mandatory int NOT NULL default 0,
tab int default NULL,
authorised_value varchar(10) default NULL,
value_builder varchar(80) default NULL,
seealso varchar(255) default NULL,
isurl int default NULL,
hidden int NOT NULL default 0,
linkid int NOT NULL default 0,
kohafield varchar(45) NULL default '',
frameworkcode varchar(8) NOT NULL default '',
PRIMARY KEY (authtypecode,tagfield,tagsubfield)
);
CREATE INDEX auth_subfield_structure_tab_idx ON auth_subfield_structure (authtypecode,tab);

-- 
-- Table structure for table auth_tag_structure
-- 

--DROP TABLE auth_tag_structure;

CREATE TABLE auth_tag_structure (
authtypecode varchar(10) NOT NULL default '',
tagfield varchar(3) NOT NULL default '',
liblibrarian varchar(255) NOT NULL default '',
libopac varchar(255) NOT NULL default '',
"repeatable" int NOT NULL default 0,
mandatory int NOT NULL default 0,
authorised_value varchar(10) default NULL,
PRIMARY KEY (authtypecode,tagfield)
);

-- 
-- Table structure for table auth_types
-- 

--DROP TABLE auth_types;

CREATE TABLE auth_types (
authtypecode varchar(10) NOT NULL default '',
authtypetext varchar(255) NOT NULL default '',
auth_tag_to_report varchar(3) NOT NULL default '',
summary text NOT NULL,
PRIMARY KEY (authtypecode)
);

-- 
-- Table structure for table authorised_values
-- 

--DROP TABLE authorised_values;

CREATE TABLE authorised_values (
id BIGSERIAL,
category varchar(10) NOT NULL default '',
authorised_value varchar(80) NOT NULL default '',
lib varchar(80) default NULL,
PRIMARY KEY (id)
);
CREATE INDEX authorised_values_name_idx ON authorised_values (category);

-- 
-- Table structure for table biblio
-- 

--DROP TABLE biblio;

CREATE TABLE biblio (
biblionumber int NOT NULL default 0,
frameworkcode varchar(4) NOT NULL default '',
author text,
title text,
unititle text,
notes text,
serial int default NULL,
seriestitle text,
copyrightdate int default NULL,
"timestamp" timestamp NOT NULL default (now()),
datecreated DATE NOT NULL,
abstract text,
PRIMARY KEY (biblionumber)
);
CREATE INDEX biblio_blbnoidx_idx ON biblio (biblionumber);

-- 
-- Table structure for table biblio_framework
-- 

--DROP TABLE biblio_framework;

CREATE TABLE biblio_framework (
frameworkcode varchar(4) NOT NULL default '',
frameworktext varchar(255) NOT NULL default '',
PRIMARY KEY (frameworkcode)
);

-- 
-- Table structure for table biblioitems
-- 

--DROP TABLE biblioitems;

CREATE TABLE biblioitems (
biblioitemnumber int NOT NULL default 0,
biblionumber int NOT NULL default 0,
volume text,
number text,
classification varchar(25) default NULL,
itemtype varchar(10) default NULL,
isbn varchar(14) default NULL,
issn varchar(9) default NULL,
dewey varchar(30) default '',
subclass varchar(3) default NULL,
publicationyear text,
publishercode varchar(255) default NULL,
volumedate date default NULL,
volumeddesc text,
collectiontitle text default NULL,
collectionissn text default NULL,
collectionvolume text default NULL,
editionstatement text default NULL,
editionresponsibility text default NULL,
"timestamp" timestamp NOT NULL default (now()),
illus varchar(255) default NULL,
pages varchar(255) default NULL,
notes text,
size varchar(255) default NULL,
place varchar(255) default NULL,
lccn varchar(25) default NULL,
marc bytea,
url varchar(255) default NULL,
lcsort varchar(25) default NULL,
ccode varchar(4) default NULL,
marcxml text NOT NULL,
PRIMARY KEY (biblioitemnumber)
);
CREATE INDEX biblioitems_publishercode_idx ON biblioitems (publishercode);
CREATE INDEX biblioitems_biblioitemnumber_idx ON biblioitems (biblioitemnumber);
CREATE INDEX biblioitems_biblionumber_idx ON biblioitems (biblionumber);
CREATE INDEX biblioitems_isbn_idx ON biblioitems (isbn);

-- 
-- Table structure for table borrowers
-- 

--DROP TABLE borrowers;

CREATE TABLE borrowers (
borrowernumber BIGSERIAL UNIQUE,
cardnumber varchar(16) UNIQUE default NULL,
surname text NOT NULL,
firstname text,
title text,
othernames text,
initials text,
streetnumber varchar(10) default NULL,
streettype varchar(50) default NULL,
address text NOT NULL,
address2 text,
city text NOT NULL,
zipcode varchar(25) default NULL,
email text,
phone text,
mobile varchar(50) default NULL,
fax text,
emailpro text,
phonepro text,
B_streetnumber varchar(10) default NULL,
B_streettype varchar(50) default NULL,
B_address varchar(100) default NULL,
B_city text,
B_zipcode varchar(25) default NULL,
B_email text,
B_phone text,
dateofbirth date default NULL,
branchcode varchar(10) NOT NULL default '',
categorycode varchar(10) NOT NULL default '',
dateenrolled date default NULL,
dateexpiry date default NULL,
gonenoaddress int default NULL,
lost int default NULL,
debarred int default NULL,
contactname text,
contactfirstname text,
contacttitle text,
guarantorid int default NULL,
borrowernotes text,
relationship varchar(100) default NULL,
ethnicity varchar(50) default NULL,
ethnotes varchar(255) default NULL,
sex varchar(1) default NULL,
"password" varchar(30) default NULL,
flags int default NULL,
userid varchar(30) default NULL,
opacnote text,
contactnote varchar(255) default NULL,
sort1 varchar(80) default NULL,
sort2 varchar(80) default NULL
);
CREATE INDEX borrowers_branchcode_idx ON borrowers (branchcode);
CREATE INDEX borrowers_borrowernumber_idx ON borrowers (borrowernumber);
CREATE INDEX borrowers_categorycode_idx ON borrowers (categorycode);

-- 
-- Table structure for table branchcategories
-- 

--DROP TABLE branchcategories;

CREATE TABLE branchcategories (
categorycode varchar(4) NOT NULL default '',
categoryname text,
codedescription text,
PRIMARY KEY (categorycode)
);

-- 
-- Table structure for table branches
-- 

--DROP TABLE branches;

CREATE TABLE branches (
branchcode varchar(10) UNIQUE NOT NULL default '',
branchname text NOT NULL,
branchaddress1 text,
branchaddress2 text,
branchaddress3 text,
branchphone text,
branchfax text,
branchemail text,
issuing int default NULL,
branchip varchar(15) default NULL,
branchprinter varchar(100) default NULL
);

-- 
-- Table structure for table branchrelations
-- 

--DROP TABLE branchrelations;

CREATE TABLE branchrelations (
branchcode varchar(10) NOT NULL default '',
categorycode varchar(4) NOT NULL default '',
PRIMARY KEY (branchcode,categorycode)
);
CREATE INDEX branchrelations_categorycode_idx ON branchrelations (categorycode);
CREATE INDEX branchrelations_branchcode_idx ON branchrelations (branchcode);

-- 
-- Table structure for table branchtransfers
-- 

--DROP TABLE branchtransfers;

CREATE TABLE branchtransfers (
itemnumber int NOT NULL default 0,
datesent timestamp default NULL,
frombranch varchar(10) NOT NULL default '',
datearrived timestamp default NULL,
tobranch varchar(10) NOT NULL default '',
comments text
);
CREATE INDEX branchtransfers_frombranch_idx ON branchtransfers (frombranch);
CREATE INDEX branchtransfers_tobranch_idx ON branchtransfers (tobranch);
CREATE INDEX branchtransfers_itemnumber_idx ON branchtransfers (itemnumber);

-- 
-- Table structure for table browser
-- 
--DROP TABLE browser;

CREATE TABLE browser (
level int NOT NULL,
classification varchar(20) NOT NULL,
description varchar(255) NOT NULL,
number int NOT NULL,
endnode int NOT NULL
);

-- 
-- Table structure for table categories
-- 

--DROP TABLE categories;

CREATE TABLE categories (
categorycode varchar(10) UNIQUE NOT NULL default '',
description text,
enrolmentperiod int default NULL,
upperagelimit int default NULL,
dateofbirthrequired int default NULL,
finetype varchar(30) default NULL,
bulk int default NULL,
enrolmentfee decimal(28,6) default NULL,
overduenoticerequired int default NULL,
issuelimit int default NULL,
reservefee decimal(28,6) default NULL,
category_type varchar(1) NOT NULL default 'A',
PRIMARY KEY (categorycode)
);

-- 
-- Table structure for table cities
-- 

--DROP TABLE cities;

CREATE TABLE cities (
cityid BIGSERIAL,
city_name varchar(100) NOT NULL default '',
city_zipcode varchar(20) default NULL,
PRIMARY KEY (cityid)
);

--
-- Table structure for table class_sort_rules
--

CREATE TABLE class_sort_rules (
  class_sort_rule varchar(10) UNIQUE NOT NULL default '',
  description text,
  sort_routine varchar(30) NOT NULL default '',
  PRIMARY KEY (class_sort_rule)
);
CREATE INDEX class_sort_rule_idx ON class_sort_rules (class_sort_rule); 

--
-- Table structure for table class_sources
--

CREATE TABLE class_sources (
  cn_source varchar(10) NOT NULL default '',
  description text,
  used int NOT NULL default 0,
  class_sort_rule varchar(10) NOT NULL default '',
  PRIMARY KEY (cn_source)
--  This seems redundant -fbcit
--  UNIQUE KEY cn_source_idx (cn_source),
);
CREATE INDEX used_idx ON class_sources (used);

-- 
-- Table structure for table currency
-- 

--DROP TABLE currency;

CREATE TABLE currency (
currency varchar(10) NOT NULL default '',
rate numeric(7,5) default NULL,
PRIMARY KEY (currency)
);

-- 
-- Table structure for table deletedbiblio
-- 

--DROP TABLE deletedbiblio;

CREATE TABLE deletedbiblio (
biblionumber int NOT NULL default 0,
frameworkcode varchar(4) NOT NULL,
author text,
title text,
unititle text,
notes text,
serial int default NULL,
seriestitle text,
copyrightdate int default NULL,
"timestamp" timestamp NOT NULL default (now()),
marc bytea,
abstract text,
PRIMARY KEY (biblionumber)
);
CREATE INDEX deletedbiblio_blbnoidx_idx ON deletedbiblio (biblionumber);

-- 
-- Table structure for table deletedbiblioitems
-- 

--DROP TABLE deletedbiblioitems;

CREATE TABLE deletedbiblioitems (
biblioitemnumber int NOT NULL default 0,
biblionumber int NOT NULL default 0,
volume text,
number text,
classification varchar(25) default NULL,
itemtype varchar(10) default NULL,
isbn varchar(14) default NULL,
issn varchar(9) default NULL,
dewey numeric(8,6) default NULL,
subclass varchar(3) default NULL,
publicationyear int default NULL,
publishercode varchar(255) default NULL,
volumedate date default NULL,
volumeddesc varchar(255) default NULL,
"timestamp" timestamp NOT NULL default (now()),
illus varchar(255) default NULL,
pages varchar(255) default NULL,
notes text,
size varchar(255) default NULL,
lccn varchar(25) default NULL,
marc text,
url varchar(255) default NULL,
place varchar(255) default NULL,
lcsort varchar(25) default NULL,
ccode varchar(4) default NULL,
marcxml text NOT NULL,
collectiontitle text,
collectionissn text,
collectionvolume text,
editionstatement text,
editionresponsibility text,
PRIMARY KEY (biblioitemnumber)
);
CREATE INDEX deletedbiblioitems_biblioitemnumber_idx ON deletedbiblioitems (biblioitemnumber);
CREATE INDEX deletedbiblioitems_biblionumber_idx ON deletedbiblioitems (biblionumber);

-- 
-- Table structure for table deletedborrowers
-- 

--DROP TABLE deletedborrowers;

CREATE TABLE deletedborrowers (
borrowernumber int NOT NULL default 0,
cardnumber varchar(9) NOT NULL default '',
surname text NOT NULL,
firstname text,
title text,
othernames text,
initials text,
streetnumber varchar(10) default NULL,
streettype varchar(50) default NULL,
address text NOT NULL,
address2 text,
city text NOT NULL,
zipcode varchar(25) default NULL,
email text,
phone text,
mobile varchar(50) default NULL,
fax text,
emailpro text,
phonepro text,
B_streetnumber varchar(10) default NULL,
B_streettype varchar(50) default NULL,
B_address varchar(100) default NULL,
B_city text,
B_zipcode varchar(25) default NULL,
B_email text,
B_phone text,
dateofbirth date default NULL,
branchcode varchar(10) NOT NULL default '',
categorycode varchar(2) default NULL,
dateenrolled date default NULL,
dateexpiry date default NULL,
gonenoaddress int default NULL,
lost int default NULL,
debarred int default NULL,
contactname text,
contactfirstname text,
contacttitle text,
guarantorid int default NULL,
borrowernotes text,
relationship varchar(100) default NULL,
ethnicity varchar(50) default NULL,
ethnotes varchar(255) default NULL,
sex varchar(1) default NULL,
"password" varchar(30) default NULL,
flags int default NULL,
userid varchar(30) default NULL,
opacnote text,
contactnote varchar(255) default NULL,
sort1 varchar(80) default NULL,
sort2 varchar(80) default NULL
);
CREATE INDEX deletedborrowers_borrowernumber_idx ON deletedborrowers (borrowernumber);
CREATE INDEX deletedborrowers_cardnumber_idx ON deletedborrowers (cardnumber);

-- 
-- Table structure for table deleteditems
-- 

--DROP TABLE deleteditems;

CREATE TABLE deleteditems (
itemnumber int NOT NULL default 0,
biblionumber int NOT NULL default 0,
biblioitemnumber int NOT NULL default 0,
barcode varchar(9) UNIQUE NOT NULL default '',
dateaccessioned date default NULL,
booksellerid varchar(10) default NULL,
homebranch varchar(4) default NULL,
price decimal(28,6) default NULL,
replacementprice decimal(28,6) default NULL,
replacementpricedate date default NULL,
datelastborrowed date default NULL,
datelastseen date default NULL,
stack int default NULL,
notforloan int default NULL,
damaged int default NULL,
itemlost int default NULL,
wthdrawn int default NULL,
bulk varchar(30) default NULL,
issues int default NULL,
renewals int default NULL,
reserves int default NULL,
restricted int default NULL,
itemnotes text,
holdingbranch varchar(4) default NULL,
interim int default NULL,
"timestamp" timestamp NOT NULL default (now()),
marc bytea,
paidfor text,
"location" varchar(80) default NULL,
itemcallnumber varchar(30) default NULL,
onloan date default NULL,
cutterextra varchar(45) default NULL,
itype varchar(10) default NULL,
PRIMARY KEY (itemnumber)
);
CREATE INDEX deleteditems_barcode_idx ON deleteditems (barcode);
CREATE INDEX deleteditems_biblioitemnumber_idx ON deleteditems (biblioitemnumber);
CREATE INDEX deleteditems_itembibnoidx_idx ON deleteditems (biblionumber);

-- 
-- Table structure for table ethnicity
-- 

--DROP TABLE ethnicity;

CREATE TABLE ethnicity (
code varchar(10) NOT NULL default '',
name varchar(255) default NULL,
PRIMARY KEY (code)
);

-- 
-- Table structure for table issues
-- 

--DROP TABLE issues;

CREATE TABLE issues (
borrowernumber int default NULL,
itemnumber int default NULL,
date_due date default NULL,
branchcode varchar(10) default NULL,
issuingbranch varchar(18) default NULL,
returndate date default NULL,
lastreneweddate date default NULL,
return varchar(4) default NULL,
renewals int default NULL,
"timestamp" timestamp NOT NULL default (now()),
issuedate date default NULL
);
CREATE INDEX issues_borrowernumber_idx ON issues (borrowernumber);
CREATE INDEX issues_itemnumber_idx ON issues (itemnumber);
CREATE INDEX issues_bordate_idx ON issues (borrowernumber,timestamp);

-- 
-- Table structure for table issuingrules
-- 

--DROP TABLE issuingrules;

CREATE TABLE issuingrules (
categorycode varchar(10) NOT NULL default '',
itemtype varchar(10) NOT NULL default '',
restrictedtype int default NULL,
rentaldiscount decimal(28,6) default NULL,
reservecharge decimal(28,6) default NULL,
fine decimal(28,6) default NULL,
firstremind int default NULL,
chargeperiod int default NULL,
accountsent int default NULL,
chargename varchar(100) default NULL,
maxissueqty int default NULL,
issuelength int default NULL,
branchcode varchar(10) NOT NULL default '',
PRIMARY KEY (branchcode,categorycode,itemtype)
);
CREATE INDEX issuingrules_categorycode_idx ON issuingrules (categorycode);
CREATE INDEX issuingrules_itemtype_idx ON issuingrules (itemtype);

-- 
-- Table structure for table items
-- 

--DROP TABLE items;

CREATE TABLE items (
itemnumber int NOT NULL default 0,
biblionumber int NOT NULL default 0,
biblioitemnumber int NOT NULL default 0,
barcode varchar(20) default NULL,
dateaccessioned date default NULL,
booksellerid varchar(10) default NULL,
homebranch varchar(4) default NULL,
price decimal(8,2) default NULL,
replacementprice decimal(8,2) default NULL,
replacementpricedate date default NULL,
datelastborrowed date default NULL,
datelastseen date default NULL,
stack int default NULL,
notforloan int default NULL,
damaged int default NULL,
itemlost int default NULL,
wthdrawn int default NULL,
itemcallnumber varchar(30) default NULL,
issues int default NULL,
renewals int default NULL,
reserves int default NULL,
restricted int default NULL,
itemnotes text,
holdingbranch varchar(10) default NULL,
paidfor text,
"timestamp" timestamp NOT NULL default (now()),
"location" varchar(80) default NULL,
onloan date default NULL,
cutterextra varchar(45) default NULL,
itype varchar(10) default NULL,
PRIMARY KEY (itemnumber)
);
CREATE INDEX items_barcode_idx ON items (barcode);
CREATE INDEX items_biblioitemnumber_idx ON items (biblioitemnumber);
CREATE INDEX items_biblionumber_idx ON items (biblionumber);
CREATE INDEX items_homebranch_idx ON items (homebranch);
CREATE INDEX items_holdingbranch_idx ON items (holdingbranch);

-- 
-- Table structure for table itemtypes
-- 

--DROP TABLE itemtypes;

CREATE TABLE itemtypes (
itemtype varchar(10) UNIQUE NOT NULL default '',
description text,
renewalsallowed int default NULL,
rentalcharge numeric(16,4) default NULL,
notforloan int default NULL,
imageurl varchar(200) default NULL,
summary text,
PRIMARY KEY (itemtype)
);

-- 
-- Table structure for table labels
-- 

--DROP TABLE labels;

CREATE TABLE labels (
labelid BIGSERIAL UNIQUE NOT NULL,
batch_id varchar(10) NOT NULL default '1',
itemnumber varchar(100) NOT NULL default '',
"timestamp" timestamp NOT NULL default (now()),
PRIMARY KEY (labelid)
);

-- 
-- Table structure for table labels_conf
-- 

--DROP TABLE labels_conf;

CREATE TABLE labels_conf (
id BIGSERIAL UNIQUE NOT NULL,
barcodetype varchar(100) default '',
title int default '0',
itemtype int default '0',
barcode int default '0',
dewey int default '0',
"class" int default '0',
subclass int default '0',
itemcallnumber int default '0',
author int default '0',
issn int default '0',
isbn int default '0',
startlabel int NOT NULL default '1',
printingtype varchar(32) default 'BAR',
layoutname varchar(20) NOT NULL default 'TEST',
guidebox int default '0',
active int default '1',
fonttype varchar(10) default NULL,
subtitle int default NULL,
PRIMARY KEY (id)
);

-- 
-- Table structure for table labels_templates
-- 

--DROP TABLE labels_templates;

CREATE TABLE labels_templates (
tmpl_id BIGSERIAL UNIQUE NOT NULL,
tmpl_code varchar(100) default '',
tmpl_desc varchar(100) default '',
page_width float default '0',
page_height float default '0',
label_width float default '0',
label_height float default '0',
topmargin float default '0',
leftmargin float default '0',
cols int default '0',
"rows" int default '0',
colgap float default '0',
rowgap float default '0',
active int default NULL,
units varchar(20) default 'PX',
fontsize int NOT NULL default '3',
PRIMARY KEY (tmpl_id)
);

-- 
-- Table structure for table letter
-- 

--DROP TABLE letter;

CREATE TABLE letter (
module varchar(20) NOT NULL default '',
code varchar(20) NOT NULL default '',
name varchar(100) NOT NULL default '',
title varchar(200) NOT NULL default '',
content text,
PRIMARY KEY (module,code)
);

-- 
-- Table structure for table marc_breeding
-- 

--DROP TABLE marc_breeding;

CREATE TABLE marc_breeding (
id BIGSERIAL,
file varchar(80) NOT NULL default '',
isbn varchar(10) NOT NULL default '',
title varchar(128) default NULL,
author varchar(80) default NULL,
marc bytea,
"encoding" varchar(40) NOT NULL default '',
z3950random varchar(40) default NULL,
PRIMARY KEY (id)
);
CREATE INDEX marc_breeding_title_idx ON marc_breeding (title);
CREATE INDEX marc_breeding_isbn_idx ON marc_breeding (isbn);

-- 
-- Table structure for table marc_subfield_structure
-- 

--DROP TABLE marc_subfield_structure;

CREATE TABLE marc_subfield_structure (
tagfield varchar(3) NOT NULL default '',
tagsubfield varchar(1) NOT NULL default '',
liblibrarian varchar(255) NOT NULL default '',
libopac varchar(255) NOT NULL default '',
"repeatable" int NOT NULL default 0,
mandatory int NOT NULL default 0,
kohafield varchar(40) default NULL,
tab int default NULL,
authorised_value varchar(20) default NULL,
authtypecode varchar(20) default NULL,
value_builder varchar(80) default NULL,
isurl int default NULL,
hidden int default NULL,
frameworkcode varchar(4) NOT NULL default '',
seealso varchar(1100) default NULL,
link varchar(80) default NULL,
defaultvalue text default NULL,
PRIMARY KEY (frameworkcode,tagfield,tagsubfield)
);
CREATE INDEX marc_subfield_structure_kohafield_2_idx ON marc_subfield_structure (kohafield);
CREATE INDEX marc_subfield_structure_tab_idx ON marc_subfield_structure (frameworkcode,tab);
CREATE INDEX marc_subfield_structure_kohafield_idx ON marc_subfield_structure (frameworkcode,kohafield);

-- 
-- Table structure for table marc_tag_structure
-- 

--DROP TABLE marc_tag_structure;

CREATE TABLE marc_tag_structure (
tagfield varchar(3) NOT NULL default '',
liblibrarian varchar(255) NOT NULL default '',
libopac varchar(255) NOT NULL default '',
"repeatable" int NOT NULL default 0,
mandatory int NOT NULL default 0,
authorised_value varchar(10) default NULL,
frameworkcode varchar(4) NOT NULL default '',
PRIMARY KEY (frameworkcode,tagfield)
);

-- 
-- Table structure for table notifys
-- 

--DROP TABLE notifys;

CREATE TABLE notifys (
notify_id int NOT NULL default 0,
borrowernumber int NOT NULL default 0,
itemnumber int NOT NULL default 0,
notify_date date default NULL,
notify_send_date date default NULL,
notify_level int NOT NULL default 0,
method varchar(20) NOT NULL default ''
);

-- 
-- Table structure for table nozebra
-- 
CREATE TABLE nozebra (
server varchar(20) NOT NULL,
indexname varchar(40) NOT NULL,
value varchar(250) NOT NULL,
biblionumbers text NOT NULL
);
CREATE INDEX nozebra_indexname_idx ON nozebra (server,indexname);
CREATE INDEX nozebra_value_idx ON nozebra (server,value);

-- 
-- Table structure for table opac_news
-- 

--DROP TABLE opac_news;

CREATE TABLE opac_news (
idnew SERIAL NOT NULL,
title varchar(250) NOT NULL default '',
"new" text NOT NULL,
lang varchar(4) NOT NULL default '',
"timestamp" timestamp NOT NULL default CURRENT_TIMESTAMP,
expirationdate date default NULL,
number int default NULL,
PRIMARY KEY (idnew)
);

-- 
-- Table structure for table overduerules
-- 

--DROP TABLE overduerules;

CREATE TABLE overduerules (
branchcode varchar(10) NOT NULL default '',
categorycode varchar(2) NOT NULL default '',
delay1 int default 0,
letter1 varchar(20) default NULL,
debarred1 varchar(1) default 0,
delay2 int default 0,
debarred2 varchar(1) default 0,
letter2 varchar(20) default NULL,
delay3 int default 0,
letter3 varchar(20) default NULL,
debarred3 int default 0,
PRIMARY KEY (branchcode,categorycode)
);

-- 
-- Table structure for table printers
-- 

--DROP TABLE printers;

CREATE TABLE printers (
printername varchar(40) NOT NULL default '',
printqueue varchar(20) default NULL,
printtype varchar(20) default NULL,
PRIMARY KEY (printername)
);

-- 
-- Table structure for table repeatable_holidays
-- 

--DROP TABLE repeatable_holidays;

CREATE TABLE repeatable_holidays (
id BIGSERIAL,
branchcode varchar(10) NOT NULL default '',
weekday int default NULL,
"day" int default NULL,
"month" int default NULL,
title varchar(50) NOT NULL default '',
description text NOT NULL,
PRIMARY KEY (id)
);

-- 
-- Table structure for table reserveCONSTRAINTs
-- 

--DROP TABLE reserveCONSTRAINTs;

CREATE TABLE reserveCONSTRAINTs (
borrowernumber int NOT NULL default 0,
reservedate date default NULL,
biblionumber int NOT NULL default 0,
biblioitemnumber int default NULL,
"timestamp" timestamp NOT NULL default (now())
);

-- 
-- Table structure for table reserves
-- 

--DROP TABLE reserves;

CREATE TABLE reserves (
borrowernumber int NOT NULL default 0,
reservedate date default NULL,
biblionumber int NOT NULL default 0,
CONSTRAINTtype varchar(1) default NULL,
branchcode varchar(10) default NULL,
notificationdate date default NULL,
reminderdate date default NULL,
cancellationdate date default NULL,
reservenotes text,
priority int default NULL,
found varchar(1) default NULL,
"timestamp" timestamp NOT NULL default (now()),
itemnumber int default NULL,
waitingdate date default NULL
);
CREATE INDEX reserves_borrowernumber_idx ON reserves (borrowernumber);
CREATE INDEX reserves_biblionumber__idx ON reserves (biblionumber);
CREATE INDEX reserves_itemnumber__idx ON reserves (itemnumber);
CREATE INDEX reserves_branchcode_idx ON reserves (branchcode);

-- 
-- Table structure for table reviews
-- 

--DROP TABLE reviews;

CREATE TABLE reviews (
reviewid BIGSERIAL,
borrowernumber int default NULL,
biblionumber int default NULL,
review text,
approved int default NULL,
datereviewed timestamp default NULL,
PRIMARY KEY (reviewid)
);

-- 
-- Table structure for table roadtype
-- 

--DROP TABLE roadtype;

CREATE TABLE roadtype (
roadtypeid BIGSERIAL,
road_type varchar(100) NOT NULL default '',
PRIMARY KEY (roadtypeid)
);

-- 
-- Table structure for table serial
-- 

--DROP TABLE serial;

CREATE TABLE serial (
serialid BIGSERIAL,
biblionumber varchar(100) NOT NULL default '',
subscriptionid varchar(100) NOT NULL default '',
serialseq varchar(100) NOT NULL default '',
status int NOT NULL default 0,
planneddate date default NULL,
notes text,
publisheddate date default NULL,
itemnumber text,
claimdate date default NULL,
routingnotes text,
PRIMARY KEY (serialid)
);

-- 
-- Table structure for table sessions
-- 

--DROP TABLE sessions;

CREATE TABLE sessions (
id varchar(32) UNIQUE NOT NULL,
a_session text NOT NULL
);

-- 
-- Table structure for table special_holidays
-- 

--DROP TABLE special_holidays;

CREATE TABLE special_holidays (
id BIGSERIAL,
branchcode varchar(10) NOT NULL default '',
"day" int NOT NULL default 0,
"month" int NOT NULL default 0,
"year" int NOT NULL default 0,
isexception int NOT NULL default '1',
title varchar(50) NOT NULL default '',
description text NOT NULL,
PRIMARY KEY (id)
);

-- 
-- Table structure for table statistics
-- 

--DROP TABLE statistics;

CREATE TABLE statistics (
datetime timestamp default NULL,
"timestamp" timestamp default NULL,
branch varchar(10) default NULL,
proccode varchar(4) default NULL,
value numeric(16,4) default NULL,
"type" varchar(16) default NULL,
other text,
usercode varchar(10) default NULL,
itemnumber int default NULL,
itemtype varchar(10) default NULL,
borrowernumber int default NULL,
associatedborrower int default NULL
);
CREATE INDEX statistics_timeidx_idx ON statistics (datetime);

-- 
-- Table structure for table stopwords
-- 

--DROP TABLE stopwords;

CREATE TABLE stopwords (
word varchar(255) default NULL
);

-- 
-- Table structure for table subscription
-- 

--DROP TABLE subscription;

CREATE TABLE subscription (
biblionumber int NOT NULL default 0,
subscriptionid BIGSERIAL,
librarian varchar(100) default '',
startdate date default NULL,
aqbooksellerid int default 0,
cost int default 0,
aqbudgetid int default 0,
weeklength int default 0,
monthlength int default 0,
numberlength int default 0,
periodicity int default 0,
dow varchar(100) default '',
numberingmethod varchar(100) default '',
notes text,
status varchar(100) NOT NULL default '',
add1 int default 0,
every1 int default 0,
whenmorethan1 int default 0,
setto1 int default NULL,
lastvalue1 int default NULL,
add2 int default 0,
every2 int default 0,
whenmorethan2 int default 0,
setto2 int default NULL,
lastvalue2 int default NULL,
add3 int default 0,
every3 int default 0,
innerloop1 int default 0,
innerloop2 int default 0,
innerloop3 int default 0,
whenmorethan3 int default 0,
setto3 int default NULL,
lastvalue3 int default NULL,
issuesatonce int NOT NULL default '1',
firstacquidate date default NULL,
manualhistory int NOT NULL default 0,
irregularity text,
letter varchar(20) default NULL,
numberpattern int default 0,
distributedto text,
internalnotes text,
callnumber text,
branchcode varchar(10) NOT NULL default '',
hemisphere int default 0,
PRIMARY KEY (subscriptionid)
);

-- 
-- Table structure for table subscriptionhistory
-- 

--DROP TABLE subscriptionhistory;

CREATE TABLE subscriptionhistory (
biblionumber int NOT NULL default 0,
subscriptionid int NOT NULL default 0,
histstartdate date default NULL,
enddate date default NULL,
missinglist text NOT NULL,
recievedlist text NOT NULL,
opacnote varchar(150) NOT NULL default '',
librariannote varchar(150) NOT NULL default '',
PRIMARY KEY (subscriptionid)
);
CREATE INDEX subscriptionhistory_biblionumber_idx ON subscriptionhistory (biblionumber);

-- 
-- Table structure for table subscriptionroutinglist
-- 

--DROP TABLE subscriptionroutinglist;

CREATE TABLE subscriptionroutinglist (
routingid BIGSERIAL,
borrowernumber int default NULL,
ranking int default NULL,
subscriptionid int default NULL,
PRIMARY KEY (routingid)
);

-- 
-- Table structure for table suggestions
-- 

--DROP TABLE suggestions;

CREATE TABLE suggestions (
suggestionid BIGSERIAL,
suggestedby int NOT NULL default 0,
managedby int default NULL,
STATUS varchar(10) NOT NULL default '',
note text,
author varchar(80) default NULL,
title varchar(80) default NULL,
copyrightdate int default NULL,
publishercode varchar(255) default NULL,
date timestamp NOT NULL default (now()),
volumedesc varchar(255) default NULL,
publicationyear int default 0,
place varchar(255) default NULL,
isbn varchar(10) default NULL,
mailoverseeing int default 0,
biblionumber int default NULL,
reason text,
PRIMARY KEY (suggestionid)
);
CREATE INDEX suggestions_suggestedby_idx ON suggestions (suggestedby);
CREATE INDEX suggestions_managedby_idx ON suggestions (managedby);

-- 
-- Table structure for table systempreferences
-- 

--DROP TABLE systempreferences;

CREATE TABLE systempreferences (
variable varchar(50) NOT NULL default '',
value text,
options text,
explanation text,
type varchar(20) default NULL,
PRIMARY KEY (variable)
);

-- 
-- Table structure for table tags
-- 

--DROP TABLE tags;

CREATE TABLE tags (
entry varchar(255) NOT NULL default '',
weight int NOT NULL default 0,
PRIMARY KEY (entry)
);

-- 
-- Table structure for table userflags
-- 

--DROP TABLE userflags;

CREATE TABLE userflags (
"bit" int NOT NULL default 0,
flag varchar(30) default NULL,
flagdesc varchar(255) default NULL,
defaulton int default NULL,
PRIMARY KEY (bit)
);

-- 
-- Table structure for table virtualshelves
-- 

--DROP TABLE virtualshelves;

CREATE TABLE virtualshelves (
shelfnumber BIGSERIAL,
shelfname varchar(255) default NULL,
"owner" varchar(80) default NULL,
category varchar(1) default NULL,
PRIMARY KEY (shelfnumber)
);

-- 
-- Table structure for table virtualshelfcontents
-- 

--DROP TABLE virtualshelfcontents;

CREATE TABLE virtualshelfcontents (
shelfnumber int NOT NULL default 0,
biblionumber int NOT NULL default 0,
flags int default NULL,
dateadded timestamp NULL default NULL
);
CREATE INDEX virtualshelfcontents_shelfnumber_idx ON virtualshelfcontents (shelfnumber);
CREATE INDEX virtualshelfcontents_biblionumber_idx ON virtualshelfcontents (biblionumber);

-- 
-- Table structure for table z3950servers
-- 

--DROP TABLE z3950servers;

CREATE TABLE z3950servers (
host varchar(255) default NULL,
port int default NULL,
db varchar(255) default NULL,
userid varchar(255) default NULL,
"password" varchar(255) default NULL,
name text,
id BIGSERIAL,
checked int default NULL,
rank int default NULL,
syntax varchar(80) default NULL,
icon text,
"position" varchar(10) NOT NULL default 'primary',
"type" varchar(10) NOT NULL default 'zed',
description text NOT NULL,
CHECK ( position IN ('primary', 'secondary', '' )),
CHECK ( type IN ('zed', 'opensearch', '' )),
PRIMARY KEY (id)
);

-- 
-- Table structure for table zebraqueue
-- 

--DROP TABLE zebraqueue;

CREATE TABLE zebraqueue (
id BIGSERIAL,
biblio_auth_number int NOT NULL default 0,
operation varchar(20) NOT NULL default '',
server varchar(20) NOT NULL default '',
PRIMARY KEY (id)
);

--
-- Add FK's last... (just because...)
--

ALTER TABLE accountlines ADD CONSTRAINT accountlines_ibfk_1 FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) MATCH SIMPLE ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE accountlines ADD CONSTRAINT accountlines_ibfk_2 FOREIGN KEY (itemnumber) REFERENCES items (itemnumber) ON DELETE SET NULL ON UPDATE SET NULL;

-- Added this FK based on the FK in other tables referencing borrowers.borrowernumber  -fbcit

ALTER TABLE accountoffsets ADD CONSTRAINT accountoffsets_ibfk_1 FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

--

ALTER TABLE aqbasket ADD CONSTRAINT aqbasket_ibfk_1 FOREIGN KEY (booksellerid) REFERENCES aqbooksellers (id) ON UPDATE CASCADE;
ALTER TABLE aqbooksellers ADD CONSTRAINT aqbooksellers_ibfk_1 FOREIGN KEY (listprice) REFERENCES currency (currency) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE aqbooksellers ADD CONSTRAINT aqbooksellers_ibfk_2 FOREIGN KEY (invoiceprice) REFERENCES currency (currency) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE aqorderbreakdown ADD CONSTRAINT aqorderbreakdown_ibfk_1 FOREIGN KEY (ordernumber) REFERENCES aqorders (ordernumber) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE aqorderbreakdown ADD CONSTRAINT aqorderbreakdown_ibfk_2 FOREIGN KEY (bookfundid) REFERENCES aqbookfund (bookfundid) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE aqorders ADD CONSTRAINT aqorders_ibfk_1 FOREIGN KEY (basketno) REFERENCES aqbasket (basketno) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE aqorders ADD CONSTRAINT aqorders_ibfk_2 FOREIGN KEY (biblionumber) REFERENCES biblio (biblionumber) ON DELETE SET NULL ON UPDATE SET NULL;
ALTER TABLE auth_tag_structure ADD CONSTRAINT auth_tag_structure_ibfk_1 FOREIGN KEY (authtypecode) REFERENCES auth_types (authtypecode) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE biblioitems ADD CONSTRAINT biblioitems_ibfk_1 FOREIGN KEY (biblionumber) REFERENCES biblio (biblionumber) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE borrowers ADD CONSTRAINT borrowers_ibfk_1 FOREIGN KEY (categorycode) REFERENCES categories (categorycode);
ALTER TABLE borrowers ADD CONSTRAINT borrowers_ibfk_2 FOREIGN KEY (branchcode) REFERENCES branches (branchcode);
ALTER TABLE branchrelations ADD CONSTRAINT branchrelations_ibfk_1 FOREIGN KEY (branchcode) REFERENCES branches (branchcode) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE branchrelations ADD CONSTRAINT branchrelations_ibfk_2 FOREIGN KEY (categorycode) REFERENCES branchcategories (categorycode) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE branchtransfers ADD CONSTRAINT branchtransfers_ibfk_1 FOREIGN KEY (frombranch) REFERENCES branches (branchcode) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE branchtransfers ADD CONSTRAINT branchtransfers_ibfk_2 FOREIGN KEY (tobranch) REFERENCES branches (branchcode) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE branchtransfers ADD CONSTRAINT branchtransfers_ibfk_3 FOREIGN KEY (itemnumber) REFERENCES items (itemnumber) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE class_sources ADD CONSTRAINT class_sources_ibfk_1 FOREIGN KEY (class_sort_rule) REFERENCES class_sort_rules (class_sort_rule);
ALTER TABLE issues ADD CONSTRAINT issues_ibfk_1 FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) MATCH SIMPLE ON DELETE SET NULL ON UPDATE SET NULL;
ALTER TABLE issues ADD CONSTRAINT issues_ibfk_2 FOREIGN KEY (itemnumber) REFERENCES items (itemnumber) ON DELETE SET NULL ON UPDATE SET NULL;
ALTER TABLE items ADD CONSTRAINT items_ibfk_1 FOREIGN KEY (biblioitemnumber) REFERENCES biblioitems (biblioitemnumber) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE items ADD CONSTRAINT items_ibfk_2 FOREIGN KEY (homebranch) REFERENCES branches (branchcode) ON UPDATE CASCADE;
ALTER TABLE items ADD CONSTRAINT items_ibfk_3 FOREIGN KEY (holdingbranch) REFERENCES branches (branchcode) ON UPDATE CASCADE;
ALTER TABLE reserves ADD CONSTRAINT reserves_ibfk_1 FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) MATCH SIMPLE ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE reserves ADD CONSTRAINT reserves_ibfk_2 FOREIGN KEY (biblionumber) REFERENCES biblio (biblionumber) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE reserves ADD CONSTRAINT reserves_ibfk_3 FOREIGN KEY (itemnumber) REFERENCES items (itemnumber) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE reserves ADD CONSTRAINT reserves_ibfk_4 FOREIGN KEY (branchcode) REFERENCES branches (branchcode) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE virtualshelfcontents ADD CONSTRAINT virtualshelfcontents_ibfk_1 FOREIGN KEY (shelfnumber) REFERENCES virtualshelves (shelfnumber) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE virtualshelfcontents ADD CONSTRAINT virtualshelfcontents_ibfk_2 FOREIGN KEY (biblionumber) REFERENCES biblio (biblionumber) ON DELETE CASCADE ON UPDATE CASCADE;

--commit;
