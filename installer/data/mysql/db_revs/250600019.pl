use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => 40284,
    description => "Add maxlength for fields 005 to 007 in MARC21",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( C4::Context->preference('marcflavour') eq 'MARC21' ) {
            my ($count) = $dbh->selectrow_array(
                q{SELECT COUNT(*) FROM marc_subfield_structure WHERE tagfield in ('005','006','007') AND maxlength=9999}
            );
            $dbh->do(q{UPDATE marc_subfield_structure SET maxlength=16 WHERE tagfield='005' AND maxlength=9999});
            $dbh->do(q{UPDATE marc_subfield_structure SET maxlength=18 WHERE tagfield='006' AND maxlength=9999});
            $dbh->do(q{UPDATE marc_subfield_structure SET maxlength=23 WHERE tagfield='007' AND maxlength=9999});
            my ($count2) = $dbh->selectrow_array(
                q{SELECT COUNT(*) FROM marc_subfield_structure WHERE tagfield in ('005','006','007') AND maxlength=9999}
            );
            say_success( $out, "Adjusted maxlength in $count records/fields" ) if $count;
            say_warning( $out, "$count2 records remaining" )                   if $count2;
        }
    },
};
