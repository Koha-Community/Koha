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
                                'If ON, a verification is performed to check if the ILL request has previously been placed by the same patron. Verification is done using one of the following identifier fields: DOI, Pubmed ID or ISBN',
                        'YesNo'
                    );
                }
        );
        say_success( $out, "Added new system preference 'ILLHistoryCheck'" );
    },
};
