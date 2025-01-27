#!/usr/bin/perl

use Modern::Perl;

use Pod::Usage   qw( pod2usage );
use Getopt::Long qw( GetOptions );

use Koha::Script -cron;

use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Suggestions;
use C4::Koha qw( GetAuthorisedValues );

my ( $help, $verbose, $confirm, $age, $age_date_field, @statuses );
GetOptions(
    'h|help'           => \$help,
    'v|verbose'        => \$verbose,
    'age:s'            => \$age,
    'age-date-field:s' => \$age_date_field,
    'status:s'         => \@statuses,
    'c|confirm'        => \$confirm,
) || pod2usage( verbose => 2 );

if ($help) {
    pod2usage( verbose => 2 );
}

unless ( $age or @statuses ) {
    pod2usage(q{At least --age or --status must be provided});
    exit;
}

unless ($confirm) {
    say "Doing a dry run; no suggestion will be modified.";
    say "Run again with --confirm to modify suggestions.";
    $verbose = 1 unless $verbose;
}

my $params = { archived => 0 };

my @available_statuses;
if (@statuses) {
    @available_statuses = map { $_->{authorised_value} } @{ GetAuthorisedValues('SUGGEST_STATUS') };
    push @available_statuses, qw( ASKED ACCEPTED CHECKED REJECTED ORDERED AVAILABLE );
    my @unknown_statuses;
    for my $status (@statuses) {
        push @unknown_statuses, $status
            if !grep { $_ eq $status } @available_statuses;
    }
    if (@unknown_statuses) {
        pod2usage(
            sprintf(
                "%s (%s)\nValid statuses are: %s",
                'Invalid status ',
                join( ', ', @unknown_statuses ),
                join( ', ', @available_statuses ),
            )
        );
        exit;
    }

    $params->{STATUS} = { -in => \@statuses } if @statuses;
}

if ($age_date_field) {
    if ( !grep { $_ eq $age_date_field } qw( suggesteddate manageddate accepteddate rejecteddate lastmodificationdate) )
    {
        pod2usage( sprintf( "The parameter for --age-field (%s) is invalid", $age_date_field ) );
        exit;
    }
} else {
    $age_date_field = 'manageddate';
}

my $date = dt_from_string;
if ($age) {
    if ( $age =~ m|^(\d)$| || $age =~ m|^days:(\d+)$| ) {
        $date->subtract( days => $1 );
    } elsif ( $age =~ m|^hours:(\d+)$| ) {
        $date->subtract( hours => $1 );
    } elsif ( $age =~ m|^weeks:(\d+)$| ) {
        $date->subtract( weeks => $1 );
    } elsif ( $age =~ m|^months:(\d+)$| ) {
        $date->subtract( months => $1 );
    } elsif ( $age =~ m|^years:(\d+)$| ) {
        $date->subtract( years => $1 );
    } else {
        pod2usage( sprintf( "The parameter for --age (%s) is invalid", $age ) );
        exit;
    }
    my $dtf = Koha::Database->new->schema->storage->datetime_parser;
    $params->{$age_date_field} = { '<=' => $dtf->format_date($date) };
}
my $suggestions = Koha::Suggestions->search($params);
say sprintf( "Found %d suggestions", $suggestions->count ) . (
    exists $params->{$age_date_field}
    ? sprintf(
        " with %s older than %s",
        $age_date_field, output_pref( { dt => $date, dateonly => 1 } )
        )
    : ""
    )
    . (
    exists $params->{status}
    ? sprintf(
        " and one of the following statuses: %s",
        join( ', ', @available_statuses )
        )
    : ""
    ) if $verbose;

while ( my $suggestion = $suggestions->next ) {
    if ($confirm) {
        say sprintf( "Archiving suggestion %s", $suggestion->suggestionid )
            if $verbose;
        $suggestion->update( { archived => 1 } );
    } else {
        say sprintf(
            "Suggestion %s would have been archived",
            $suggestion->suggestionid
        );
    }
}

=head1 NAME

archive_purchase_suggestions.pl - Archive purchase suggestions given their age and status

=head1 SYNOPSIS

archive_purchase_suggestions.pl [-h|--help] [-v|--verbose] [-c|--confirm] [--age=AGE] [--age-date-field=DATE_FIELD] [--status=STATUS]

=head1 OPTIONS

=over

=item B<-h|--help>

Print a brief help message

=item B<-c|--confirm>

This flag must be provided in order for the script to actually
archive purchase suggestions.  If it is not supplied, the script will
only report on the suggestions it would have archived.

=item B<--age>

It must contain an integer representing the number of days elapsed since the suggestions has been modified. You can use it along with B<--age-date-field> to specify the database column you want to apply this number.

You can also provide a number of hours, days, weeks, months or years. Like --age=months:1 to archive purchase suggestions older than a month.

=item B<--age-date-field>

You can specify one of the date fields of suggestions: suggesteddate, manageddate, accepteddate, rejecteddate or lastmodificationdate. Default is manageddate.

=item B<--status>

It must be one of the 6 default statuses (ASKED, ACCEPTED, CHECKED, REJECTED, ORDERED or AVAILABLE), or one define in the SUGGEST_STATUS authorized value's category.

Can be passed several times.

=item B<-v|--verbose>

Verbose mode.

=back

=head1 AUTHOR

Jonathan Druart <jonathan.druart@bugs.koha-community.org>

=head1 LICENSE

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

Koha is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Koha; if not, see <http://www.gnu.org/licenses>.

=cut
