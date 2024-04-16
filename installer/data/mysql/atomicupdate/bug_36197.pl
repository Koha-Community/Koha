use Modern::Perl;
return {
    bug_number  => "36197",
    description => "Add new ILLOpacUnauthenticatedRequest system preferences",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{ INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('ILLOpacUnauthenticatedRequest','',NULL,'Can OPAC users place ILL requests without having to be logged in','YesNo'); }
        );
        say $out "Added new system preference 'ILLOpacUnauthenticatedRequest'";
    },
};
