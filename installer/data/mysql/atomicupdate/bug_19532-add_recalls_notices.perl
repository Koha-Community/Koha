$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`) VALUES
        ('circulation','RETURN_RECALLED_ITEM','','Notification to return a recalled item','0','Notification to return a recalled item','Date: <<today>>

<<borrowers.firstname>> <<borrowers.surname>>,

A recall has been placed on the following item: <<biblio.title>> / <<biblio.author>> (<<items.barcode>>). The due date has been updated, and is now <<issues.date_due>>. Please return the item before the due date.

Thank you!','email'),
        ('circulation','PICKUP_RECALLED_ITEM','','Recalled item awaiting pickup','0','Recalled item awaiting pickup','Date: <<today>>

<<borrowers.firstname>> <<borrowers.surname>>,

A recall that you requested on the following item: <<biblio.title>> / <<biblio.author>> (<<items.barcode>>) is now ready for you to pick up at <<recalls.branchcode>>. Please pick up your item by <<recalls.expirationdate>>.

Thank you!','email'),
        ('circulation','RECALL_REQUESTER_DET','','Details of patron who recalled item',0,'Details of patron who recalled item','Date: <<today>>

Recall for pickup at <<branches.branchname>>
<<borrowers.surname>>, <<borrowers.firstname>> (<<borrowers.cardnumber>>)
<<borrowers.phone>>
<<borrowers.streetnumber>> <<borrowers.address>>, <<borrowers.address2>>, <<borrowers.city>> <<borrowers.zipcode>>
<<borrowers.email>>

ITEM RECALLED
<<biblio.title>> by <<biblio.author>>
Barcode: <<items.barcode>>
Callnumber: <<items.itemcallnumber>>
Waiting since: <<recalls.waitingdate>>
Notes: <<recalls.recallnotes>>', 'print')
    });

    NewVersion( $DBversion, 19532, "Add recalls notices: RETURN_RECALLED_ITEM, PICKUP_RECALLED_ITEM, RECALL_REQUESTER_DET" );
}
