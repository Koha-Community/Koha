$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO letter 
        (module,code,branchcode,name,is_html,title,content,message_transport_type,lang)
        VALUES ('reserves','HOLD_REMINDER','','Waiting hold reminder',0,'You have waiting holds.','Dear [% borrower.firstname %] [% borrower.surname %],\r\n\r\nThe follwing holds are waiting at [% branch.branchname %]:\r\n\\r\n[% FOREACH hold IN holds %]\r\n    [% hold.biblio.title %] : waiting since [% hold.waitingdate %]\r\n[% END %]','email','default')
    });
    NewVersion( $DBversion, 15986, "Add sample HOLD_REMINDER notice");
}
