$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

    if ( column_exists('opac_news', 'new' ) ) {
        $dbh->do(q|ALTER TABLE opac_news CHANGE COLUMN new content text NOT NULL|);
    }

    my ( $used_in_templates ) = $dbh->selectrow_array(q|
        SELECT COUNT(*) FROM letter WHERE content LIKE "%<<opac_news.new>>%";
    |);
    if ( $used_in_templates ) {
        print "WARNING - It seems that you are using the opac_news.new column in your notice templates\n";
        print "Since it has now been renamed with opac_news.content, you should update them.\n";
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17960 - Rename opac_news with opac_news.content)\n";
}
