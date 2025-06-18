#!/usr/bin/perl

# Copyright 2013 C & P Bibliography Services
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use CGI                 qw ( -utf8 );
use C4::Output          qw( output_html_with_http_headers );
use C4::Auth            qw( get_template_and_user );
use C4::AuthoritiesMarc qw( GetAuthority ModAuthority DelAuthority GetTagsLabels merge );
use C4::Biblio          qw( TransformHtmlToMarc );

use Koha::Authority::MergeRequests;
use Koha::Authority::Types;
use Koha::MetadataRecord::Authority;

my $input  = CGI->new;
my @authid = $input->multi_param('authid');
my $op     = $input->param('op') || q{};

my @errors;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "authorities/merge.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { editauthorities => 1 },
    }
);

#------------------------
# Merging
#------------------------
if ( $op eq 'cud-merge' ) {

    # Creating a new record from the html code
    my $record    = TransformHtmlToMarc( $input, 0 );
    my $recordid1 = $input->param('recordid1') // q{};
    my $recordid2 = $input->param('recordid2') // q{};
    my $typecode  = $input->param('frameworkcode');

    # Some error checking
    if ( $recordid1 eq $recordid2 ) {
        push @errors, { code => 'DESTRUCTIVE_MERGE' };
    } elsif ( !$typecode || !Koha::Authority::Types->find($typecode) ) {
        push @errors, { code => 'WRONG_FRAMEWORK' };
    } elsif ( scalar $record->fields == 0 ) {
        push @errors, { code => 'EMPTY_MARC' };
    }
    if (@errors) {
        $template->param( errors => \@errors );
        output_html_with_http_headers $input, $cookie, $template->output;
        exit;
    }

    # Rewriting the leader
    if ( my $authrec = GetAuthority($recordid1) ) {
        $record->leader( $authrec->leader() );
    }

    # Modifying the reference record
    # This triggers a merge for the biblios attached to $recordid1
    ModAuthority( $recordid1, $record, $typecode );

    # Now merge for biblios attached to $recordid2
    my $MARCfrom = GetAuthority($recordid2);
    merge( { mergefrom => $recordid2, MARCfrom => $MARCfrom, mergeto => $recordid1, MARCto => $record } );

    # Delete the other record. No need to merge.
    DelAuthority( { authid => $recordid2, skip_merge => 1 } );

    # Parameters
    $template->param(
        result    => 1,
        recordid1 => $recordid1
    );

    #-------------------------
    # Show records to merge
    #-------------------------
} else {
    my $mergereference = $input->param('mergereference');
    $template->{'VARS'}->{'mergereference'} = $mergereference;

    if ( scalar(@authid) != 2 ) {
        push @errors, { code => "WRONG_COUNT", value => scalar(@authid) };
    } elsif ( $authid[0] eq $authid[1] ) {
        push @errors, { code => 'DESTRUCTIVE_MERGE' };
    } else {
        my $recordObj1 = Koha::MetadataRecord::Authority->get_from_authid( $authid[0] );
        if ( !$recordObj1 ) {
            push @errors, { code => "MISSING_RECORD", value => $authid[0] };
        }

        my $recordObj2;
        if ( defined $mergereference && $mergereference eq 'breeding' ) {
            $recordObj2 = Koha::MetadataRecord::Authority->get_from_breeding( $authid[1] );
        } else {
            $recordObj2 = Koha::MetadataRecord::Authority->get_from_authid( $authid[1] );
        }
        if ( !$recordObj2 ) {
            push @errors, { code => "MISSING_RECORD", value => $authid[1] };
        }

        unless ( $recordObj1 && $recordObj2 ) {
            if (@errors) {
                $template->param( errors => \@errors );
            }
            output_html_with_http_headers $input, $cookie, $template->output;
            exit;
        }

        if ($mergereference) {

            my $framework;
            if ( $recordObj1->authtypecode ne $recordObj2->authtypecode && $mergereference ne 'breeding' ) {
                $framework = $input->param('frameworkcode');
            } else {
                $framework = $recordObj1->authtypecode;
            }
            if ( $mergereference eq 'breeding' ) {
                $mergereference = $authid[0];
            }

            # Getting MARC Structure
            my $tagslib = GetTagsLabels( 1, $framework );
            foreach my $field ( keys %$tagslib ) {
                if ( defined $tagslib->{$field}->{'tab'} && $tagslib->{$field}->{'tab'} eq ' ' ) {
                    $tagslib->{$field}->{'tab'} = 0;
                }
            }

            #Setting $notreference
            my $notreference = $authid[1];
            if ( $mergereference == $notreference ) {
                $notreference = $authid[0];

                #Swap so $recordObj1 is always the correct merge reference
                ( $recordObj1, $recordObj2 ) = ( $recordObj2, $recordObj1 );
            }

            # Getting frameworktext
            my $frameworktext1           = Koha::Authority::Types->find( $recordObj1->authtypecode );
            my $frameworktext2           = Koha::Authority::Types->find( $recordObj2->authtypecode );
            my $frameworktextdestination = Koha::Authority::Types->find($framework);

            # Creating a loop for display

            my @records = (
                {
                    recordid      => $mergereference,
                    record        => $recordObj1->record,
                    frameworkcode => $recordObj1->authtypecode,
                    frameworktext => $frameworktext1->authtypetext,
                    display       => $recordObj1->createMergeHash($tagslib),
                    reference     => 1,
                },
                {
                    recordid      => $notreference,
                    record        => $recordObj2->record,
                    frameworkcode => $recordObj2->authtypecode,
                    frameworktext => $frameworktext2->authtypetext,
                    display       => $recordObj2->createMergeHash($tagslib),
                },
            );

            # Parameters
            $template->param(
                recordid1         => $mergereference,
                recordid2         => $notreference,
                records           => \@records,
                framework         => $framework,
                frameworktext     => $frameworktextdestination->authtypetext,
                multipleauthtypes => ( $recordObj1->authtypecode ne $recordObj2->authtypecode ) ? 1 : 0,
            );
        } else {

            # Ask the user to choose which record will be the kept
            $template->param(
                choosereference => 1,
                recordid1       => $authid[0],
                recordid2       => $authid[1],
                title1          => $recordObj1->authorized_heading,
                title2          => $recordObj2->authorized_heading,
            );
            if ( $recordObj1->authtypecode ne $recordObj2->authtypecode ) {
                my $authority_types = Koha::Authority::Types->search(
                    { authtypecode => { '!=' => '' } },
                    { order_by     => ['authtypetext'] }
                );
                my $frameworktext1 = Koha::Authority::Types->find( $recordObj1->authtypecode );
                my $frameworktext2 = Koha::Authority::Types->find( $recordObj2->authtypecode );
                $template->param(
                    frameworkselect => $authority_types->unblessed,
                    frameworkcode1  => $recordObj1->authtypecode,
                    frameworkcode2  => $recordObj2->authtypecode,
                    frameworklabel1 => $frameworktext1->authtypetext,
                    frameworklabel2 => $frameworktext2->authtypetext,
                );
            }
        }
    }
}

if (@errors) {
    $template->param( errors => \@errors );
}
output_html_with_http_headers $input, $cookie, $template->output;
