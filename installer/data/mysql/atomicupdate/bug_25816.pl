use Modern::Perl;

return {
    bug_number  => "25816",
    description => "Add OPAC messages in SIP display",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('SIP2AddOpacMessagesToScreenMessage','0','','If enabled, patron OPAC messages will be included in the SIP2 screen message','YesNo')
        }
        );

        say $out "Added new system preference 'SIP2AddOpacMessagesToScreenMessage'";
    },
};
