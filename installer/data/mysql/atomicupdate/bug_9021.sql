CREATE TABLE  sms_providers (
   id INT( 11 ) NOT NULL AUTO_INCREMENT PRIMARY KEY ,
   name VARCHAR( 255 ) NOT NULL ,
   domain VARCHAR( 255 ) NOT NULL ,
   UNIQUE (
       name
   )
) ENGINE = INNODB CHARACTER SET utf8;

ALTER TABLE borrowers ADD sms_provider_id INT( 11 ) NULL DEFAULT NULL AFTER smsalertnumber, ADD INDEX ( sms_provider_id );

ALTER TABLE borrowers ADD FOREIGN KEY ( sms_provider_id ) REFERENCES  sms_providers ( id );
