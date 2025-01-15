use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

use C4::Context;

return {
    bug_number  => "38441",
    description => "Add 'ILLHistoryCheck' system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
                    INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES (
                            'ILLHistoryCheck', '', '',
                                'If ON, during the ILL request process, a check is performed to see if the ILL request has already been previously placed',
                        'YesNo'
                    );
                }
        );
        say $out "Added new system preference 'ILLHistoryCheck'";
    },
};
