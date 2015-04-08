#!/usr/bin/perl

#script to administer the categories table
#written 20/02/2002 by paul.poulain@free.fr

# ALGO :
# this script use an $op to know what to do.
# if $op is empty or none of the above values,
#	- the default screen is build (with all records, or filtered datas).
#	- the   user can clic on add, modify or delete record.
# if $op=add_form
#	- if primkey exists, this is a modification,so we read the $primkey record
#	- builds the add/modify form
# if $op=add_validate
#	- the user has just send datas, so we create/modify the record
# if $op=delete_form
#	- we show the record having primkey=$primkey and ask for deletion validation form
# if $op=delete_confirm
#	- we delete the record having primkey=$primkey

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

use CGI;
use C4::Context;
use C4::Auth;
use C4::Branch;
use C4::Output;
use C4::Dates;
use C4::Form::MessagingPreferences;
use Koha::Database;

sub StringSearch {
    my ( $searchstring, $type ) = @_;
    my $dbh = C4::Context->dbh;
    $searchstring //= '';
    $searchstring =~ s/\'/\\\'/g;
    my @data = split( ' ', $searchstring );
    push @data, q{} if $#data == -1;
    my $count = @data;
    my $sth   = $dbh->prepare("Select * from categories where (description like ?) order by category_type,description,categorycode");
    $sth->execute("$data[0]%");
    my @results;

    while ( my $data = $sth->fetchrow_hashref ) {
        push( @results, $data );
    }

    #  $sth->execute;
    $sth->finish;
    return ( scalar(@results), \@results );
}

my $input         = new CGI;
my $searchfield   = $input->param('description');
my $script_name   = "/cgi-bin/koha/admin/categorie.pl";
my $categorycode  = $input->param('categorycode');
my $op            = $input->param('op') // '';
my $block_expired = $input->param("block_expired");

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "admin/categorie.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 'parameters_remaining_permissions' },
        debug           => 1,
    }
);

$template->param(
    script_name  => $script_name,
    categorycode => $categorycode,
    searchfield  => $searchfield
);

################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ( $op eq 'add_form' ) {
    $template->param( add_form => 1 );

    #---- if primkey exists, it's a modify action, so read values to modify...
    my $data;
    my @selected_branches;
    if ($categorycode) {
        my $dbh = C4::Context->dbh;
        my $sth =
          $dbh->prepare("SELECT * FROM categories WHERE categorycode=?");
        $sth->execute($categorycode);
        $data = $sth->fetchrow_hashref;

        $sth = $dbh->prepare(
            "SELECT b.branchcode, b.branchname 
            FROM categories_branches AS cb, branches AS b 
            WHERE cb.branchcode = b.branchcode AND cb.categorycode = ?
        ");
        $sth->execute($categorycode);
        while ( my $branch = $sth->fetchrow_hashref ) {
            push @selected_branches, $branch;
        }
        $sth->finish;
    }

    if (   $data->{'enrolmentperioddate'}
        && $data->{'enrolmentperioddate'} eq '0000-00-00' )
    {
        $data->{'enrolmentperioddate'} = undef;
    }

    $data->{'category_type'} //= '';

    my $branches = GetBranches();
    my @branches_loop;
    foreach my $branch ( sort keys %$branches ) {
        my $selected =
          ( grep { $$_{branchcode} eq $branch } @selected_branches ) ? 1 : 0;
        push @branches_loop,
          {
            branchcode => $$branches{$branch}{branchcode},
            branchname => $$branches{$branch}{branchname},
            selected   => $selected,
          };
    }

    $template->param(
        branches_loop       => \@branches_loop,
        description         => $data->{'description'},
        enrolmentperiod     => $data->{'enrolmentperiod'},
        enrolmentperioddate => $data->{'enrolmentperioddate'},
        upperagelimit       => $data->{'upperagelimit'},
        dateofbirthrequired => $data->{'dateofbirthrequired'},
        enrolmentfee        => sprintf( "%.2f", $data->{'enrolmentfee'} || 0 ),
        overduenoticerequired => $data->{'overduenoticerequired'},
        issuelimit            => $data->{'issuelimit'},
        reservefee            => sprintf( "%.2f", $data->{'reservefee'} || 0 ),
        hidelostitems         => $data->{'hidelostitems'},
        category_type         => $data->{'category_type'},
        default_privacy       => $data->{'default_privacy'},
        SMSSendDriver         => C4::Context->preference("SMSSendDriver"),
        "type_" . $data->{'category_type'} => 1,
        BlockExpiredPatronOpacActions =>
          $data->{'BlockExpiredPatronOpacActions'},
        TalkingTechItivaPhone =>
          C4::Context->preference("TalkingTechItivaPhoneNotification"),
    );

    if ( C4::Context->preference('EnhancedMessagingPreferences') ) {
        C4::Form::MessagingPreferences::set_form_values(
            { categorycode => $categorycode }, $template );
    }

    # END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
    # called by add_form, used to insert/modify data in DB
}
elsif ( $op eq 'add_validate' ) {
    $template->param( add_validate => 1 );

    my $is_a_modif = $input->param("is_a_modif");

    my $dbh = C4::Context->dbh;

    if ( $input->param('enrolmentperioddate') ) {
        $input->param(
            'enrolmentperioddate' => C4::Dates::format_date_in_iso(
                $input->param('enrolmentperioddate')
            )
        );
    }

    if ($is_a_modif) {
        my $sth = $dbh->prepare( "
                UPDATE categories
                SET description=?,
                    enrolmentperiod=?,
                    enrolmentperioddate=?,
                    upperagelimit=?,
                    dateofbirthrequired=?,
                    enrolmentfee=?,
                    reservefee=?,
                    hidelostitems=?,
                    overduenoticerequired=?,
                    category_type=?,
                    BlockExpiredPatronOpacActions=?,
                    default_privacy=?
                WHERE categorycode=?"
        );
        $sth->execute(
            map { $input->param($_) } (
                'description',           'enrolmentperiod',
                'enrolmentperioddate',   'upperagelimit',
                'dateofbirthrequired',   'enrolmentfee',
                'reservefee',            'hidelostitems',
                'overduenoticerequired', 'category_type',
                'block_expired',         'default_privacy',
                'categorycode'
            )
        );
        my @branches = $input->param("branches");
        if (@branches) {
            $sth = $dbh->prepare(
                "DELETE FROM categories_branches WHERE categorycode = ?"
            );
            $sth->execute( $input->param("categorycode") );
            $sth = $dbh->prepare(
                "INSERT INTO categories_branches ( categorycode, branchcode ) VALUES ( ?, ? )"
            );
            for my $branchcode (@branches) {
                next if not $branchcode;
                $sth->bind_param( 1, $input->param("categorycode") );
                $sth->bind_param( 2, $branchcode );
                $sth->execute;
            }
        }
        $sth->finish;
    }
    else {
        my $sth = $dbh->prepare( "
            INSERT INTO categories (
                categorycode,
                description,
                enrolmentperiod,
                enrolmentperioddate,
                upperagelimit,
                dateofbirthrequired,
                enrolmentfee,
                reservefee,
                hidelostitems,
                overduenoticerequired,
                category_type,
                BlockExpiredPatronOpacActions,
                default_privacy
            )
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)" );
        $sth->execute(
            map { $input->param($_) } (
                'categorycode',    'description',
                'enrolmentperiod', 'enrolmentperioddate',
                'upperagelimit',   'dateofbirthrequired',
                'enrolmentfee',    'reservefee',
                'hidelostitems',   'overduenoticerequired',
                'category_type',   'block_expired',
                'default_privacy',
            )
        );
        $sth->finish;
    }

    if ( C4::Context->preference('EnhancedMessagingPreferences') ) {
        C4::Form::MessagingPreferences::handle_form_action( $input,
            { categorycode => $input->param('categorycode') }, $template );
    }

    print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=categorie.pl\"></html>";
    exit;

    # END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
    # called by default form, used to confirm deletion of data in DB
}
elsif ( $op eq 'delete_confirm' ) {
    my $schema = Koha::Database->new()->schema();
    $template->param( delete_confirm => 1 );

    my $count =
      $schema->resultset('Borrower')
      ->search( { categorycode => $categorycode } )->count();

    my $category = $schema->resultset('Category')->find($categorycode);

    $category->enrolmentperioddate(
        C4::Dates::format_date( $category->enrolmentperioddate() ) );

    $template->param( category => $category, patrons_in_category => $count );

    # END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
  # called by delete_confirm, used to effectively confirm deletion of data in DB
}
elsif ( $op eq 'delete_confirmed' ) {
    $template->param( delete_confirmed => 1 );
    my $dbh = C4::Context->dbh;

    my $categorycode = uc( $input->param('categorycode') );

    my $sth = $dbh->prepare("delete from categories where categorycode=?");

    $sth->execute($categorycode);
    $sth->finish;

    print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=categorie.pl\"></html>";
    exit;

    # END $OP eq DELETE_CONFIRMED
}
else {    # DEFAULT
    $template->param( else => 1 );
    my @loop;
    my ( $count, $results ) = StringSearch( $searchfield, 'web' );

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("
        SELECT b.branchcode, b.branchname 
        FROM categories_branches AS cb, branches AS b 
        WHERE cb.branchcode = b.branchcode AND cb.categorycode = ?
    ");

    for ( my $i = 0 ; $i < $count ; $i++ ) {
        $sth->execute( $results->[$i]{'categorycode'} );

        my @selected_branches;
        while ( my $branch = $sth->fetchrow_hashref ) {
            push @selected_branches, $branch;
        }

        my $enrolmentperioddate = $results->[$i]{'enrolmentperioddate'};
        if ( $enrolmentperioddate && $enrolmentperioddate eq '0000-00-00' ) {
            $enrolmentperioddate = undef;
        }

        $results->[$i]{'category_type'} //= '';

        my %row = (
            branches              => \@selected_branches,
            categorycode          => $results->[$i]{'categorycode'},
            description           => $results->[$i]{'description'},
            enrolmentperiod       => $results->[$i]{'enrolmentperiod'},
            enrolmentperioddate   => $enrolmentperioddate,
            upperagelimit         => $results->[$i]{'upperagelimit'},
            dateofbirthrequired   => $results->[$i]{'dateofbirthrequired'},
            overduenoticerequired => $results->[$i]{'overduenoticerequired'},
            issuelimit            => $results->[$i]{'issuelimit'},
            hidelostitems         => $results->[$i]{'hidelostitems'},
            category_type         => $results->[$i]{'category_type'},
            default_privacy       => $results->[$i]{'default_privacy'},
            reservefee => sprintf( "%.2f", $results->[$i]{'reservefee'} || 0 ),
            enrolmentfee =>
              sprintf( "%.2f", $results->[$i]{'enrolmentfee'} || 0 ),
            "type_" . $results->[$i]{'category_type'} => 1,
        );

        if ( C4::Context->preference('EnhancedMessagingPreferences') ) {
            my $brief_prefs =
              _get_brief_messaging_prefs( $results->[$i]{'categorycode'} );
            $row{messaging_prefs} = $brief_prefs if @$brief_prefs;
        }
        push @loop, \%row;
    }

    $template->param( loop => \@loop );

    # check that I (institution) and C (child) exists. otherwise => warning to the user
    $sth = $dbh->prepare("select category_type from categories where category_type='C'");
    $sth->execute;
    my ($categoryChild) = $sth->fetchrow;
    $template->param( categoryChild => $categoryChild );

    $sth = $dbh->prepare("select category_type from categories where category_type='I'");
    $sth->execute;
    my ($categoryInstitution) = $sth->fetchrow;
    $template->param( categoryInstitution => $categoryInstitution );
    $sth->finish;

}    #---- END $OP eq DEFAULT
output_html_with_http_headers $input, $cookie, $template->output;

exit 0;

sub _get_brief_messaging_prefs {
    my $categorycode      = shift;
    my $messaging_options = C4::Members::Messaging::GetMessagingOptions();
    my $results           = [];
    PREF: foreach my $option (@$messaging_options) {
        my $pref = C4::Members::Messaging::GetMessagingPreferences(
            {
                categorycode => $categorycode,
                message_name => $option->{'message_name'}
            }
        );
        next unless $pref->{'transports'};
        my $brief_pref = {
            message_attribute_id      => $option->{'message_attribute_id'},
            message_name              => $option->{'message_name'},
            $option->{'message_name'} => 1
        };
        foreach my $transport ( keys %{ $pref->{'transports'} } ) {
            push @{ $brief_pref->{'transports'} }, { transport => $transport };
        }
        push @$results, $brief_pref;
    }
    return $results;
}
