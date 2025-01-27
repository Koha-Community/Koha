use Modern::Perl;

return {
    bug_number  => "14364",
    description => "Allow automatically canceled expired waiting holds to fill the next hold",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('ExpireReservesAutoFill','0',NULL,'Automatically fill the next hold with a automatically canceled expired waiting hold.','YesNo'),
            ('ExpireReservesAutoFillEmail','', NULL,'. Send email notification of hold filled from automatically expired/cancelled hold to this address. If not defined, Koha will fallback to the library reply-to address','Free');
        }
        );
        say $out "Added new system preference 'ExpireReservesAutoFill'";

        $dbh->do(
            q{
        INSERT IGNORE INTO letter(module,code,branchcode,name,is_html,title,content,message_transport_type)
        VALUES ( 'reserves', 'HOLD_CHANGED', '', 'Canceled hold available for different patron', '0', 'Canceled hold available for different patron', 'The patron picking up <<biblio.title>> (<<items.barcode>>) has changed to <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>).

Please update the hold information for this item.

Title: <<biblio.title>>
Author: <<biblio.author>>
Item: <<items.itemcallnumber>>
Pickup location: <<branches.branchname>>', 'email');
        }
        );

        say $out "Added new letter 'HOLD_CHANGED' (email)";
    },
};
