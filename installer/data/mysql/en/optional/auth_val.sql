-- Reasons for acceptance or rejection of suggestions in acquisitions
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','BSELL','Bestseller');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','SCD','Shelf Copy Damaged');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','LCL','Library Copy Lost');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','AVILL','Available via ILL');

-- availability statuses
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOST','0','');
INSERT INTO `authorised_values`  (category, authorised_value, lib) VALUES ('LOST','2','Long Overdue (Lost)');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOST','1','Lost');
INSERT INTO `authorised_values`  (category, authorised_value, lib ) VALUES ('LOST','3','Lost and Paid For');
INSERT INTO `authorised_values`  (category, authorised_value, lib )VALUES ('LOST','4','Missing');

-- damaged status of an item
INSERT INTO `authorised_values`  (category, authorised_value, lib) VALUES ('DAMAGED','0','');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('DAMAGED','1','Damaged');

-- location qualification for an item, departments are linked by default to items.location
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','FIC','Fiction');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','CHILD','Children\'s Area');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','DISPLAY','On Display');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','NEW','New Materials Shelf');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','STAFF','Staff Office');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','GEN','General Stacks');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','AV','Audio Visual');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','REF','Reference');

-- collection codes for an item
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('CCODE','FIC','Fiction');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('CCODE','REF','Reference');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('CCODE','NFIC','Non Fiction');

-- withdrawn status of an item, linked to items.wthdrawn
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('WITHDRAWN','0','');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('WITHDRAWN','1','Withdrawn');

-- loanability status of an item, linked to items.notforloan
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('NOT_LOAN','-1','Ordered');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('NOT_LOAN','0','');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('NOT_LOAN','1','Not For Loan');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('NOT_LOAN','2','Staff Collection');

-- restricted status of an item, linked to items.restricted
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('RESTRICTED','0','');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('RESTRICTED','1','Restricted Access');
