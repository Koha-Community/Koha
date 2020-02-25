$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{INSERT IGNORE INTO letter (module, code, name, title, content, message_transport_type) VALUES ('members', 'PROBLEM_REPORT','OPAC Problem Report','OPAC Problem Report','Username: <<problem_reports.username>>\n\nProblem page: <<problem_reports.problempage>>\n\nTitle: <<problem_reports.title>>\n\nMessage: <<problem_reports.content>>','email') });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 4461 - Adding PROBLEM_REPORT notice)\n";
}
