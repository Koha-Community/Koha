#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

=head1 tools/letter.pl

 ALGO :
 this script use an $op to know what to do.
 if $op is empty or none of the above values,
	- the default screen is build (with all records, or filtered datas).
	- the   user can clic on add, modify or delete record.
 if $op=add_form
	- if primkey exists, this is a modification,so we read the $primkey record
	- builds the add/modify form
 if $op=add_validate
	- the user has just send datas, so we create/modify the record
 if $op=delete_form
	- we show the record having primkey=$primkey and ask for deletion validation form
 if $op=delete_confirm
	- we delete the record having primkey=$primkey

=cut

use strict;
use CGI;
use C4::Date;
use C4::Auth;
use C4::Context;
use C4::Output;

sub StringSearch {
    my ( $searchstring, $type ) = @_;
    my $dbh = C4::Context->dbh;
    $searchstring =~ s/\'/\\\'/g;
    my @data = split( ' ', $searchstring );
    my $count = @data;
    my $sth =
      $dbh->prepare(
        "Select * from letter where (code like ?) order by module,code");
    $sth->execute("$data[0]%");
    my @results;
    my $cnt = 0;

    while ( my $data = $sth->fetchrow_hashref ) {
        push( @results, $data );
        $cnt++;
    }

    #  $sth->execute;
    $sth->finish;
    return ( $cnt, \@results );
}

my $input       = new CGI;
my $searchfield = $input->param('searchfield');
my $offset      = $input->param('offset');
my $script_name = "/cgi-bin/koha/tools/letter.pl";
my $code        = $input->param('code');
my $module      = $input->param('module');
my $content     = $input->param('content');
my $pagesize    = 20;
my $op          = $input->param('op');
$searchfield =~ s/\,//g;
my $dbh = C4::Context->dbh;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "tools/letter.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 1 },
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
}

$template->param( action => $script_name );
################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ( $op eq 'add_form' ) {

    #---- if primkey exists, it's a modify action, so read values to modify...
    my $letter;
    if ($code) {
        my $sth =
          $dbh->prepare("select * from letter where module=? and code=?");
        $sth->execute( $module, $code );
        $letter = $sth->fetchrow_hashref;
        $sth->finish;
    }

    # build field list
    my @SQLfieldname;
    my %line = ( 'value' => "LibrarianFirstname", 'text' => 'LibrarianFirstname' );
    push @SQLfieldname, \%line;
    my %line = ( 'value' => "LibrarianSurname", 'text' => 'LibrarianSurname' );
    push @SQLfieldname, \%line;
    my %line = ( 'value' => "LibrarianEmailaddress", 'text' => 'LibrarianEmailaddress' );
    push @SQLfieldname, \%line;
    my $sth2 = $dbh->prepare("SHOW COLUMNS from branches");
    $sth2->execute;
    my %line = ( 'value' => "", 'text' => '---BRANCHES---' );
    push @SQLfieldname, \%line;

    while ( ( my $field ) = $sth2->fetchrow_array ) {
        my %line = ( 'value' => "branches." . $field, 'text' => "branches." . $field );
        push @SQLfieldname, \%line;
    }

    # add acquisition specific tables
    if ( index( $module, "acquisition" ) > 0 ) {
        my $sth2 = $dbh->prepare("SHOW COLUMNS from aqbooksellers");
        $sth2->execute;
        my %line = ( 'value' => "", 'text' => '---BOOKSELLERS---' );
        push @SQLfieldname, \%line;
        while ( ( my $field ) = $sth2->fetchrow_array ) {
            my %line = (
                'value' => "aqbooksellers." . $field,
                'text'  => "aqbooksellers." . $field
            );
            push @SQLfieldname, \%line;
        }
        my $sth2 = $dbh->prepare("SHOW COLUMNS from aqorders");
        $sth2->execute;
        my %line = ( 'value' => "", 'text' => '---ORDERS---' );
        push @SQLfieldname, \%line;
        while ( ( my $field ) = $sth2->fetchrow_array ) {
            my %line = (
                'value' => "aqorders." . $field,
                'text'  => "aqorders." . $field
            );
            push @SQLfieldname, \%line;
        }

        # add issues specific tables
    }
    elsif ( index( $module, "issues" ) > 0 ) {
        my $sth2 = $dbh->prepare("SHOW COLUMNS from aqbooksellers");
        $sth2->execute;
        my %line = ( 'value' => "", 'text' => '---BOOKSELLERS---' );
        push @SQLfieldname, \%line;
        while ( ( my $field ) = $sth2->fetchrow_array ) {
            my %line = (
                'value' => "aqbooksellers." . $field,
                'text'  => "aqbooksellers." . $field
            );
            push @SQLfieldname, \%line;
        }
        my $sth2 = $dbh->prepare("SHOW COLUMNS from serial");
        $sth2->execute;
        my %line = ( 'value' => "", 'text' => '---SERIALS---' );
        push @SQLfieldname, \%line;
        while ( ( my $field ) = $sth2->fetchrow_array ) {
            my %line = ( 'value' => "serial." . $field, 'text' => "serial." . $field );
            push @SQLfieldname, \%line;
        }
        my $sth2 = $dbh->prepare("SHOW COLUMNS from subscription");
        $sth2->execute;
        my %line = ( 'value' => "", 'text' => '---SUBSCRIPTION---' );
        push @SQLfieldname, \%line;
        while ( ( my $field ) = $sth2->fetchrow_array ) {
            my %line = (
                'value' => "subscription." . $field,
                'text'  => "subscription." . $field
            );
            push @SQLfieldname, \%line;
        }
        my %line = ( 'value' => "", 'text' => '---Biblio---' );
        push @SQLfieldname, \%line;
        my %line = ('value' => "biblio.title",'text'  => "Title");
        push @SQLfieldname, \%line;
        my %line = ('value' => "biblio.author",'text'  => "Author");
        push @SQLfieldname, \%line;
        my %line = ('value' => "biblio.serial",'text'  => "Serial");
        push @SQLfieldname, \%line;
    }
    else {
        my $sth2 = $dbh->prepare("SHOW COLUMNS from biblio");
        $sth2->execute;
        my %line = ( 'value' => "", 'text' => '---BIBLIO---' );

        push @SQLfieldname, \%line;
        while ( ( my $field ) = $sth2->fetchrow_array ) {

# note : %line is redefined, otherwise \%line contains the same value for every entry of the list
            my %line = ( 'value' => "biblio." . $field, 'text' => "biblio." . $field );
            push @SQLfieldname, \%line;
        }
        my $sth2 = $dbh->prepare("SHOW COLUMNS from biblioitems");
        $sth2->execute;
        my %line = ( 'value' => "", 'text' => '---BIBLIOITEMS---' );
        push @SQLfieldname, \%line;
        while ( ( my $field ) = $sth2->fetchrow_array ) {
            my %line = (
                'value' => "biblioitems." . $field,
                'text'  => "biblioitems." . $field
            );
            push @SQLfieldname, \%line;
        }
        my %line = ( 'value' => "", 'text' => '---ITEMS---' );
        push @SQLfieldname, \%line;
        my %line = ( 'value' => "items.content", 'text' => 'items.content' );
        push @SQLfieldname, \%line;

        my $sth2 = $dbh->prepare("SHOW COLUMNS from borrowers");
        $sth2->execute;
        my %line = ( 'value' => "", 'text' => '---BORROWERS---' );
        push @SQLfieldname, \%line;
        while ( ( my $field ) = $sth2->fetchrow_array ) {
            my %line = (
                'value' => "borrowers." . $field,
                'text'  => "borrowers." . $field
            );
            push @SQLfieldname, \%line;
        }
    }
    if ($code) {
        $template->param( modify => 1 );
        $template->param( code   => $letter->{code} );
    }
    else {
        $template->param( adding => 1 );
    }
    $template->param(
        name    => $letter->{name},
        title   => $letter->{title},
        content => ( $content ? $content : $letter->{content} ),
        ( $module ? $module : $letter->{module} ) => 1,
        SQLfieldname => \@SQLfieldname,
    );

    # END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
    # called by add_form, used to insert/modify data in DB
}
elsif ( $op eq 'add_validate' ) {
    my $dbh = C4::Context->dbh;
    my $sth =
      $dbh->prepare(
        "replace letter (module,code,name,title,content) values (?,?,?,?,?)");
    $sth->execute(
        $input->param('module'), $input->param('code'),
        $input->param('name'),   $input->param('title'),
        $input->param('content')
    );
    $sth->finish;
    print $input->redirect("letter.pl");
    exit;

    # END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
    # called by default form, used to confirm deletion of data in DB
}
elsif ( $op eq 'delete_confirm' ) {
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("select * from letter where code=?");
    $sth->execute($code);
    my $data = $sth->fetchrow_hashref;
    $sth->finish;
    $template->param( module  => $data->{module} );
    $template->param( code    => $code );
    $template->param( name    => $data->{'name'} );
    $template->param( content => $data->{'content'} );

    # END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
  # called by delete_confirm, used to effectively confirm deletion of data in DB
}
elsif ( $op eq 'delete_confirmed' ) {
    my $dbh    = C4::Context->dbh;
    my $code   = uc( $input->param('code') );
    my $module = $input->param('module');
    my $sth    = $dbh->prepare("delete from letter where module=? and code=?");
    $sth->execute( $module, $code );
    $sth->finish;
    print $input->redirect("/cgi-bin/koha/tools/letter.pl");
    return;

    # END $OP eq DELETE_CONFIRMED
################## DEFAULT ##################################
}
else {    # DEFAULT
    if ( $searchfield ne '' ) {
        $template->param( search      => 1 );
        $template->param( searchfield => $searchfield );
    }
    my ( $count, $results ) = StringSearch( $searchfield, 'web' );
    my $toggle    = 0;
    my @loop_data = ();
    for (
        my $i = $offset ;
        $i < ( $offset + $pagesize < $count ? $offset + $pagesize : $count ) ;
        $i++
      )
    {
        if ( $toggle ) {
            $toggle = 0;
        }
        else {
            $toggle = 1;
        }
        my %row_data;
        $row_data{toggle} = $toggle;
        $row_data{module} = $results->[$i]{'module'};
        $row_data{code}   = $results->[$i]{'code'};
        $row_data{name}   = $results->[$i]{'name'};
        push( @loop_data, \%row_data );
    }
    $template->param( letter => \@loop_data );
}    #---- END $OP eq DEFAULT

output_html_with_http_headers $input, $cookie, $template->output;

