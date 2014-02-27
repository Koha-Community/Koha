#! /usr/bin/perl
use strict;
use warnings;
use C4::Context;
my $dbh = C4::Context->dbh;

# add phone message transport type
$dbh->do("INSERT INTO message_transport_types (message_transport_type) VALUES ('phone')");

# adds HOLD and PREDUE letters (as placeholders)
$dbh->do("INSERT INTO letter (module, code, name, title, content, message_transport_type) VALUES
          ('reserves', 'HOLD', 'Item Available for Pick-up (phone notice)', 'Item Available for Pick-up (phone notice)', 'Your item is available for pickup', 'phone'),
          ('circulation', 'PREDUE', 'Advance Notice of Item Due (phone notice)', 'Advance Notice of Item Due (phone notice)', 'Your item is due soon', 'phone'),
          ('circulation', 'OVERDUE', 'Overdue Notice (phone notice)', 'Overdue Notice (phone notice)', 'Your item is overdue', 'phone')
          ");

# add phone notifications to patron message preferences options
$dbh->do("INSERT INTO message_transports
         (message_attribute_id, message_transport_type, is_digest, letter_module, letter_code) VALUES
         (4, 'phone', 0, 'reserves', 'HOLD'),
         (2, 'phone', 0, 'circulation', 'PREDUE')
         ");

# add TalkingTechItivaPhoneNotification syspref
$dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('TalkingTechItivaPhoneNotification',0,'If ON, enables Talking Tech I-tiva phone notifications',NULL,'YesNo');");

print "Upgrade done (Support for Talking Tech i-tiva phone notification system)\n";
