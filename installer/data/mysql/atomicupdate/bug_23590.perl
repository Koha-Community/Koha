$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if( !column_exists( 'suggestions', 'lastmodificationby' ) ) {
        $dbh->do(q|
            ALTER TABLE suggestions ADD COLUMN lastmodificationby INT(11) DEFAULT NULL AFTER rejecteddate
        |);

        $dbh->do(q|
            ALTER TABLE suggestions ADD CONSTRAINT `suggestions_ibfk_lastmodificationby` FOREIGN KEY (`lastmodificationby`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE
        |);
    }
    if( !column_exists( 'suggestions', 'lastmodificationdate' ) ) {
        $dbh->do(q|
            ALTER TABLE suggestions ADD COLUMN lastmodificationdate DATE DEFAULT NULL AFTER lastmodificationby
        |);

        my $suggestions = $dbh->selectall_arrayref(q|
            SELECT suggestionid, managedby, manageddate, acceptedby, accepteddate, rejectedby, rejecteddate
            FROM suggestions
        |, { Slice => {} });
        for my $suggestion ( @$suggestions ) {
            my ( $max_date ) = sort ( $suggestion->{manageddate} || (), $suggestion->{accepteddate} || (), $suggestion->{rejecteddate} || () );
            next unless $max_date;
            my $last_modif_by = ( defined $suggestion->{manageddate} and $max_date eq $suggestion->{manageddate} )
              ? $suggestion->{managedby}
              : ( defined $suggestion->{accepteddate} and $max_date eq $suggestion->{accepteddate} )
              ? $suggestion->{acceptedby}
              : ( defined $suggestion->{rejecteddate} and $max_date eq $suggestion->{rejecteddate} )
              ? $suggestion->{rejectedby}
              : undef;
            next unless $last_modif_by;
            $dbh->do(q|
                UPDATE suggestions
                SET lastmodificationdate = ?, lastmodificationby = ?
                WHERE suggestionid = ?
            |, undef, $max_date, $last_modif_by, $suggestion->{suggestionid});
        }

    }

    $dbh->do( q|
        INSERT IGNORE INTO letter(module, code, branchcode, name, is_html, title, content, message_transport_type, lang) VALUES ('suggestions', 'NOTIFY_MANAGER', '', 'Notify manager of a suggestion', 0, "A suggestion has been assigned to you", "Dear [% borrower.firstname %] [% borrower.surname %],\nA suggestion has been assigned to you: [% suggestion.title %].\nThank you,\n[% branch.branchname %]", 'email', 'default');
    | );

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23590 - Add lastmodificationby and lastmodificationdate to the suggestions table)\n";
}
