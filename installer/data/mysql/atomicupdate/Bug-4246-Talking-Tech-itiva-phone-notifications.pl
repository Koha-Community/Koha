#! /usr/bin/perl
use strict;
use warnings;
use C4::Context;
my $dbh = C4::Context->dbh;

# add phone message transport type
$dbh->do("INSERT INTO message_transport_types (message_transport_type) VALUES ('phone')");

# adds HOLD_PHONE and PREDUE_PHONE letters (as placeholders)
$dbh->do("INSERT INTO letter (module, code, name, title, content) VALUES
          ('reserves', 'HOLD_PHONE', 'Item Available for Pick-up (phone notice)', 'Item Available for Pick-up (phone notice)', 'Your item is available for pickup'),
          ('circulation', 'PREDUE_PHONE', 'Advance Notice of Item Due (phone notice)', 'Advance Notice of Item Due (phone notice)', 'Your item is due soon'),
          ('circulation', 'OVERDUE_PHONE', 'Overdue Notice (phone notice)', 'Overdue Notice (phone notice)', 'Your item is overdue')
          ");

# add phone notifications to patron message preferences options
$dbh->do("INSERT INTO message_transports
         (message_attribute_id, message_transport_type, is_digest, letter_module, letter_code) VALUES
         (4, 'phone', 0, 'reserves', 'HOLD_PHONE'),
         (2, 'phone', 0, 'circulation', 'PREDUE_PHONE')
         ");

# add TalkingTechItivaPhoneNotification syspref
$dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('TalkingTechItivaPhoneNotification',0,'If ON, enables Talking Tech I-tiva phone notifications',NULL,'YesNo');");

print "Upgrade done (Support for Talking Tech i-tiva phone notification system)\n";
