#!/usr/bin/perl

use Modern::Perl;
use Getopt::Long qw( GetOptions );
use Pod::Usage   qw( pod2usage );
use Time::HiRes  qw( gettimeofday );

use Koha::Script -cron;
use C4::AuthoritiesMarc qw( GetAuthority merge );
use C4::Log             qw( cronlogaction );
use Koha::Authority::MergeRequests;

use constant RESET_HOURS => 24;
use constant REMOVE_DAYS => 30;

my ($params);
my $command_line_options = join( " ", @ARGV );
GetOptions(
    'h' => \$params->{help},
    'v' => \$params->{verbose},
    'b' => \$params->{batch},
);

$| = 1;    # flushes output
if ( $params->{batch} ) {
    cronlogaction( { info => $command_line_options } );
    handle_batch($params);
} else {
    pod2usage(1);
}

sub handle_batch {
    my $params  = shift;
    my $verbose = $params->{verbose};

    my $starttime = gettimeofday;
    print "Started merging\n" if $verbose;

    Koha::Authority::MergeRequests->cron_cleanup( { reset_hours => RESET_HOURS, remove_days => REMOVE_DAYS } );
    my $rs = Koha::Authority::MergeRequests->search(
        { done     => 0 },
        { order_by => { -asc => 'id' } },    # IMPORTANT
    );

    # For best results, postponed merges should be applied in right order.
    # Similarly, we do not only select the last one for a specific id.

    while ( my $req = $rs->next ) {
        $req->done(2)->store;
        print "Merging auth " . $req->authid . " to " . ( $req->authid_new // 'NULL' ) . ".\n" if $verbose;
        my $newmarc =
            $req->authid_new
            ? GetAuthority( $req->authid_new )
            : undef;

        # Following merge call handles both modifications and deletes
        merge(
            {
                mergefrom      => $req->authid,
                MARCfrom       => scalar $req->oldmarc,
                mergeto        => $req->authid_new,
                MARCto         => $newmarc,
                override_limit => 1,
            }
        );
        $req->done(1)->store;
    }
    my $timeneeded = gettimeofday - $starttime;
    print "Done in $timeneeded seconds\n" if $verbose;
}

=head1 NAME

merge_authorities.pl

=head1 DESCRIPTION

Cron script to handle authority merge requests

=head1 SYNOPSIS

merge_authorities.pl -h

merge_authorities.pl -b -v

=head1 OPTIONS

-b : batch mode (You need to pass this parameter from crontab file)

-h : print usage statement

-v : verbose mode

=head1 AUTHOR

Koha Development Team

=cut
