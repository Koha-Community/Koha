ALTER TABLE items                   CHANGE COLUMN ccode ccode varchar(80) default NULL;
ALTER TABLE deleteditems            CHANGE COLUMN ccode ccode varchar(80) default NULL;
ALTER TABLE branch_transfer_limits  CHANGE COLUMN ccode ccode varchar(80) default NULL;
ALTER TABLE course_items            CHANGE COLUMN ccode ccode varchar(80) default NULL;
