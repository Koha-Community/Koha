#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2013 BibLibre
#
# Koha is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General
# Public License along with Koha; if not, see
# <http://www.gnu.org/licenses>

use Modern::Perl;

use CGI;
use List::MoreUtils qw( uniq );

use C4::Auth;
use C4::Output;
use C4::AuthoritiesMarc;
use C4::Biblio;

my $input = new CGI;
my $dbh = C4::Context->dbh;
my $op = $input->param('op') // q|form|;
my $recordtype = $input->param('recordtype') // 'biblio';

my ($template, $loggedinuser, $cookie) = get_template_and_user({
        template_name => 'tools/batch_delete_records.tt',
        query => $input,
        type => "intranet",
        authnotrequired => 0,
        flagsrequired => { tools => 'records_batchdel' },
});

my @records;
my @messages;
if ( $op eq 'form' ) {
    # Display the form
    $template->param( op => 'form' );
} elsif ( $op eq 'list' ) {
    # List all records to process
    my @record_ids;
    if ( my $bib_list = $input->param('bib_list') ) {
        # Come from the basket
        @record_ids = split /\//, $bib_list;
        $recordtype = 'biblio';
    } elsif ( my $uploadfile = $input->param('uploadfile') ) {
        # A file of id is given
        while ( my $content = <$uploadfile> ) {
            next unless $content;
            $content =~ s/[\r\n]*$//;
            push @record_ids, $content if $content;
        }
    } else {
        # The user enters manually the list of id
        push @record_ids, split( /\s\n/, $input->param('recordnumber_list') );
    }

    for my $record_id ( uniq @record_ids ) {
        if ( $recordtype eq 'biblio' ) {
            # Retrieve biblio information
            my $biblio = C4::Biblio::GetBiblio( $record_id );
            unless ( $biblio ) {
                push @messages, {
                    type => 'warning',
                    code => 'biblio_not_exists',
                    biblionumber => $record_id,
                };
                next;
            }
            my $record = &GetMarcBiblio( $record_id );
            $biblio->{subtitle} = GetRecordValue( 'subtitle', $record, GetFrameworkCode( $record_id ) );
            $biblio->{itemnumbers} = C4::Items::GetItemnumbersForBiblio( $record_id );
            $biblio->{reserves} = C4::Reserves::GetReservesFromBiblionumber({ biblionumber => $record_id });
            $biblio->{issues_count} = C4::Biblio::CountItemsIssued( $record_id );
            push @records, $biblio;
        } else {
            # Retrieve authority information
            my $authority = C4::AuthoritiesMarc::GetAuthority( $record_id );
            unless ( $authority ) {
                push @messages, {
                    type => 'warning',
                    code => 'authority_not_exists',
                    authid => $record_id,
                };
                next;
            }

            $authority = {
                authid => $record_id,
                summary => C4::AuthoritiesMarc::BuildSummary( $authority, $record_id ),
                count_usage => C4::AuthoritiesMarc::CountUsage( $record_id ),
            };
            push @records, $authority;
        }
    }
    $template->param(
        records => \@records,
        op => 'list',
    );
} elsif ( $op eq 'delete' ) {
    # We want to delete selected records!
    my @record_ids = $input->multi_param('record_id');
    my $dbh = C4::Context->dbh;
    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;

    my $error;
    my $report = {
        total_records => 0,
        total_success => 0,
    };
    RECORD_IDS: for my $record_id ( sort { $a <=> $b } @record_ids ) {
        $report->{total_records}++;
        next unless $record_id;
        if ( $recordtype eq 'biblio' ) {
            # Biblios
            my $biblionumber = $record_id;
            # First, checking if issues exist.
            # If yes, nothing to do
            if ( C4::Biblio::CountItemsIssued( $biblionumber ) ) {
                push @messages, {
                    type => 'warning',
                    code => 'item_issued',
                    biblionumber => $biblionumber,
                };
                $dbh->rollback;
                next;
            }

            # Cancel reserves
            my $reserves = C4::Reserves::GetReservesFromBiblionumber({ biblionumber => $biblionumber });
            for my $reserve ( @$reserves ) {
                eval{
                    C4::Reserves::CancelReserve( { reserve_id => $reserve->{reserve_id} } );
                };
                if ( $@ ) {
                    push @messages, {
                        type => 'error',
                        code => 'reserve_not_cancelled',
                        biblionumber => $biblionumber,
                        reserve_id => $reserve->{reserve_id},
                        error => $@,
                    };
                    $dbh->rollback;
                    next RECORD_IDS;
                }
            }

            # Delete items
            my @itemnumbers = @{ C4::Items::GetItemnumbersForBiblio( $biblionumber ) };
            ITEMNUMBER: for my $itemnumber ( @itemnumbers ) {
                my $error = eval { C4::Items::DelItemCheck( $biblionumber, $itemnumber ) };
                if ( $error != 1 or $@ ) {
                    push @messages, {
                        type => 'error',
                        code => 'item_not_deleted',
                        biblionumber => $biblionumber,
                        itemnumber => $itemnumber,
                        error => ($@ ? $@ : $error),
                    };
                    $dbh->rollback;
                    next RECORD_IDS;
                }
            }

            # Finally, delete the biblio
            my $error = eval {
                C4::Biblio::DelBiblio( $biblionumber );
            };
            if ( $error or $@ ) {
                push @messages, {
                    type => 'error',
                    code => 'biblio_not_deleted',
                    biblionumber => $biblionumber,
                    error => ($@ ? $@ : $error),
                };
                $dbh->rollback;
                next;
            }

            push @messages, {
                type => 'success',
                code => 'biblio_deleted',
                biblionumber => $biblionumber,
            };
            $report->{total_success}++;
            $dbh->commit;
        } else {
            # Authorities
            my $authid = $record_id;
            my $r = eval { C4::AuthoritiesMarc::DelAuthority( $authid ) };
            if ( $r eq '0E0' or $@ ) {
                push @messages, {
                    type => 'error',
                    code => 'authority_not_deleted',
                    authid => $authid,
                    error => ($@ ? $@ : 0),
                };
                $dbh->rollback;
                next;
            } else {
                push @messages, {
                    type => 'success',
                    code => 'authority_deleted',
                    authid => $authid,
                };
                $report->{total_success}++;
                $dbh->commit;
            }
        }
    }
    $template->param(
        op => 'report',
        report => $report,
    );
}

$template->param(
    messages => \@messages,
    recordtype => $recordtype,
);

output_html_with_http_headers $input, $cookie, $template->output;
