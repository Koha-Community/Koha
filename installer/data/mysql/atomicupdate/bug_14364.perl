$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('ExpireReservesAutoFill','0',NULL,'Automatically fill the next hold with a automatically canceled expired waiting hold.','YesNo'),
        ('ExpireReservesAutoFillEmail','', NULL,'If ExpireReservesAutoFill and an email is defined here, the email notification for the change in the hold will be sent to this address.','Free');
    });

    $dbh->do(q{
        INSERT IGNORE INTO letter(module,code,branchcode,name,is_html,title,content,message_transport_type)
        VALUES ( 'reserves', 'HOLD_CHANGED', '', 'Canceled Hold Available for Different Patron', '0', 'Canceled Hold Available for Different Patron', 'The patron picking up <<biblio.title>> (<<items.barcode>>) has changed to <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>).

Please update the hold information for this item.

Title: <<biblio.title>>
Author: <<biblio.author>>
Copy: <<items.copynumber>>
Pickup location: <<branches.branchname>>', 'email');
    });

    NewVersion( $DBversion, 14364, "Allow automatically canceled expired waiting holds to fill the next hold");
}
