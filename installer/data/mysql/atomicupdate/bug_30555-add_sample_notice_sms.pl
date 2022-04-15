use Modern::Perl;

return {
    bug_number => "30555",
    description => "Add more sample notice for sms messages",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{
            INSERT IGNORE INTO letter
            (module,code,branchcode,name,is_html,title,content,message_transport_type,lang)
            VALUES
            ('circulation','CHECKIN','','Item check-in (digest)',0,'Check-ins','The following items have been checked in:\r\n----\r\n[% biblio.title %]\r\n----\r\nThank you.','sms','default'),
            ('circulation','CHECKOUT','','Item check-out (digest)',0,'Checkouts','The following items have been checked out:\r\n----\r\n[% biblio.title %]\r\n----\r\nThank you for visiting [% branch.branchname %].','sms','default'),
            ('circulation','DUE','','Item due reminder',0,'Item due reminder','Dear <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nThe following item is now due:\r\n\r\n<<biblio.title>>','sms','default'),
            ('circulation','DUEDGST','','Item due reminder (digest)',0,'Item due reminder','Dear <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nYou have <<count>> item(s) that are now due\r\n\r\nThank you.','sms','default'),
            ('circulation','PREDUE','','Advance notice of item due',0,'Advance notice of item due','Dear <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nThe following item will be due soon:\r\n\r\n<<biblio.title>>','sms','default'),
            ('circulation','PREDUEDGST','','Advance notice of item due (digest)',0,'Advance notice of item due','Dear <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nYou have <<count>> item(s) that will be due soon.\r\n\r\nThank you.','sms','default'),
            ('reserves','HOLD','','Hold available for pickup',0,'Hold available for pickup at <<branches.branchname>>','Dear <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nYour hold for <<biblio.title>> is available for pickup.','sms','default')
        });
    },
};
