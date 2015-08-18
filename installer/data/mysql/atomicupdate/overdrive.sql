ALTER TABLE borrowers ADD overdrive_auth_token text default NULL AFTER lastseen;

INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
VALUES ('OverDriveCirculation','0','Enable client to see their OverDrive account','','YesNo');
