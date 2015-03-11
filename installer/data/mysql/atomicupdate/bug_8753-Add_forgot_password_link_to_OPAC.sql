INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
VALUES ('OpacResetPassword',  '0','','Shows the ''Forgot your password?'' link in the OPAC','YesNo');

CREATE TABLE IF NOT EXISTS borrower_password_recovery (
  borrowernumber int(11) NOT NULL,
  uuid varchar(128) NOT NULL,
  valid_until timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY borrowernumber (borrowernumber)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT IGNORE INTO `letter` (module, code, branchcode, name, is_html, title, content, message_transport_type)
VALUES ('members','PASSWORD_RESET','','Online password reset',1,'Koha password recovery','<html>\r\n<p>This email has been sent in response to your password recovery request for the account <strong><<user>></strong>.\r\n</p>\r\n<p>\r\nYou can now create your new password using the following link:\r\n<br/><a href=\"<<passwordreseturl>>\"><<passwordreseturl>></a>\r\n</p>\r\n<p>This link will be valid for 2 days from this email\'s reception, then you must reapply if you do not change your password.</p>\r\n<p>Thank you.</p>\r\n</html>\r\n','email');
