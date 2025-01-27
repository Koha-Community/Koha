use Modern::Perl;

return {
    bug_number  => "20517",
    description => "Add SIP2SortBinMapping system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('SIP2SortBinMapping','',NULL,'Use the following mappings to determine the sort_bin of a returned item. The mapping should be on the form \"branchcode:item field:item field value:sort bin number\", with one mapping per line.','free');
	}
        );
    },
};
