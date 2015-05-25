-- Add NewsAuthorDisplay system preference, bug 14247.
INSERT IGNORE INTO systempreferences (`variable`,`value`,`options`,`explanation`,`type`) VALUES('NewsAuthorDisplay','none','none|opac|staff|both','Display the author name for news items.','Choice');
