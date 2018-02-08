$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    my $pref =
q|# PERSO_NAME  100 600 696 700 796 800 896
marc21, 100, ind1:auth1
marc21, 600, ind1:auth1, ind2:thesaurus
marc21, 696, ind1:auth1
marc21, 700, ind1:auth1
marc21, 796, ind1:auth1
marc21, 800, ind1:auth1
marc21, 896, ind1:auth1
# CORPO_NAME  110 610 697 710 797 810 897
marc21, 110, ind1:auth1
marc21, 610, ind1:auth1, ind2:thesaurus
marc21, 697, ind1:auth1
marc21, 710, ind1:auth1
marc21, 797, ind1:auth1
marc21, 810, ind1:auth1
marc21, 897, ind1:auth1
# MEETI_NAME    111 611 698 711 798 811 898
marc21, 111, ind1:auth1
marc21, 611, ind1:auth1, ind2:thesaurus
marc21, 698, ind1:auth1
marc21, 711, ind1:auth1
marc21, 798, ind1:auth1
marc21, 811, ind1:auth1
marc21, 898, ind1:auth1
# UNIF_TITLE        130 440 630 699 730 799 830 899 / 240
marc21, 130, ind1:auth2
marc21, 240, , ind2:auth2
marc21, 440, , ind2:auth2
marc21, 630, ind1:auth2, ind2:thesaurus
marc21, 699, ind1:auth2
marc21, 730, ind1:auth2
marc21, 799, ind1:auth2
marc21, 830, , ind2:auth2
marc21, 899, ind1:auth2
# CHRON_TERM    648
marc21, 648, , ind2:thesaurus
# TOPIC_TERM      650 654 656 657 658 690
marc21, 650, , ind2:thesaurus
# GEOGR_NAME   651 662 691 / 751
marc21, 651, , ind2:thesaurus
# GENRE/FORM    655
marc21, 655, , ind2:thesaurus

# UNIMARC: Always copy the indicators from the authority
unimarc, *, ind1:auth1, ind2:auth2|;

    $dbh->do( qq|
INSERT IGNORE INTO systempreferences ( value, variable, options, explanation, type ) VALUES ( ?, 'AuthorityControlledIndicators', NULL, 'Authority controlled indicators per biblio field', 'Free' );
    |, undef, $pref );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 14769: Authorities merge: Set correct indicators in biblio field)\n";
}
