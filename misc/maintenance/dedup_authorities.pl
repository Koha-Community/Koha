#!/usr/bin/perl
use Modern::Perl;
use C4::Context;
use C4::AuthoritiesMarc;
use C4::Biblio;
use C4::Search;
use C4::Charset;
use C4::Heading;
use Koha::SearchEngine;
use Koha::SearchEngine::QueryBuilder;
use Koha::Logger;

use Koha::Authorities;

use Getopt::Long;
use YAML;
use List::MoreUtils qw/uniq/;
use Pod::Usage      qw( pod2usage );

=head1 NAME

misc/migration_tools/dedup_authorities.pl - Deduping authorities script

=head1 SYNOPSIS

dedup_authorities.pl [ -h ] [ -where="authid < 5000" ] -c [ -v ] [ -m d ] [ -a PERSO_NAME ]

 Options:
     -h --help          display usage statement
     -v --verbose       increase verbosity, can be repeated for greater verbosity
     -m --method        method for choosing the reference authority, can be: date, used, or ppn (UNIMARC)
                        can be repeated
     -w --where         a SQL WHERE statement to limit the authority records checked
     -c --confirm       without this parameter no changes will be made, script will run in test mode
     -a --authtypecode  check only specified auth type, repeatable

=head1 OPTIONS

=over

=item B<--method>

Method(s) used to choose which authority to keep in case we found
duplicates.
<methods> is a string composed of letters describing what methods to use
and in which order.
Letters can be:
    date:  keep the most recent authority (based on 005 field)
    used:  keep the most used authority
    ppn:   PPN (UNIMARC only), keep the authority with a ppn (when some
        authorities don't have one, based on 009 field)

Example:
-m ppn -m date -m used
Among the authorities that have a PPN, keep the most recent,
and if two (or more) have the same date in 005, keep the
most used.

Default is 'used'

=item B<--where>

limit the deduplication to SOME authorities only

Example:
-where="authid < 5000"
will only auths with a low auth_id (old records)

=item B<--verbose>

display verbose logging, can be repeated twice for more info


=item B<--help>

show usage information.

=back

=cut

my @methods;
my @authtypecodes;
my $help        = 0;
my $confirm     = 0;
my $verbose     = 0;
my $wherestring = "";
my $debug       = 0;

my $result = GetOptions(
    "d|debug"          => \$debug,
    "v|verbose+"       => \$verbose,
    "c|confirm"        => \$confirm,
    "h|help"           => \$help,
    "w|where=s"        => \$wherestring,
    "m|method=s"       => \@methods,
    "a|authtypecode=s" => \@authtypecodes
);

pod2usage( -verbose => 2 ) if ($help);

print "RUNNING IN TEST MODE, NO CHANGES WILL BE MADE\n" unless $confirm;
$verbose = 1                                            unless ( $confirm || $verbose );

my @choose_subs;
@methods = ('used') unless @methods;
foreach my $method (@methods) {
    if ( $method eq 'date' ) {
        push @choose_subs, \&_get_date;
    } elsif ( $method eq 'ppn' ) {
        die 'PPN method is only valid for UNIMARC'
            unless ( C4::Context->preference('marcflavour') eq 'UNIMARC' );
        push @choose_subs, \&_has_ppn;
    } elsif ( $method eq 'used' ) {
        push @choose_subs, \&_get_usage;
    } else {
        warn "Choose method '$method' is not supported";
    }
}

my $dbh = C4::Context->dbh;

$verbose and print "Fetching authtypecodes...\n";
my $params = undef;
if (@authtypecodes) {
    $params = { authtypecode => { -in => \@authtypecodes } };
}
my @auth_types = Koha::Authority::Types->search($params)->as_list;
my %auth_match_headings =
    map { $_->authtypecode => $_->auth_tag_to_report } @auth_types;
$verbose and print "Fetching authtypecodes done.\n";

my %biblios;
my $seen;

for my $authtype (@auth_types) {
    my $authtypecode = $authtype->authtypecode;
    my %duplicated;
    my $deleted      = 0;
    my $updated_bibs = 0;
    my $i            = 0;
    $verbose and print "Deduping authtype '$authtypecode' \n";

    $verbose and print "Fetching authorities for '$authtypecode'... ";
    my $authorities = Koha::Authorities->search( { authtypecode => $authtypecode } );
    $authorities = $authorities->search( \$wherestring ) if $wherestring;
    my $size = $authorities->count;
    $verbose and print "$size authorities found\n";

    while ( my $authority = $authorities->next ) {
        next if defined $seen->{ $authority->authid };
        $seen->{ $authority->authid } = 1;
        $i++;
        if ( $verbose >= 2 ) {
            my $percentage = sprintf( "%.2f", $i * 100 / $size );
            print "Processing authority " . $authority->authid . " ($i/$size $percentage%)\n";
        } elsif ( $verbose and ( $i % 100 ) == 0 ) {
            my $percentage = sprintf( "%.2f", $i * 100 / $size );
            print "Progression for authtype '$authtypecode': $i/$size ($percentage%)\n";
        }

        #authority was marked as duplicate
        next if defined $duplicated{ $authority->authid };
        my $authrecord = C4::AuthoritiesMarc::GetAuthority( $authority->authid );

        next unless $authrecord;
        C4::Charset::SetUTF8Flag($authrecord);

        $debug and print "    Building query...\n";
        my $field = $authrecord->field( $auth_match_headings{$authtypecode} );
        unless ($field) {
            warn "    Malformed authority record, no heading";
            next;
        }
        unless ( $field->as_string ) {
            warn "    Malformed authority record, blank heading";
            next;
        }
        my $heading     = C4::Heading->new_from_field( $field, undef, 1 );    #new auth heading
        my $search_term = $heading->search_form;
        $debug and print "    Building query done\n";
        $debug and print "    $search_term\n";

        $debug and print "    Searching...";

        my $builder  = Koha::SearchEngine::QueryBuilder->new( { index => $Koha::SearchEngine::AUTHORITIES_INDEX } );
        my $searcher = Koha::SearchEngine::Search->new( { index => $Koha::SearchEngine::AUTHORITIES_INDEX } );
        my $query    = $builder->build_authorities_query_compat(
            ['match-heading'], [''],
            [''], ['exact'], [$search_term], $authtypecode, ''
        );
        my ( $results, $total ) = $searcher->search_auth_compat( $query, 0, 50, undef );
        if ( !$results ) {
            $debug and warn "    " . $@;
            $debug and warn "    " . YAML::Dump($search_term);
            $debug and warn "    " . $field->as_string;
            next;
        }

        $debug and warn "    " . YAML::Dump($results);

        my @recordids =
            map { $_->{authid} != $authority->authid ? $_->{authid} : () } @$results;
        if ( !$results || scalar(@$results) < 1 || scalar @recordids < 1 ) {
            ( $verbose >= 2 )
                and print '    No duplicates found for ' . $heading->display_form . "\n";
            next;
        }
        map { $seen->{$_} = 1 } @recordids;
        $debug and print "    Searching done.\n";

        $debug and print "    Choosing records...";
        my ( $recordid_to_keep, @recordids_to_merge ) = _choose_records( $authority->authid, @recordids );
        $debug and print "    Choosing records done.\n";
        unless ( !$confirm or @recordids_to_merge == 0 ) {
            ( $verbose >= 2 )
                and print "    Merging " . join( ',', @recordids_to_merge ) . " into $recordid_to_keep.\n";
            for my $localauthid (@recordids_to_merge) {
                next if $recordid_to_keep == $localauthid;
                my $MARCto        = C4::AuthoritiesMarc::GetAuthority($recordid_to_keep);
                my $editedbiblios = 0;
                eval {
                    $editedbiblios = C4::AuthoritiesMarc::merge(
                        {
                            mergefrom => $localauthid,
                            MARCfrom  => undef,
                            mergeto   => $recordid_to_keep,
                            MARCto    => $MARCto
                        }
                    );
                };
                if ($@) {
                    warn "    Merging $localauthid into $recordid_to_keep failed :",
                        $@;
                } else {
                    print "    Updated " . $editedbiblios . " biblios\n";
                    $updated_bibs += $editedbiblios;
                    $duplicated{$localauthid} = 2;
                    print "    Deleting $localauthid\n";
                    C4::AuthoritiesMarc::DelAuthority( { authid => $localauthid, skip_merge => 1 } );
                    $deleted++;
                }
            }
            ( $verbose >= 2 ) and print "    Merge done.\n";
            $duplicated{$recordid_to_keep} = 1;
        } elsif ( $verbose >= 2 ) {
            if ( @recordids_to_merge > 0 ) {
                print '    Would merge '
                    . join( ',', @recordids_to_merge )
                    . " into $recordid_to_keep ("
                    . $heading->display_form . ")\n";
            } else {
                print "    No duplicates found for $recordid_to_keep\n";
            }
        }
    }
    $verbose and print "End of deduping for authtype '$authtypecode'\n";
    $verbose and print "Updated $updated_bibs biblios\n";
    $verbose and print "Deleted $deleted authorities\n";
}

# Update biblios
my @biblios_to_update = grep { defined $biblios{$_} and $biblios{$_} == 1 }
    keys %biblios;
if ( @biblios_to_update > 0 ) {
} else {
    print "No biblios to update\n";
}

exit 0;

sub _get_id {
    my $record = shift;

    if ( $record and ( my $field = $record->field('001') ) ) {
        return $field->data();
    }
    return 0;
}

sub _has_ppn {
    my $record = shift;

    if ( $record and ( my $field = $record->field('009') ) ) {
        return $field->data() ? 1 : 0;
    }
    return 0;
}

sub _get_date {
    my $record = shift;

    if ( $record and ( my $field = $record->field('005') ) ) {
        return $field->data();
    }
    return 0;
}

sub _get_usage {
    my $record = shift;

    if ( $record and ( my $field = $record->field('001') ) ) {
        return Koha::Authorities->get_usage_count( { authid => $field->data() } );
    }
    return 0;
}

=head2 _choose_records
    this function takes input of candidate record ids to merging
    and returns
        first the record to merge to
        and list of records to merge from
=cut

sub _choose_records {
    my @recordids = @_;

    my @records         = map { C4::AuthoritiesMarc::GetAuthority($_) } @recordids;
    my @candidate_auths = @records;

    # See http://www.sysarch.com/Perl/sort_paper.html Schwartzian transform
    my @candidate_authids =
        map $_->[0] => sort { $b->[1] <=> $a->[1] || $b->[2] <=> $a->[2] || $b->[3] <=> $a->[3] }
        map [ _get_id($_),
        $choose_subs[0] ? $choose_subs[0]->($_) : 0,
        $choose_subs[1] ? $choose_subs[1]->($_) : 0,
        $choose_subs[2] ? $choose_subs[2]->($_) : 0 ] => ( $records[0], @candidate_auths );

    return @candidate_authids;
}
