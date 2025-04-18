#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use CGI      qw ( -utf8 );
use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use C4::Context;

use Koha::Caches;
use Koha::AuthorisedValues;
use Koha::BiblioFrameworks;
use Koha::Database;

# retrieve parameters
my $input                 = CGI->new;
my $frameworkcode         = $input->param('frameworkcode')         || '';    # set to select framework
my $existingframeworkcode = $input->param('existingframeworkcode') || '';
my $searchfield           = $input->param('searchfield')           || 0;
$searchfield =~ s/\,//g;

my $offset    = $input->param('offset') || 0;
my $op        = $input->param('op')     || '';
my $dspchoice = $input->cookie("marctagstructure_selectdisplay") // $input->param('select_display');
my $pagesize  = 20;

my $dbh   = C4::Context->dbh;
my $cache = Koha::Caches->get_instance();

# open template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "admin/marctagstructure.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { parameters => 'manage_marc_frameworks' },
    }
);

my $frameworks = Koha::BiblioFrameworks->search( {}, { order_by => ['frameworktext'] } );

# check that framework is defined in marc_tag_structure
my $sth = $dbh->prepare("select count(*) from marc_tag_structure where frameworkcode=?");
$sth->execute($frameworkcode);
my ($frameworkexist) = $sth->fetchrow;
unless ($frameworkexist) {

    # if frameworkcode does not exists, then OP must be changed to "create framework" if we are not on the way to create it
    # (op = itemtyp_create_confirm)
    if ( $op eq "cud-framework_create_confirm" ) {
        duplicate_framework( $frameworkcode, $existingframeworkcode );
        $op = "";    # unset $op to go back to framework list
    } else {
        $op = "framework_create";
    }
}

my $framework = $frameworks->search( { frameworkcode => $frameworkcode } )->next;
$template->param(
    frameworks        => $frameworks,
    framework         => $framework,
    ( $op || 'else' ) => 1,
);

################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ( $op eq 'add_form' ) {

    #---- if primkey exists, it's a modify action, so read values to modify...
    my $data;
    if ($searchfield) {
        $sth = $dbh->prepare(
            "select tagfield,liblibrarian,libopac,repeatable,mandatory,important,authorised_value,ind1_defaultvalue,ind2_defaultvalue from marc_tag_structure where tagfield=? and frameworkcode=?"
        );
        $sth->execute( $searchfield, $frameworkcode );
        $data = $sth->fetchrow_hashref;
    }

    if ($searchfield) {
        $template->param( searchfield            => $searchfield );
        $template->param( 'heading_modify_tag_p' => 1 );
    } else {
        $template->param( 'heading_add_tag_p' => 1 );
    }
    $template->param( 'use_heading_flags_p' => 1 );
    $template->param(
        liblibrarian      => $data->{'liblibrarian'},
        libopac           => $data->{'libopac'},
        repeatable        => $data->{'repeatable'},
        mandatory         => $data->{'mandatory'},
        important         => $data->{'important'},
        authorised_value  => $data->{authorised_value},
        ind1_defaultvalue => $data->{'ind1_defaultvalue'},
        ind2_defaultvalue => $data->{'ind2_defaultvalue'}
    );    # FIXME: move checkboxes to presentation layer
          # END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
    # called by add_form, used to insert/modify data in DB
} elsif ( $op eq 'cud-add_validate' ) {
    my $tagfield          = $input->param('tagfield');
    my $liblibrarian      = $input->param('liblibrarian');
    my $libopac           = $input->param('libopac');
    my $repeatable        = $input->param('repeatable') ? 1 : 0;
    my $mandatory         = $input->param('mandatory')  ? 1 : 0;
    my $important         = $input->param('important')  ? 1 : 0;
    my $authorised_value  = $input->param('authorised_value');
    my $ind1_defaultvalue = $input->param('ind1_defaultvalue');
    my $ind2_defaultvalue = $input->param('ind2_defaultvalue');
    my $error;

    if ( $input->param('modif') ) {
        $sth = $dbh->prepare(
            "UPDATE marc_tag_structure SET liblibrarian=? ,libopac=? ,repeatable=? ,mandatory=? ,important=? ,authorised_value=?, ind1_defaultvalue=?, ind2_defaultvalue=? WHERE frameworkcode=? AND tagfield=?"
        );
        $sth->execute(
            $liblibrarian,
            $libopac,
            $repeatable,
            $mandatory,
            $important,
            $authorised_value,
            $ind1_defaultvalue,
            $ind2_defaultvalue,
            $frameworkcode,
            $tagfield
        );
    } else {
        my $schema = Koha::Database->new()->schema();
        my $rs     = $schema->resultset('MarcTagStructure');
        my $field  = $rs->find( { tagfield => $tagfield, frameworkcode => $frameworkcode } );
        if ( !$field ) {
            $sth = $dbh->prepare(
                "INSERT INTO marc_tag_structure (tagfield,liblibrarian,libopac,repeatable,mandatory,important,authorised_value,ind1_defaultvalue,ind2_defaultvalue,frameworkcode) values (?,?,?,?,?,?,?,?,?,?)"
            );
            $sth->execute(
                $tagfield,
                $liblibrarian,
                $libopac,
                $repeatable,
                $mandatory,
                $important,
                $authorised_value,
                $ind1_defaultvalue,
                $ind2_defaultvalue,
                $frameworkcode
            );
        } else {
            $error = 'duplicate_tagfield';
        }
    }
    if ( !$error ) {
        $cache->clear_from_cache("MarcStructure-0-$frameworkcode");
        $cache->clear_from_cache("MarcStructure-1-$frameworkcode");
        $cache->clear_from_cache("MarcSubfieldStructure-$frameworkcode");
        $cache->clear_from_cache("MarcCodedFields-$frameworkcode");
    }
    my $redirect_url = "/cgi-bin/koha/admin/marctagstructure.pl?searchfield=$tagfield&frameworkcode=$frameworkcode";
    if ($error) {
        $redirect_url .= "&error=$error";
    }
    print $input->redirect($redirect_url);
    exit;

    # END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
    # called by default form, used to confirm deletion of data in DB
} elsif ( $op eq 'delete_confirm' ) {
    $sth = $dbh->prepare(
        "select tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value,ind1_defaultvalue,ind2_defaultvalue from marc_tag_structure where tagfield=? and frameworkcode=?"
    );
    $sth->execute( $searchfield, $frameworkcode );
    my $data = $sth->fetchrow_hashref;
    $template->param(
        liblibrarian => $data->{'liblibrarian'},
        searchfield  => $searchfield
    );

    # END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
    # called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ( $op eq 'cud-delete_confirmed' ) {
    my $sth1 = $dbh->prepare("DELETE FROM marc_tag_structure      WHERE tagfield=? AND frameworkcode=?");
    my $sth2 = $dbh->prepare("DELETE FROM marc_subfield_structure WHERE tagfield=? AND frameworkcode=?");
    $sth1->execute( $searchfield, $frameworkcode );
    $sth2->execute( $searchfield, $frameworkcode );
    $cache->clear_from_cache("MarcStructure-0-$frameworkcode");
    $cache->clear_from_cache("MarcStructure-1-$frameworkcode");
    $cache->clear_from_cache("MarcSubfieldStructure-$frameworkcode");
    $cache->clear_from_cache("MarcCodedFields-$frameworkcode");
    print $input->redirect(
        "/cgi-bin/koha/admin/marctagstructure.pl?searchfield=$searchfield&amp;frameworkcode=$frameworkcode");
    exit;

    # END $OP eq DELETE_CONFIRMED
################## ITEMTYPE_CREATE ##################################
    # called automatically if an unexisting  frameworkis selected
} elsif ( $op eq 'framework_create' ) {
    my $frameworks = Koha::BiblioFrameworks->search(
        { 'marc_tag_structure.frameworkcode' => { '!=' => undef } },
        {
            join     => 'marc_tag_structure',
            distinct => 1
        }
    );
    $template->param( existing_frameworks => $frameworks );

################## DEFAULT ##################################
} else {    # DEFAULT
    my $error_code = $input->param('error');
    if ($error_code) {
        if ( $error_code eq 'duplicate_tagfield' ) {
            $template->param( 'blocking_error' => $error_code );
        }
    }

    # here, $op can be unset or set to "cud-framework_create_confirm".
    if ( $searchfield ne '' ) {
        $template->param( searchfield => $searchfield );
    }
    my $cnt = 0;
    if ($dspchoice) {

        #here, user only wants used tags/subfields displayed
        $searchfield =~ s/\'/\\\'/g;
        my @data = split( ' ', $searchfield );
        my $sth  = $dbh->prepare( "
		      SELECT marc_tag_structure.tagfield AS mts_tagfield,
		              marc_tag_structure.liblibrarian as mts_liblibrarian,
		              marc_tag_structure.libopac as mts_libopac,
		              marc_tag_structure.repeatable as mts_repeatable,
		              marc_tag_structure.mandatory as mts_mandatory,
                      marc_tag_structure.important as mts_important,
		              marc_tag_structure.authorised_value as mts_authorized_value,
                  marc_tag_structure.ind1_defaultvalue as mts_ind1_defaultvalue,
                  marc_tag_structure.ind1_defaultvalue as mts_ind2_defaultvalue,
		              marc_subfield_structure.*
                FROM marc_tag_structure 
                LEFT JOIN marc_subfield_structure ON (marc_tag_structure.tagfield=marc_subfield_structure.tagfield AND marc_tag_structure.frameworkcode=marc_subfield_structure.frameworkcode) WHERE (marc_tag_structure.tagfield >= ? and marc_tag_structure.frameworkcode=?) AND marc_subfield_structure.tab>=0 ORDER BY marc_tag_structure.tagfield,marc_subfield_structure.tagsubfield"
        );

        #could be ordoned by tab
        $sth->execute( $data[0], $frameworkcode );
        my @results = ();
        while ( my $data = $sth->fetchrow_hashref ) {
            push( @results, $data );
            $cnt++;
        }

        my @loop_data = ();
        my $j         = 1;
        my $i         = $offset;
        while ( $i < $cnt ) {
            my %row_data;    # get a fresh hash for the row data
            $row_data{tagfield}          = $results[$i]->{'mts_tagfield'};
            $row_data{liblibrarian}      = $results[$i]->{'mts_liblibrarian'};
            $row_data{repeatable}        = $results[$i]->{'mts_repeatable'};
            $row_data{mandatory}         = $results[$i]->{'mts_mandatory'};
            $row_data{important}         = $results[$i]->{'mts_important'};
            $row_data{authorised_value}  = $results[$i]->{'mts_authorised_value'};
            $row_data{ind1_defaultvalue} = $results[$i]->{'mts_ind1_defaultvalue'};
            $row_data{ind2_defaultvalue} = $results[$i]->{'mts_ind2_defaultvalue'};
            $j                           = $i;
            my @internal_loop = ();

            while ( ( $j < $cnt ) and ( $results[$i]->{'tagfield'} == $results[$j]->{'tagfield'} ) ) {
                my %subfield_data;
                $subfield_data{tagsubfield}      = $results[$j]->{'tagsubfield'};
                $subfield_data{liblibrarian}     = $results[$j]->{'liblibrarian'};
                $subfield_data{kohafield}        = $results[$j]->{'kohafield'};
                $subfield_data{repeatable}       = $results[$j]->{'repeatable'};
                $subfield_data{mandatory}        = $results[$j]->{'mandatory'};
                $subfield_data{important}        = $results[$j]->{'important'};
                $subfield_data{tab}              = $results[$j]->{'tab'};
                $subfield_data{seealso}          = $results[$j]->{'seealso'};
                $subfield_data{authorised_value} = $results[$j]->{'authorised_value'};
                $subfield_data{authtypecode}     = $results[$j]->{'authtypecode'};
                $subfield_data{value_builder}    = $results[$j]->{'value_builder'};

                # 				warn "tagfield :  ".$results[$j]->{'tagfield'}." tagsubfield :".$results[$j]->{'tagsubfield'};
                push @internal_loop, \%subfield_data;
                $j++;
            }
            $row_data{'subfields'} = \@internal_loop;
            push( @loop_data, \%row_data );
            $i = $j;
        }
        $template->param(
            select_display => "True",
            loop           => \@loop_data
        );
    } else {

        # Hidden feature: If search was field$subfield, redirect to the subfield edit form
        my ( $tagfield, $tagsubfield ) = split /\$/, $searchfield;
        if ($tagsubfield) {
            print $input->redirect(
                sprintf
                    '/cgi-bin/koha/admin/marc_subfields_structure.pl?op=add_form&tagfield=%s&frameworkcode=%s#%s_panel',
                $tagfield, $frameworkcode, $tagsubfield
            );
            exit;
        }

        #here, normal old style : display every tags
        my ( $count, $results ) = StringSearch( $searchfield, $frameworkcode );
        $cnt = $count;
        my @loop_data = ();
        for ( my $i = $offset ; $i < $count ; $i++ ) {
            my %row_data;    # get a fresh hash for the row data
            $row_data{tagfield}          = $results->[$i]{'tagfield'};
            $row_data{liblibrarian}      = $results->[$i]{'liblibrarian'};
            $row_data{repeatable}        = $results->[$i]{'repeatable'};
            $row_data{mandatory}         = $results->[$i]{'mandatory'};
            $row_data{important}         = $results->[$i]{'important'};
            $row_data{authorised_value}  = $results->[$i]{'authorised_value'};
            $row_data{ind1_defaultvalue} = $results->[$i]{'ind1_defaultvalue'};
            $row_data{ind2_defaultvalue} = $results->[$i]{'ind2_defaultvalue'};
            push( @loop_data, \%row_data );
        }
        $template->param( loop => \@loop_data );
    }
    if ( $offset > 0 ) {
        $template->param(
            isprevpage  => $offset,
            prevpage    => $offset - $pagesize,
            searchfield => $searchfield,
        );
    }
    if ( $offset + $pagesize < $cnt ) {
        $template->param(
            nextpage    => $offset + $pagesize,
            searchfield => $searchfield,
        );
    }
}    #---- END $OP eq DEFAULT

output_html_with_http_headers $input, $cookie, $template->output;

#
# the sub used for searches
#
sub StringSearch {
    my ( $searchstring, $frameworkcode ) = @_;
    my $sth = C4::Context->dbh->prepare( "
    SELECT tagfield,liblibrarian,libopac,repeatable,mandatory,important,authorised_value,ind1_defaultvalue,ind2_defaultvalue
     FROM  marc_tag_structure
     WHERE (tagfield >= ? and frameworkcode=?)
    ORDER BY tagfield
    " );
    $sth->execute( $searchstring, $frameworkcode );
    my $results = $sth->fetchall_arrayref( {} );
    return ( scalar(@$results), $results );
}

#
# the sub used to duplicate a framework from an existing one in MARC parameters tables.
#
sub duplicate_framework {
    my ( $newframeworkcode, $oldframeworkcode ) = @_;
    my $dbh = C4::Context->dbh;
    $dbh->do(
        q|INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, important, authorised_value, ind1_defaultvalue, ind2_defaultvalue, frameworkcode)
        SELECT tagfield,liblibrarian,libopac,repeatable,mandatory,important,authorised_value, ind1_defaultvalue, ind2_defaultvalue, ? from marc_tag_structure where frameworkcode=?|,
        undef, $newframeworkcode, $oldframeworkcode
    );

    $dbh->do(
        q|INSERT INTO marc_subfield_structure (frameworkcode,tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,important,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,seealso,hidden,link,defaultvalue,maxlength)
        SELECT ?,tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,important,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,seealso,hidden,link,defaultvalue,maxlength from marc_subfield_structure where frameworkcode=?
    |, undef, $newframeworkcode, $oldframeworkcode
    );
}

