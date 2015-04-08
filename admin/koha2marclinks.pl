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

use strict;
use warnings;
use C4::Output;
use C4::Auth;
use CGI;
use C4::Context;
use C4::Biblio;


my $input       = new CGI;
my $tablename   = $input->param('tablename');
$tablename      = "biblio" unless ($tablename);
my $kohafield   = $input->param('kohafield');
my $op          = $input->param('op');
my $script_name = 'koha2marclinks.pl';

my ( $template, $borrowernumber, $cookie ) = get_template_and_user (
    {
        template_name   => "admin/koha2marclinks.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 'parameters_remaining_permissions' },
        debug           => 1,
    }
);

if ($op) {
    $template->param(
        script_name => $script_name,
        $op         => 1
    );    # we show only the TMPL_VAR names $op
}
else {
    $template->param(
        script_name => $script_name,
        else        => 1
    );    # we show only the TMPL_VAR names $op
    $op = q{};
}

my $dbh = C4::Context->dbh;
my $cache = Koha::Cache->get_instance();

################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ( $op eq 'add_form' ) {
    my $data;
    my $sth =
      $dbh->prepare(
"select tagfield,tagsubfield,liblibrarian as lib,tab from marc_subfield_structure where kohafield=? AND frameworkcode=''"
      );
    $sth->execute( $tablename . "." . $kohafield );
    my ( $defaulttagfield, $defaulttagsubfield, $defaultliblibrarian ) =
      $sth->fetchrow;

    for ( my $i = 0 ; $i <= 9 ; $i++ ) {
        my $sth2 =
          $dbh->prepare(
"select tagfield,tagsubfield,liblibrarian as lib,tab from marc_subfield_structure where tagfield like ? AND frameworkcode=''"
          );
        $sth2->execute("$i%");
        my @marcarray;
        push @marcarray, " ";
        while ( my ( $field, $tagsubfield, $liblibrarian ) =
            $sth2->fetchrow_array )
        {
            push @marcarray, "$field $tagsubfield - $liblibrarian";
        }
        my $marclist = {
            values  => \@marcarray,
            default => "$defaulttagfield $defaulttagsubfield - $defaultliblibrarian",
        };
        $template->param( "marclist$i" => $marclist );
    }
    $template->param(
        tablename => $tablename,
        kohafield => $kohafield
    );

    # END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
    # called by add_form, used to insert/modify data in DB
}
elsif ( $op eq 'add_validate' ) {

    #----- empty koha field :
    $dbh->do(
"update marc_subfield_structure set kohafield='' where kohafield='$tablename.$kohafield'"
    );

    #---- reload if not empty
    my @temp = split / /, $input->param('marc');
    $dbh->do(
"update marc_subfield_structure set kohafield='$tablename.$kohafield' where tagfield='$temp[0]' and tagsubfield='$temp[1]'"
    );
    # We could get a list of all frameworks and do them one-by-one, or zap
    # everything.
    $cache->flush_all();
    print
"Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=koha2marclinks.pl?tablename=$tablename\"></html>";
    exit;

    # END $OP eq ADD_VALIDATE
################## DEFAULT ##################################
}
else {    # DEFAULT
    my $sth =
      $dbh->prepare(
q|select tagfield,tagsubfield,liblibrarian,kohafield from marc_subfield_structure where kohafield is not NULL and kohafield != ''|
      );
    $sth->execute;
    my %fields;
    while ( ( my $tagfield, my $tagsubfield, my $liblibrarian, my $kohafield ) =
        $sth->fetchrow ) {
        $fields{$kohafield}->{tagfield}     = $tagfield;
        $fields{$kohafield}->{tagsubfield}  = $tagsubfield;
        $fields{$kohafield}->{liblibrarian} = $liblibrarian;
    }

  #XXX: This might not work. Maybe should use a DBI call instead of SHOW COLUMNS
    my $sth2 = $dbh->prepare("SHOW COLUMNS from $tablename");
    $sth2->execute;

    my @loop_data = ();
    while ( ( my $field ) = $sth2->fetchrow_array ) {
        my %row_data;    # get a fresh hash for the row data
        $row_data{tagfield} = $fields{ $tablename . "." . $field }->{tagfield};
        $row_data{tagsubfield} =
          $fields{ $tablename . "." . $field }->{tagsubfield};
        $row_data{liblibrarian} =
          $fields{ $tablename . "." . $field }->{liblibrarian};
        $row_data{kohafield} = $field;
        $row_data{edit} =
"$script_name?op=add_form&amp;tablename=$tablename&amp;kohafield=$field";
        push( @loop_data, \%row_data );
    }
    my $tablenames = {
        values  => [ 'biblio', 'biblioitems', 'items' ],
        default => $tablename,
    };
    $template->param(
        loop      => \@loop_data,
        tablename => $tablenames,
    );
}    #---- END $OP eq DEFAULT
output_html_with_http_headers $input, $cookie, $template->output;
