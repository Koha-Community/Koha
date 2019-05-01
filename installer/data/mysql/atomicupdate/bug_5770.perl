$DBversion = '18.12.00.XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( q{
            INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES
            ('EmailPurchaseSuggestions','0','0|EmailAddressForSuggestions|BranchEmailAddress|KohaAdminEmailAddress','Choose email address that will be sent new purchase suggestions','Choice'),
            ('EmailAddressForSuggestions','','','If you choose EmailAddressForSuggestions you should enter a valid email address','free')
    });

    $dbh->do( q{
            INSERT IGNORE INTO `letter` (module, code, name, title, content, is_html, message_transport_type) VALUES
            ('suggestions','NEW_SUGGESTION','New suggestion','New suggestion','<h3>Suggestion pending approval</h3>
                <p><h4>Suggested by</h4>
                    <ul>
                        <li><<borrowers.firstname>> <<borrowers.surname>></li>
                        <li><<borrowers.cardnumber>></li>
                        <li><<borrowers.phone>></li>
                        <li><<borrowers.email>></li>
                    </ul>
                </p>
                <p><h4>Title suggested</h4>
                    <ul>
                        <li><b>Library:</b> <<branches.branchname>></li>
                        <li><b>Title:</b> <<suggestions.title>></li>
                        <li><b>Author:</b> <<suggestions.author>></li>
                        <li><b>Copyright date:</b> <<suggestions.copyrightdate>></li>
                        <li><b>Standard number (ISBN, ISSN or other):</b> <<suggestions.isbn>></li>
                        <li><b>Publisher:</b> <<suggestions.publishercode>></li>
                        <li><b>Collection title:</b> <<suggestions.collectiontitle>></li>
                        <li><b>Publication place:</b> <<suggestions.place>></li>
                        <li><b>Quantity:</b> <<suggestions.quantity>></li>
                        <li><b>Item type:</b> <<suggestions.itemtype>></li>
                        <li><b>Reason for suggestion:</b> <<suggestions.patronreason>></li>
                        <li><b>Notes:</b> <<suggestions.note>></li>
                    </ul>
                </p>',1, 'email')
    });

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 5770 - Email librarian when purchase suggestion made)\n";
}
