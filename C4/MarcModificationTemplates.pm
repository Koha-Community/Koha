package C4::MarcModificationTemplates;

# This file is part of Koha.
#
# Copyright 2010 Kyle M Hall <kyle.m.hall@gmail.com>
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

use DateTime;

use C4::Context;
use Koha::SimpleMARC;
use Koha::MoreUtils;

use vars qw(@ISA @EXPORT);

use constant DEBUG => 0;

BEGIN {
    @ISA = qw(Exporter);
    @EXPORT = qw(
        &GetModificationTemplates
        &AddModificationTemplate
        &DelModificationTemplate

        &GetModificationTemplateAction
        &GetModificationTemplateActions

        &AddModificationTemplateAction
        &ModModificationTemplateAction
        &DelModificationTemplateAction
        &MoveModificationTemplateAction

        &ModifyRecordsWithTemplate
        &ModifyRecordWithTemplate
    );
}


=head1 NAME

C4::MarcModificationTemplates - Module to manage MARC Modification Templates

=head1 DESCRIPTION

MARC Modification Templates are a tool for marc batch imports,
so that librarians can set up templates for various vendors'
files telling Koha what fields to insert data into.

=head1 FUNCTIONS

=cut

=head2 GetModificationTemplates

  my @templates = GetModificationTemplates( $template_id );

  Passing optional $template_id marks it as the selected template.

=cut

sub GetModificationTemplates {
  my ( $template_id ) = @_;
  warn("C4::MarcModificationTemplates::GetModificationTemplates( $template_id )") if DEBUG;

  my $dbh = C4::Context->dbh;
  my $sth = $dbh->prepare("SELECT * FROM marc_modification_templates ORDER BY name");
  $sth->execute();

  my @templates;
  while ( my $template = $sth->fetchrow_hashref() ) {
    $template->{'selected'} = 1
        if $template_id && $template->{'template_id'} eq $template_id;
    push( @templates, $template );
  }

  return @templates;
}

=head2
  AddModificationTemplate

  $template_id = AddModificationTemplate( $template_name[, $template_id ] );

  If $template_id is supplied, the actions from that template will be copied
  into the newly created template.
=cut

sub AddModificationTemplate {
  my ( $template_name, $template_id_copy ) = @_;

  my $dbh = C4::Context->dbh;
  my $sth = $dbh->prepare("INSERT INTO marc_modification_templates ( name ) VALUES ( ? )");
  $sth->execute( $template_name );

  $sth = $dbh->prepare("SELECT * FROM marc_modification_templates WHERE name = ?");
  $sth->execute( $template_name );
  my $row = $sth->fetchrow_hashref();
  my $template_id = $row->{'template_id'};

  if ( $template_id_copy ) {
    my @actions = GetModificationTemplateActions( $template_id_copy );
    foreach my $action ( @actions ) {
      AddModificationTemplateAction(
        $template_id,
        $action->{'action'},
        $action->{'field_number'},
        $action->{'from_field'},
        $action->{'from_subfield'},
        $action->{'field_value'},
        $action->{'to_field'},
        $action->{'to_subfield'},
        $action->{'to_regex_search'},
        $action->{'to_regex_replace'},
        $action->{'to_regex_modifiers'},
        $action->{'conditional'},
        $action->{'conditional_field'},
        $action->{'conditional_subfield'},
        $action->{'conditional_comparison'},
        $action->{'conditional_value'},
        $action->{'conditional_regex'},
        $action->{'description'},
      );

    }
  }

  return $template_id;
}

=head2
  DelModificationTemplate

  DelModificationTemplate( $template_id );
=cut

sub DelModificationTemplate {
  my ( $template_id ) = @_;

  my $dbh = C4::Context->dbh;
  my $sth = $dbh->prepare("DELETE FROM marc_modification_templates WHERE template_id = ?");
  $sth->execute( $template_id );
}

=head2
  GetModificationTemplateAction

  my $action = GetModificationTemplateAction( $mmta_id );
=cut

sub GetModificationTemplateAction {
  my ( $mmta_id ) = @_;

  my $dbh = C4::Context->dbh;
  my $sth = $dbh->prepare("SELECT * FROM marc_modification_template_actions WHERE mmta_id = ?");
  $sth->execute( $mmta_id );
  my $action = $sth->fetchrow_hashref();

  return $action;
}

=head2
  GetModificationTemplateActions

  my @actions = GetModificationTemplateActions( $template_id );
=cut

sub GetModificationTemplateActions {
  my ( $template_id ) = @_;

  warn( "C4::MarcModificationTemplates::GetModificationTemplateActions( $template_id )" ) if DEBUG;

  my $dbh = C4::Context->dbh;
  my $sth = $dbh->prepare("SELECT * FROM marc_modification_template_actions WHERE template_id = ? ORDER BY ordering");
  $sth->execute( $template_id );

  my @actions;
  while ( my $action = $sth->fetchrow_hashref() ) {
    push( @actions, $action );
  }

  warn( Data::Dumper::Dumper( @actions ) ) if DEBUG > 4;

  return @actions;
}

=head2
  AddModificationTemplateAction

  AddModificationTemplateAction(
    $template_id, $action, $field_number,
    $from_field, $from_subfield, $field_value,
    $to_field, $to_subfield, $to_regex_search, $to_regex_replace, $to_regex_modifiers
    $conditional, $conditional_field, $conditional_subfield,
    $conditional_comparison, $conditional_value,
    $conditional_regex, $description
  );

  Adds a new action to the given modification template.

=cut

sub AddModificationTemplateAction {
  my (
    $template_id,
    $action,
    $field_number,
    $from_field,
    $from_subfield,
    $field_value,
    $to_field,
    $to_subfield,
    $to_regex_search,
    $to_regex_replace,
    $to_regex_modifiers,
    $conditional,
    $conditional_field,
    $conditional_subfield,
    $conditional_comparison,
    $conditional_value,
    $conditional_regex,
    $description
  ) = @_;

  warn( "C4::MarcModificationTemplates::AddModificationTemplateAction( $template_id, $action,
                    $field_number, $from_field, $from_subfield, $field_value, $to_field, $to_subfield,
                    $to_regex_search, $to_regex_replace, $to_regex_modifiers, $conditional, $conditional_field, $conditional_subfield, $conditional_comparison,
                    $conditional_value, $conditional_regex, $description )" ) if DEBUG;

  $conditional ||= undef;
  $conditional_comparison ||= undef;
  $conditional_regex ||= '0';

  my $dbh = C4::Context->dbh;
  my $sth = $dbh->prepare( 'SELECT MAX(ordering) + 1 AS next_ordering FROM marc_modification_template_actions WHERE template_id = ?' );
  $sth->execute( $template_id );
  my $row = $sth->fetchrow_hashref;
  my $ordering = $row->{'next_ordering'} || 1;

  my $query = "
  INSERT INTO marc_modification_template_actions (
  mmta_id,
  template_id,
  ordering,
  action,
  field_number,
  from_field,
  from_subfield,
  field_value,
  to_field,
  to_subfield,
  to_regex_search,
  to_regex_replace,
  to_regex_modifiers,
  conditional,
  conditional_field,
  conditional_subfield,
  conditional_comparison,
  conditional_value,
  conditional_regex,
  description
  )
  VALUES ( NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )";

  $sth = $dbh->prepare( $query );

  $sth->execute(
    $template_id,
    $ordering,
    $action,
    $field_number,
    $from_field,
    $from_subfield,
    $field_value,
    $to_field,
    $to_subfield,
    $to_regex_search,
    $to_regex_replace,
    $to_regex_modifiers,
    $conditional,
    $conditional_field,
    $conditional_subfield,
    $conditional_comparison,
    $conditional_value,
    $conditional_regex,
    $description
  );
}

=head2
  ModModificationTemplateAction

  ModModificationTemplateAction(
    $mmta_id, $action, $field_number, $from_field,
    $from_subfield, $field_value, $to_field,
    $to_subfield, $to_regex_search, $to_regex_replace, $to_regex_modifiers, $conditional,
    $conditional_field, $conditional_subfield,
    $conditional_comparison, $conditional_value,
    $conditional_regex, $description
  );

  Modifies an existing action.

=cut

sub ModModificationTemplateAction {
  my (
    $mmta_id,
    $action,
    $field_number,
    $from_field,
    $from_subfield,
    $field_value,
    $to_field,
    $to_subfield,
    $to_regex_search,
    $to_regex_replace,
    $to_regex_modifiers,
    $conditional,
    $conditional_field,
    $conditional_subfield,
    $conditional_comparison,
    $conditional_value,
    $conditional_regex,
    $description
  ) = @_;

  my $dbh = C4::Context->dbh;
  $conditional ||= undef;
  $conditional_comparison ||= undef;
  $conditional_regex ||= '0';

  my $query = "
  UPDATE marc_modification_template_actions SET
  action = ?,
  field_number = ?,
  from_field = ?,
  from_subfield = ?,
  field_value = ?,
  to_field = ?,
  to_subfield = ?,
  to_regex_search = ?,
  to_regex_replace = ?,
  to_regex_modifiers = ?,
  conditional = ?,
  conditional_field = ?,
  conditional_subfield = ?,
  conditional_comparison = ?,
  conditional_value = ?,
  conditional_regex = ?,
  description = ?
  WHERE mmta_id = ?";

  my $sth = $dbh->prepare( $query );

  $sth->execute(
    $action,
    $field_number,
    $from_field,
    $from_subfield,
    $field_value,
    $to_field,
    $to_subfield,
    $to_regex_search,
    $to_regex_replace,
    $to_regex_modifiers,
    $conditional,
    $conditional_field,
    $conditional_subfield,
    $conditional_comparison,
    $conditional_value,
    $conditional_regex,
    $description,
    $mmta_id
  );
}


=head2
  DelModificationTemplateAction

  DelModificationTemplateAction( $mmta_id );

  Deletes the given template action.
=cut

sub DelModificationTemplateAction {
  my ( $mmta_id ) = @_;

  my $action = GetModificationTemplateAction( $mmta_id );

  my $dbh = C4::Context->dbh;
  my $sth = $dbh->prepare("DELETE FROM marc_modification_template_actions WHERE mmta_id = ?");
  $sth->execute( $mmta_id );

  $sth = $dbh->prepare("UPDATE marc_modification_template_actions SET ordering = ordering - 1 WHERE template_id = ? AND ordering > ?");
  $sth->execute( $action->{'template_id'}, $action->{'ordering'} );
}

=head2
  MoveModificationTemplateAction

  MoveModificationTemplateAction( $mmta_id, $where );

  Changes the order for the given action.
  Options for $where are 'up', 'down', 'top' and 'bottom'
=cut
sub MoveModificationTemplateAction {
  my ( $mmta_id, $where ) = @_;

  my $action = GetModificationTemplateAction( $mmta_id );

  return if ( $action->{'ordering'} eq '1' && ( $where eq 'up' || $where eq 'top' ) );
  return if ( $action->{'ordering'} eq GetModificationTemplateActions( $action->{'template_id'} ) && ( $where eq 'down' || $where eq 'bottom' ) );

  my $dbh = C4::Context->dbh;
  my ( $sth, $query );

  if ( $where eq 'up' || $where eq 'down' ) {

    ## For up and down, we just swap the ordering number with the one above or below it.

    ## Change the ordering for the other action
    $query = "UPDATE marc_modification_template_actions SET ordering = ? WHERE template_id = ? AND ordering = ?";

    my $ordering = $action->{'ordering'};
    $ordering-- if ( $where eq 'up' );
    $ordering++ if ( $where eq 'down' );

    $sth = $dbh->prepare( $query );
    $sth->execute( $action->{'ordering'}, $action->{'template_id'}, $ordering );

    ## Change the ordering for this action
    $query = "UPDATE marc_modification_template_actions SET ordering = ? WHERE mmta_id = ?";
    $sth = $dbh->prepare( $query );
    $sth->execute( $ordering, $action->{'mmta_id'} );

  } elsif ( $where eq 'top' ) {

    $sth = $dbh->prepare('UPDATE marc_modification_template_actions SET ordering = ordering + 1 WHERE template_id = ? AND ordering < ?');
    $sth->execute( $action->{'template_id'}, $action->{'ordering'} );

    $sth = $dbh->prepare('UPDATE marc_modification_template_actions SET ordering = 1 WHERE mmta_id = ?');
    $sth->execute( $mmta_id );

  } elsif ( $where eq 'bottom' ) {

    my $ordering = GetModificationTemplateActions( $action->{'template_id'} );

    $sth = $dbh->prepare('UPDATE marc_modification_template_actions SET ordering = ordering - 1 WHERE template_id = ? AND ordering > ?');
    $sth->execute( $action->{'template_id'}, $action->{'ordering'} );

    $sth = $dbh->prepare('UPDATE marc_modification_template_actions SET ordering = ? WHERE mmta_id = ?');
    $sth->execute( $ordering, $mmta_id );

  }

}

=head2
  ModifyRecordsWithTemplate

  ModifyRecordsWithTemplate( $template_id, $batch );

  Accepts a template id and a MARC::Batch object.
=cut

sub ModifyRecordsWithTemplate {
  my ( $template_id, $batch ) = @_;
  warn( "C4::MarcModificationTemplates::ModifyRecordsWithTemplate( $template_id, $batch )" ) if DEBUG;

  while ( my $record = $batch->next() ) {
    ModifyRecordWithTemplate( $template_id, $record );
  }
}

=head2
  ModifyRecordWithTemplate

  ModifyRecordWithTemplate( $template_id, $record )

  Accepts a MARC::Record object ( $record ) and modifies
  it based on the actions for the given $template_id
=cut

sub ModifyRecordWithTemplate {
    my ( $template_id, $record ) = @_;
    warn( "C4::MarcModificationTemplates::ModifyRecordWithTemplate( $template_id, $record )" ) if DEBUG;
    warn( "Unmodified Record:\n" . $record->as_formatted() ) if DEBUG >= 10;

    my $current_date = DateTime->now()->ymd();
    my $branchcode = '';
    $branchcode = C4::Context->userenv->{branch} if C4::Context->userenv;

    my @actions = GetModificationTemplateActions( $template_id );

    foreach my $a ( @actions ) {
        my $action = $a->{'action'};
        my $field_number = $a->{'field_number'} // 1;
        my $from_field = $a->{'from_field'};
        my $from_subfield = $a->{'from_subfield'};
        my $field_value = $a->{'field_value'};
        my $to_field = $a->{'to_field'};
        my $to_subfield = $a->{'to_subfield'};
        my $to_regex_search = $a->{'to_regex_search'};
        my $to_regex_replace = $a->{'to_regex_replace'};
        my $to_regex_modifiers = $a->{'to_regex_modifiers'};
        my $conditional = $a->{'conditional'};
        my $conditional_field = $a->{'conditional_field'};
        my $conditional_subfield = $a->{'conditional_subfield'};
        my $conditional_comparison = $a->{'conditional_comparison'};
        my $conditional_value = $a->{'conditional_value'};
        my $conditional_regex = $a->{'conditional_regex'};

        if ( $field_value ) {
            $field_value =~ s/__CURRENTDATE__/$current_date/g;
            $field_value =~ s/__BRANCHCODE__/$branchcode/g;
        }

        my $do = 1;
        my $field_numbers = [];
        if ( $conditional ) {
            if ( $conditional_comparison eq 'exists' ) {
                $field_numbers = field_exists({
                        record => $record,
                        field => $conditional_field,
                        subfield => $conditional_subfield,
                    });
                $do = $conditional eq 'if'
                    ? @$field_numbers
                    : not @$field_numbers;
            }
            elsif ( $conditional_comparison eq 'not_exists' ) {
                $field_numbers = field_exists({
                        record => $record,
                        field => $conditional_field,
                        subfield => $conditional_subfield
                    });
                $do = $conditional eq 'if'
                    ? not @$field_numbers
                    : @$field_numbers;
            }
            elsif ( $conditional_comparison eq 'equals' ) {
                $field_numbers = field_equals({
                    record => $record,
                    value => $conditional_value,
                    field => $conditional_field,
                    subfield => $conditional_subfield,
                    is_regex => $conditional_regex,
                });
                $do = $conditional eq 'if'
                    ? @$field_numbers
                    : not @$field_numbers;
            }
            elsif ( $conditional_comparison eq 'not_equals' ) {
                $field_numbers = field_equals({
                    record => $record,
                    value => $conditional_value,
                    field => $conditional_field,
                    subfield => $conditional_subfield,
                    is_regex => $conditional_regex,
                });
                my $all_fields = [
                    1 .. scalar @{
                        field_exists(
                            {
                                record   => $record,
                                field    => $conditional_field,
                                subfield => $conditional_subfield
                            }
                        )
                    }
                ];
                $field_numbers = [Koha::MoreUtils::singleton ( @$field_numbers, @$all_fields ) ];
                $do = $conditional eq 'if'
                    ? @$field_numbers
                    : not @$field_numbers;
            }
        }

        if ( $do ) {

            # field_number == 0 if all field need to be updated
            # or 1 if only the first field need to be updated

            # A condition has been given
            if ( @$field_numbers > 0 ) {
                if ( $field_number == 1 ) {
                    # We want only the first matching
                    $field_numbers = [ $field_numbers->[0] ];
                }
            }
            # There was no condition
            else {
                if ( $field_number == 1 ) {
                    # We want to process the first field
                    $field_numbers = [ 1 ];
                } elsif ( $to_field and $from_field ne $to_field ) {
                    # If the from and to fields are not the same, we only process the first field.
                    $field_numbers = [ 1 ];
                }
            }

            if ( $action eq 'copy_field' ) {
                copy_field({
                    record => $record,
                    from_field => $from_field,
                    from_subfield => $from_subfield,
                    to_field => $to_field,
                    to_subfield => $to_subfield,
                    regex => {
                        search => $to_regex_search,
                        replace => $to_regex_replace,
                        modifiers => $to_regex_modifiers
                    },
                    field_numbers => $field_numbers,
                });
            }
            elsif ( $action eq 'copy_and_replace_field' ) {
                copy_and_replace_field({
                    record => $record,
                    from_field => $from_field,
                    from_subfield => $from_subfield,
                    to_field => $to_field,
                    to_subfield => $to_subfield,
                    regex => {
                        search => $to_regex_search,
                        replace => $to_regex_replace,
                        modifiers => $to_regex_modifiers
                    },
                    field_numbers => $field_numbers,
                });
            }
            elsif ( $action eq 'add_field' ) {
                add_field({
                    record => $record,
                    field => $from_field,
                    subfield => $from_subfield,
                    values => [ $field_value ],
                    field_numbers => $field_numbers,
                });
            }
            elsif ( $action eq 'update_field' ) {
                update_field({
                    record => $record,
                    field => $from_field,
                    subfield => $from_subfield,
                    values => [ $field_value ],
                    field_numbers => $field_numbers,
                });
            }
            elsif ( $action eq 'move_field' ) {
                move_field({
                    record => $record,
                    from_field => $from_field,
                    from_subfield => $from_subfield,
                    to_field => $to_field,
                    to_subfield => $to_subfield,
                    regex => {
                        search => $to_regex_search,
                        replace => $to_regex_replace,
                        modifiers => $to_regex_modifiers
                    },
                    field_numbers => $field_numbers,
                });
            }
            elsif ( $action eq 'delete_field' ) {
                delete_field({
                    record => $record,
                    field => $from_field,
                    subfield => $from_subfield,
                    field_numbers => $field_numbers,
                });
            }
        }

        warn( $record->as_formatted() ) if DEBUG >= 10;
    }

    return;
}
1;
__END__

=head1 AUTHOR

Kyle M Hall

=cut
