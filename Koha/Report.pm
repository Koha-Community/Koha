package Koha::Report;

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

use Koha::Database;
use Koha::Reports;

#use Koha::DateUtils qw( dt_from_string output_pref );

use base qw(Koha::Object);
#
# FIXME We could only return an error code instead of the arrayref
# Only 1 error is returned
# TODO Koha::Report->store should check this before saving

use constant FORBIDDEN_COLUMN_MATCHES => qw(password token uuid secret);
use constant ALLOWLISTED_COLUMN_NAMES =>
    qw(password_expiration_date password_expiry_days reset_password change_password min_password_length require_strong_password password_expiration_date force_password_reset_when_set_by_staff);

=head1 NAME

Koha::Report - Koha Report Object class

=head1 API

=head2 Class Methods

=head3 is_sql_valid

my ( $is_sql_valid, $errors ) = $report->is_sql_valid;

$errors is a arrayref of hashrefs, keys can be sqlerr or queryerr.

Validate SQL query string so it only contains a select,
not any of the harmful queries.

=cut

sub is_sql_valid {
    my ($self) = @_;

    my $sql = $self->savedsql;
    $sql //= '';
    my @errors = ();

    if ( $sql =~ /;?\W?(UPDATE|DELETE|DROP|INSERT|SHOW|CREATE)\W/i ) {
        push @errors, { sqlerr => $1 };
    } elsif ( $sql !~ /^\s*SELECT\b\s*/i ) {
        push @errors, { queryerr => 'Missing SELECT' };
    } else {
        push @errors, { passworderr => "Illegal column in results" }
            if $self->check_columns($sql);
    }

    return ( @errors ? 0 : 1, \@errors );
}

=head3 check_columns

    $self->check_columns('SELECT password from borrowers');
    $self->check_columns( undef, [qw(password token)] );

    Check if passed sql statement or column_names arrayref contains
    forbidden column names (credentials etc.).
    Returns all bad column names or empty list.

=cut

sub check_columns {
    my ( $self, $sql, $column_names ) = @_;

    # TODO When passing sql, we actually go thru the whole statement, not just columns

    my $regex;
    push my @columns, @{ $column_names // [] };
    if ($sql) {

        # Now find all matches for e.g. password but also modulepassword or password_hash
        # Note that \w includes underscore, not hyphen
        $regex   = '(\w*(?:' . ( join '|', FORBIDDEN_COLUMN_MATCHES ) . ')\w*)';
        @columns = ( $sql =~ /$regex/ig );
    } else {
        $regex   = '(' . ( join '|', FORBIDDEN_COLUMN_MATCHES ) . ')';
        @columns = grep { /$regex/i } @columns;
    }

    # Check for allowlisted variants
    $regex   = '(^' . ( join '|', ALLOWLISTED_COLUMN_NAMES ) . ')$';    # should be full match
    @columns = grep { !/$regex/i } @columns;
    return @columns;
}

=head3 get_search_info

Return search info

=cut

sub get_search_info {
    my $self          = shift;
    my $sub_mana_info = { 'query' => shift };
    return $sub_mana_info;
}

=head3 get_sharable_info

Return properties that can be shared.

=cut

sub get_sharable_info {
    my $self             = shift;
    my $shared_report_id = shift;
    my $report           = Koha::Reports->find($shared_report_id);
    my $sub_mana_info    = {
        'savedsql'     => $report->savedsql,
        'report_name'  => $report->report_name,
        'notes'        => $report->notes,
        'report_group' => $report->report_group,
        'type'         => $report->type,
    };
    return $sub_mana_info;
}

=head3 new_from_mana

Clear a Mana report to be imported in Koha?

=cut

sub new_from_mana {
    my $self = shift;
    my $data = shift;

    $data->{mana_id} = $data->{id};

    delete $data->{exportemail};
    delete $data->{kohaversion};
    delete $data->{creationdate};
    delete $data->{lastimport};
    delete $data->{id};
    delete $data->{nbofusers};
    delete $data->{language};

    Koha::Report->new($data)->store;
}

=head3 prep_report

Prep the report and return executable sql with parameters embedded and a list of header types
for building batch action links in the template

=cut

sub prep_report {
    my ( $self, $param_names, $sql_params, $params ) = @_;    # params keys: export
    my $sql = $self->savedsql;

    # First we split out the placeholders
    # This part of the code supports using [[ table.field | alias ]] in the
    # query and replaces it by table.field AS alias. This is used to build
    # the batch action links foir cardnumbers, itemnumbers, and biblionumbers in the template
    # while allowing the library to alter the column names
    my @split = split /\[\[|\]\]/, $sql;
    my $headers;
    for ( my $i = 0 ; $i < $#split / 2 ; $i++ ) {    #The placeholders are always the odd elements of the array
        my ( $type, $name ) = split /\|/,
            $split[ $i * 2 + 1 ];                    # We split them on '|'
        $name =~ s/^\s+|\s+$//;                      # Trim
        $headers->{$name} = $type;                   # Store as a lookup for the template
        $headers->{$name} =~ s/^\w*\.//;             # strip the table name just as in $sth->{NAME} array
        $split[ $i * 2 + 1 ] =~
            s/(\||\?|\.|\*|\(|\)|\%)/\\$1/g;         #Quote any special characters so we can replace the placeholders
        $name = C4::Context->dbh->quote($name);
        $sql =~ s/\[\[$split[$i*2+1]\]\]/$type AS $name/;    # Remove placeholders from SQL
    }

    my %lookup;
    unless ( scalar @$param_names ) {
        my @placeholders = $sql =~ /<<([^<>]+)>>/g;
        foreach my $placeholder (@placeholders) {
            push @$param_names, $placeholder unless grep { $_ eq $placeholder } @$param_names;
        }
    }
    @lookup{@$param_names} = @$sql_params;
    @split = split /<<|>>/, $sql;
    for ( my $i = 0 ; $i < $#split / 2 ; $i++ ) {
        my $quoted =
            @$param_names ? $lookup{ $split[ $i * 2 + 1 ] } : @$sql_params[$i];

        # if there are special regexp chars, we must \ them
        $split[ $i * 2 + 1 ] =~ s/(\||\?|\.|\*|\(|\)|\%)/\\$1/g;

        #if ( $split[ $i * 2 + 1 ] =~ /\|\s*date\s*$/ ) {
        #    $quoted = output_pref(
        #        {
        #            dt         => dt_from_string($quoted),
        #            dateformat => 'iso',
        #            dateonly   => 1
        #        }
        #    ) if $quoted;
        #}
        unless ( $split[ $i * 2 + 1 ] =~ /\|\s*list\s*$|\s*\:in\s*$/ && $quoted ) {
            $quoted = C4::Context->dbh->quote($quoted);
        } else {
            my @list = split /\n/, $quoted;
            my @quoted_list;
            foreach my $item (@list) {
                $item =~ s/\r//;
                push @quoted_list, C4::Context->dbh->quote($item);
            }
            $quoted = "(" . join( ",", @quoted_list ) . ")";
        }
        $sql =~ s/<<$split[$i*2+1]>>/$quoted/;
    }

    $sql = $self->_might_add_limit($sql) if $params->{export};

    $sql = "$sql /* saved_sql.id: ${\( $self->id )} */";
    return $sql, $headers;
}

=head3 _might_add_limit

    $sql = $self->_might_add_limit($sql);

Depending on pref ReportsExportLimit. If there is a limit defined
and the report does not contain a limit already, this routine adds
a LIMIT to $sql.

=cut

sub _might_add_limit {
    my ( $self, $sql ) = @_;
    if ( C4::Context->preference('ReportsExportLimit')
        && $sql !~ /\sLIMIT\s\d+(?![^\(]*\))/i )
    {
        # Note: regex tries to account for allowed limits in subqueries.
        # This assumes that we dont have an INTO option at the end (which does
        # not work in current Koha reporting)
        $sql .= " LIMIT " . C4::Context->preference('ReportsExportLimit');
    }
    return $sql;
}

=head3 _type

Returns name of corresponding DBIC resultset

=cut

sub _type {
    return 'SavedSql';
}

1;
