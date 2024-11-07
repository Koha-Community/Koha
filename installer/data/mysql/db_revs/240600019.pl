use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "23781",
    description => "Recalls notices and messaging preferences",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{ INSERT IGNORE INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`) VALUES ('circulation','RETURN_RECALLED_ITEM','','Notification to return a recalled item','0','Return recalled item','Your item has been recalled: <<biblio.title>> (<<items.barcode>>). Please return it by <<issues.date_due>.','sms'), ('circulation','PICKUP_RECALLED_ITEM','','Recalled item awaiting pickup','0','Recalled item awaiting pickup','A recalled item: <<biblio.title>> (<<items.barcode>>) is ready for you to pick up at <<recalls.branchcode>>. Please collect by <<recalls.expirationdate>>.','sms') }
            ) != '0E0'
            ? say_success( $out, "Added recalls SMS notices: RETURN_RECALLED_ITEM, PICKUP_RECALLED_ITEM" )
            : say_info( $out, "SMS notices already exist, RETURN_RECALLED_ITEM, PICKUP_RECALLED_ITEM, left intact" );

        $dbh->do(
            q{ INSERT IGNORE INTO message_attributes (message_attribute_id, message_name, takes_days) VALUES (12, 'Recall_Waiting', 0), (13, 'Recall_Requested', 0) }
            ) != '0E0'
            ? say_success( $out, "Added message attributes for recalls: Recall_Waiting, Recall_Requested" )
            : say_info( $out, "Message attributes for recalls already exist" );

        $dbh->do(
            q{ INSERT IGNORE INTO message_transports (message_attribute_id, message_transport_type, is_digest, letter_module, letter_code, branchcode) VALUES (12, "email", 0, "circulation", "PICKUP_RECALLED_ITEM", null), (12, "sms", 0, "circulation", "PICKUP_RECALLED_ITEM", null), (12, "phone", 0, "circulation", "PICKUP_RECALLED_ITEM", null), (13, "email", 0, "circulation", "RETURN_RECALLED_ITEM", null), (13, "sms", 0, "circulation", "RETURN_RECALLED_ITEM", null), (13, "phone", 0, "circulation", "RETURN_RECALLED_ITEM", null) }
            ) != '0E0'
            ? say_success( $out, "Added message transports for recalls notices" )
            : say_info( $out, "Message transports for recalls already exist" );
    },
};
