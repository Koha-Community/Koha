package C4::CourseReserves;

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

use C4::Context;
use C4::Items qw(GetItem ModItem);
use C4::Biblio qw(GetBiblioFromItemNumber);
use C4::Circulation qw(GetOpenIssue);

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $DEBUG @FIELDS);

BEGIN {
    require Exporter;
    @ISA       = qw(Exporter);
    @EXPORT_OK = qw(
      &GetCourse
      &ModCourse
      &GetCourses
      &DelCourse

      &GetCourseInstructors
      &ModCourseInstructors

      &GetCourseItem
      &ModCourseItem

      &GetCourseReserve
      &ModCourseReserve
      &GetCourseReserves
      &DelCourseReserve

      &SearchCourses

      &GetItemCourseReservesInfo
    );
    %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );

    $DEBUG = 0;
    @FIELDS = ( 'itype', 'ccode', 'holdingbranch', 'location' );
}

=head1 NAME

C4::CourseReserves - Koha course reserves module

=head1 SYNOPSIS

use C4::CourseReserves;

=head1 DESCRIPTION

This module deals with course reserves.

=head1 FUNCTIONS

=head2 GetCourse

    $course = GetCourse( $course_id );

=cut

sub GetCourse {
    my ($course_id) = @_;
    warn whoami() . "( $course_id )" if $DEBUG;

    my $query = "SELECT * FROM courses WHERE course_id = ?";
    my $dbh   = C4::Context->dbh;
    my $sth   = $dbh->prepare($query);
    $sth->execute($course_id);

    my $course = $sth->fetchrow_hashref();

    $query = "
        SELECT b.* FROM course_instructors ci
        LEFT JOIN borrowers b ON ( ci.borrowernumber = b.borrowernumber )
        WHERE course_id =  ?
    ";
    $sth = $dbh->prepare($query);
    $sth->execute($course_id);
    $course->{'instructors'} = $sth->fetchall_arrayref( {} );

    return $course;
}

=head2 ModCourse

    ModCourse( [ course_id => $id ] [, course_name => $course_name ] [etc...] );

=cut

sub ModCourse {
    my (%params) = @_;
    warn identify_myself(%params) if $DEBUG;

    my $dbh = C4::Context->dbh;

    my $course_id;
    if ( defined $params{'course_id'} ) {
        $course_id = $params{'course_id'};
        delete $params{'course_id'};
    }

    my @query_keys;
    my @query_values;

    my $query;

    $query .= ($course_id) ? ' UPDATE ' : ' INSERT ';
    $query .= ' courses SET ';

    foreach my $key ( keys %params ) {
        push( @query_keys,   "$key=?" );
        push( @query_values, $params{$key} );
    }
    $query .= join( ',', @query_keys );

    if ($course_id) {
        $query .= " WHERE course_id = ?";
        push( @query_values, $course_id );
    }

    $dbh->do( $query, undef, @query_values );

    $course_id = $course_id
      || $dbh->last_insert_id( undef, undef, 'courses', 'course_id' );

    EnableOrDisableCourseItems(
        course_id => $course_id,
        enabled   => $params{'enabled'}
    );

    return $course_id;
}

=head2 GetCourses

  @courses = GetCourses( [ fieldname => $value ] [, fieldname2 => $value2 ] [etc...] );

=cut

sub GetCourses {
    my (%params) = @_;
    warn identify_myself(%params) if $DEBUG;

    my @query_keys;
    my @query_values;

    my $query = "
        SELECT courses.*
        FROM courses
        LEFT JOIN course_reserves ON course_reserves.course_id = courses.course_id
        LEFT JOIN course_items ON course_items.ci_id = course_reserves.ci_id
    ";

    if ( keys %params ) {

        $query .= " WHERE ";

        foreach my $key ( keys %params ) {
            push( @query_keys,   " $key LIKE ? " );
            push( @query_values, $params{$key} );
        }

        $query .= join( ' AND ', @query_keys );
    }

    $query .= " GROUP BY courses.course_id ";

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute(@query_values);

    my $courses = $sth->fetchall_arrayref( {} );

    foreach my $c (@$courses) {
        $c->{'instructors'} = GetCourseInstructors( $c->{'course_id'} );
    }

    return $courses;
}

=head2 DelCourse

  DelCourse( $course_id );

=cut

sub DelCourse {
    my ($course_id) = @_;

    my $course_reserves = GetCourseReserves( course_id => $course_id );

    foreach my $res (@$course_reserves) {
        DelCourseReserve( cr_id => $res->{'cr_id'} );
    }

    my $query = "
        DELETE FROM course_instructors
        WHERE course_id = ?
    ";
    C4::Context->dbh->do( $query, undef, $course_id );

    $query = "
        DELETE FROM courses
        WHERE course_id = ?
    ";
    C4::Context->dbh->do( $query, undef, $course_id );
}

=head2 EnableOrDisableCourseItems

  EnableOrDisableCourseItems( course_id => $course_id, enabled => $enabled );

  For each item on reserve for this course,
  if the course item has no active course reserves,
  swap the fields for the item to make it 'normal'
  again.

  enabled => 'yes' to enable course items
  enabled => 'no' to disable course items

=cut

sub EnableOrDisableCourseItems {
    my (%params) = @_;
    warn identify_myself(%params) if $DEBUG;

    my $course_id = $params{'course_id'};
    my $enabled = $params{'enabled'} || 0;

    my $lookfor = ( $enabled eq 'yes' ) ? 'no' : 'yes';

    return unless ( $course_id && $enabled );
    return unless ( $enabled eq 'yes' || $enabled eq 'no' );

    my $course_reserves = GetCourseReserves( course_id => $course_id );

    if ( $enabled eq 'yes' ) {
        foreach my $course_reserve (@$course_reserves) {
            if (CountCourseReservesForItem(
                    ci_id   => $course_reserve->{'ci_id'},
                    enabled => 'yes'
                )
              ) {
                EnableOrDisableCourseItem(
                    ci_id   => $course_reserve->{'ci_id'},
                    enabled => 'yes',
                );
            }
        }
    }
    if ( $enabled eq 'no' ) {
        foreach my $course_reserve (@$course_reserves) {
            unless (
                CountCourseReservesForItem(
                    ci_id   => $course_reserve->{'ci_id'},
                    enabled => 'yes'
                )
              ) {
                EnableOrDisableCourseItem(
                    ci_id   => $course_reserve->{'ci_id'},
                    enabled => 'no',
                );
            }
        }
    }
}

=head2 EnableOrDisableCourseItem

    EnableOrDisableCourseItem( ci_id => $ci_id, enabled => $enabled );

    enabled => 'yes' to enable course items
    enabled => 'no' to disable course items

=cut

sub EnableOrDisableCourseItem {
    my (%params) = @_;
    warn identify_myself(%params) if $DEBUG;

    my $ci_id   = $params{'ci_id'};
    my $enabled = $params{'enabled'};

    return unless ( $ci_id && $enabled );
    return unless ( $enabled eq 'yes' || $enabled eq 'no' );

    my $course_item = GetCourseItem( ci_id => $ci_id );

    ## We don't want to 'enable' an already enabled item,
    ## or disable and already disabled item,
    ## as that would cause the fields to swap
    if ( $course_item->{'enabled'} ne $enabled ) {
        _SwapAllFields($ci_id);

        my $query = "
            UPDATE course_items
            SET enabled = ?
            WHERE ci_id = ?
        ";

        C4::Context->dbh->do( $query, undef, $enabled, $ci_id );

    }

}

=head2 GetCourseInstructors

    @$borrowers = GetCourseInstructors( $course_id );

=cut

sub GetCourseInstructors {
    my ($course_id) = @_;
    warn "C4::CourseReserves::GetCourseInstructors( $course_id )"
      if $DEBUG;

    my $query = "
        SELECT * FROM borrowers
        RIGHT JOIN course_instructors ON ( course_instructors.borrowernumber = borrowers.borrowernumber )
        WHERE course_instructors.course_id = ?
    ";

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute($course_id);

    return $sth->fetchall_arrayref( {} );
}

=head2 ModCourseInstructors

    ModCourseInstructors( mode => $mode, course_id => $course_id, [ cardnumbers => $cardnumbers ] OR [ borrowernumbers => $borrowernumbers  );

    $mode can be 'replace', 'add', or 'delete'

    $cardnumbers and $borrowernumbers are both references to arrays

    Use either cardnumbers or borrowernumber, but not both.

=cut

sub ModCourseInstructors {
    my (%params) = @_;
    warn identify_myself(%params) if $DEBUG;

    my $course_id       = $params{'course_id'};
    my $mode            = $params{'mode'};
    my $cardnumbers     = $params{'cardnumbers'};
    my $borrowernumbers = $params{'borrowernumbers'};

    return unless ($course_id);
    return
      unless ( $mode eq 'replace'
        || $mode eq 'add'
        || $mode eq 'delete' );
    return unless ( $cardnumbers || $borrowernumbers );
    return if ( $cardnumbers && $borrowernumbers );

    my ( @cardnumbers, @borrowernumbers );
    @cardnumbers = @$cardnumbers if ( ref($cardnumbers) eq 'ARRAY' );
    @borrowernumbers = @$borrowernumbers
      if ( ref($borrowernumbers) eq 'ARRAY' );

    my $field  = (@cardnumbers) ? 'cardnumber' : 'borrowernumber';
    my @fields = (@cardnumbers) ? @cardnumbers : @borrowernumbers;
    my $placeholders = join( ',', ('?') x scalar @fields );

    my $dbh = C4::Context->dbh;

    $dbh->do( "DELETE FROM course_instructors WHERE course_id = ?", undef, $course_id )
      if ( $mode eq 'replace' );

    my $query;

    if ( $mode eq 'add' || $mode eq 'replace' ) {
        $query = "
            INSERT INTO course_instructors ( course_id, borrowernumber )
            SELECT ?, borrowernumber
            FROM borrowers
            WHERE $field IN ( $placeholders )
        ";
    } else {
        $query = "
            DELETE FROM course_instructors
            WHERE course_id = ?
            AND borrowernumber IN (
                SELECT borrowernumber FROM borrowers WHERE $field IN ( $placeholders )
            )
        ";
    }

    my $sth = $dbh->prepare($query);

    $sth->execute( $course_id, @fields ) if (@fields);
}

=head2 GetCourseItem {

  $course_item = GetCourseItem( itemnumber => $itemnumber [, ci_id => $ci_id );

=cut

sub GetCourseItem {
    my (%params) = @_;
    warn identify_myself(%params) if $DEBUG;

    my $ci_id      = $params{'ci_id'};
    my $itemnumber = $params{'itemnumber'};

    return unless ( $itemnumber || $ci_id );

    my $field = ($itemnumber) ? 'itemnumber' : 'ci_id';
    my $value = ($itemnumber) ? $itemnumber  : $ci_id;

    my $query = "SELECT * FROM course_items WHERE $field = ?";
    my $dbh   = C4::Context->dbh;
    my $sth   = $dbh->prepare($query);
    $sth->execute($value);

    my $course_item = $sth->fetchrow_hashref();

    if ($course_item) {
        $query = "SELECT * FROM course_reserves WHERE ci_id = ?";
        $sth   = $dbh->prepare($query);
        $sth->execute( $course_item->{'ci_id'} );
        my $course_reserves = $sth->fetchall_arrayref( {} );

        $course_item->{'course_reserves'} = $course_reserves
          if ($course_reserves);
    }
    return $course_item;
}

=head2 ModCourseItem {

  ModCourseItem( %params );

  Creates or modifies an existing course item.

=cut

sub ModCourseItem {
    my (%params) = @_;
    warn identify_myself(%params) if $DEBUG;

    my $itemnumber    = $params{'itemnumber'};
    my $itype         = $params{'itype'};
    my $ccode         = $params{'ccode'};
    my $holdingbranch = $params{'holdingbranch'};
    my $location      = $params{'location'};

    return unless ($itemnumber);

    my $course_item = GetCourseItem( itemnumber => $itemnumber );

    my $ci_id;

    if ($course_item) {
        $ci_id = $course_item->{'ci_id'};

        _UpdateCourseItem(
            ci_id       => $ci_id,
            course_item => $course_item,
            %params
        );
    } else {
        $ci_id = _AddCourseItem(%params);
    }

    return $ci_id;

}

=head2 _AddCourseItem

    my $ci_id = _AddCourseItem( %params );

=cut

sub _AddCourseItem {
    my (%params) = @_;
    warn identify_myself(%params) if $DEBUG;

    my ( @fields, @values );

    push( @fields, 'itemnumber = ?' );
    push( @values, $params{'itemnumber'} );

    foreach (@FIELDS) {
        if ( $params{$_} ) {
            push( @fields, "$_ = ?" );
            push( @values, $params{$_} );
        }
    }

    my $query = "INSERT INTO course_items SET " . join( ',', @fields );
    my $dbh = C4::Context->dbh;
    $dbh->do( $query, undef, @values );

    my $ci_id = $dbh->last_insert_id( undef, undef, 'course_items', 'ci_id' );

    return $ci_id;
}

=head2 _UpdateCourseItem

  _UpdateCourseItem( %params );

=cut

sub _UpdateCourseItem {
    my (%params) = @_;
    warn identify_myself(%params) if $DEBUG;

    my $ci_id         = $params{'ci_id'};
    my $course_item   = $params{'course_item'};
    my $itype         = $params{'itype'};
    my $ccode         = $params{'ccode'};
    my $holdingbranch = $params{'holdingbranch'};
    my $location      = $params{'location'};

    return unless ( $ci_id || $course_item );

    $course_item = GetCourseItem( ci_id => $ci_id )
      unless ($course_item);
    $ci_id = $course_item->{'ci_id'} unless ($ci_id);

    ## Revert fields that had an 'original' value, but now don't
    ## Update the item fields to the stored values from course_items
    ## and then set those fields in course_items to NULL
    my @fields_to_revert;
    foreach (@FIELDS) {
        if ( !$params{$_} && $course_item->{$_} ) {
            push( @fields_to_revert, $_ );
        }
    }
    _RevertFields(
        ci_id       => $ci_id,
        fields      => \@fields_to_revert,
        course_item => $course_item
    ) if (@fields_to_revert);

    ## Update fields that still have an original value, but it has changed
    ## This necessitates only changing the current item values, as we still
    ## have the original values stored in course_items
    my %mod_params;
    foreach (@FIELDS) {
        if (   $params{$_}
            && $course_item->{$_}
            && $params{$_} ne $course_item->{$_} ) {
            $mod_params{$_} = $params{$_};
        }
    }
    ModItem( \%mod_params, undef, $course_item->{'itemnumber'} ) if %mod_params;

    ## Update fields that didn't have an original value, but now do
    ## We must save the original value in course_items, and also
    ## update the item fields to the new value
    my $item = GetItem( $course_item->{'itemnumber'} );
    my %mod_params_new;
    my %mod_params_old;
    foreach (@FIELDS) {
        if ( $params{$_} && !$course_item->{$_} ) {
            $mod_params_new{$_} = $params{$_};
            $mod_params_old{$_} = $item->{$_};
        }
    }
    _ModStoredFields( 'ci_id' => $params{'ci_id'}, %mod_params_old );
    ModItem( \%mod_params_new, undef, $course_item->{'itemnumber'} ) if %mod_params_new;

}

=head2 _ModStoredFields

    _ModStoredFields( %params );

    Updates the values for the 'original' fields in course_items
    for a given ci_id

=cut

sub _ModStoredFields {
    my (%params) = @_;
    warn identify_myself(%params) if $DEBUG;

    return unless ( $params{'ci_id'} );

    my ( @fields_to_update, @values_to_update );

    foreach (@FIELDS) {
        if ( $params{$_} ) {
            push( @fields_to_update, $_ );
            push( @values_to_update, $params{$_} );
        }
    }

    my $query = "UPDATE course_items SET " . join( ',', map { "$_=?" } @fields_to_update ) . " WHERE ci_id = ?";

    C4::Context->dbh->do( $query, undef, @values_to_update, $params{'ci_id'} )
      if (@values_to_update);

}

=head2 _RevertFields

    _RevertFields( ci_id => $ci_id, fields => \@fields_to_revert );

=cut

sub _RevertFields {
    my (%params) = @_;
    warn identify_myself(%params) if $DEBUG;

    my $ci_id       = $params{'ci_id'};
    my $course_item = $params{'course_item'};
    my $fields      = $params{'fields'};
    my @fields      = @$fields;

    return unless ($ci_id);

    $course_item = GetCourseItem( ci_id => $params{'ci_id'} )
      unless ($course_item);

    my $mod_item_params;
    my @fields_to_null;
    foreach my $field (@fields) {
        foreach (@FIELDS) {
            if ( $field eq $_ && $course_item->{$_} ) {
                $mod_item_params->{$_} = $course_item->{$_};
                push( @fields_to_null, $_ );
            }
        }
    }
    ModItem( $mod_item_params, undef, $course_item->{'itemnumber'} ) if $mod_item_params && %$mod_item_params;

    my $query = "UPDATE course_items SET " . join( ',', map { "$_=NULL" } @fields_to_null ) . " WHERE ci_id = ?";

    C4::Context->dbh->do( $query, undef, $ci_id ) if (@fields_to_null);
}

=head2 _SwapAllFields

    _SwapAllFields( $ci_id );

=cut

sub _SwapAllFields {
    my ($ci_id) = @_;
    warn "C4::CourseReserves::_SwapFields( $ci_id )" if $DEBUG;

    my $course_item = GetCourseItem( ci_id => $ci_id );
    my $item = GetItem( $course_item->{'itemnumber'} );

    my %course_item_fields;
    my %item_fields;
    foreach (@FIELDS) {
        if ( $course_item->{$_} ) {
            $course_item_fields{$_} = $course_item->{$_};
            $item_fields{$_}        = $item->{$_};
        }
    }

    ModItem( \%course_item_fields, undef, $course_item->{'itemnumber'} ) if %course_item_fields;
    _ModStoredFields( %item_fields, ci_id => $ci_id );
}

=head2 GetCourseItems {

  $course_items = GetCourseItems(
      [course_id => $course_id]
      [, itemnumber => $itemnumber ]
  );

=cut

sub GetCourseItems {
    my (%params) = @_;
    warn identify_myself(%params) if $DEBUG;

    my $course_id  = $params{'course_id'};
    my $itemnumber = $params{'itemnumber'};

    return unless ($course_id);

    my @query_keys;
    my @query_values;

    my $query = "SELECT * FROM course_items";

    if ( keys %params ) {

        $query .= " WHERE ";

        foreach my $key ( keys %params ) {
            push( @query_keys,   " $key LIKE ? " );
            push( @query_values, $params{$key} );
        }

        $query .= join( ' AND ', @query_keys );
    }

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute(@query_values);

    return $sth->fetchall_arrayref( {} );
}

=head2 DelCourseItem {

  DelCourseItem( ci_id => $cr_id );

=cut

sub DelCourseItem {
    my (%params) = @_;
    warn identify_myself(%params) if $DEBUG;

    my $ci_id = $params{'ci_id'};

    return unless ($ci_id);

    _RevertFields( ci_id => $ci_id, fields => \@FIELDS );

    my $query = "
        DELETE FROM course_items
        WHERE ci_id = ?
    ";
    C4::Context->dbh->do( $query, undef, $ci_id );
}

=head2 GetCourseReserve {

  $course_item = GetCourseReserve( %params );

=cut

sub GetCourseReserve {
    my (%params) = @_;
    warn identify_myself(%params) if $DEBUG;

    my $cr_id     = $params{'cr_id'};
    my $course_id = $params{'course_id'};
    my $ci_id     = $params{'ci_id'};

    return unless ( $cr_id || ( $course_id && $ci_id ) );

    my $dbh = C4::Context->dbh;
    my $sth;

    if ($cr_id) {
        my $query = "
            SELECT * FROM course_reserves
            WHERE cr_id = ?
        ";
        $sth = $dbh->prepare($query);
        $sth->execute($cr_id);
    } else {
        my $query = "
            SELECT * FROM course_reserves
            WHERE course_id = ? AND ci_id = ?
        ";
        $sth = $dbh->prepare($query);
        $sth->execute( $course_id, $ci_id );
    }

    my $course_reserve = $sth->fetchrow_hashref();
    return $course_reserve;
}

=head2 ModCourseReserve

    $id = ModCourseReserve( %params );

=cut

sub ModCourseReserve {
    my (%params) = @_;
    warn identify_myself(%params) if $DEBUG;

    my $course_id   = $params{'course_id'};
    my $ci_id       = $params{'ci_id'};
    my $staff_note  = $params{'staff_note'};
    my $public_note = $params{'public_note'};

    return unless ( $course_id && $ci_id );

    my $course_reserve = GetCourseReserve( course_id => $course_id, ci_id => $ci_id );
    my $cr_id;

    my $dbh = C4::Context->dbh;

    if ($course_reserve) {
        $cr_id = $course_reserve->{'cr_id'};

        my $query = "
            UPDATE course_reserves
            SET staff_note = ?, public_note = ?
            WHERE cr_id = ?
        ";
        $dbh->do( $query, undef, $staff_note, $public_note, $cr_id );
    } else {
        my $query = "
            INSERT INTO course_reserves SET
            course_id = ?,
            ci_id = ?,
            staff_note = ?,
            public_note = ?
        ";
        $dbh->do( $query, undef, $course_id, $ci_id, $staff_note, $public_note );
        $cr_id = $dbh->last_insert_id( undef, undef, 'course_reserves', 'cr_id' );
    }

    my $course = GetCourse($course_id);
    EnableOrDisableCourseItem(
        ci_id   => $params{'ci_id'},
        enabled => $course->{'enabled'}
    );

    return $cr_id;
}

=head2 GetCourseReserves {

  $course_reserves = GetCourseReserves( %params );

  Required:
      course_id OR ci_id
  Optional:
      include_items   => 1,
      include_count   => 1,
      include_courses => 1,

=cut

sub GetCourseReserves {
    my (%params) = @_;
    warn identify_myself(%params) if $DEBUG;

    my $course_id       = $params{'course_id'};
    my $ci_id           = $params{'ci_id'};
    my $include_items   = $params{'include_items'};
    my $include_count   = $params{'include_count'};
    my $include_courses = $params{'include_courses'};

    return unless ( $course_id || $ci_id );

    my $field = ($course_id) ? 'course_id' : 'ci_id';
    my $value = ($course_id) ? $course_id  : $ci_id;

    my $query = "
        SELECT cr.*, ci.itemnumber
        FROM course_reserves cr, course_items ci
        WHERE cr.$field = ?
        AND cr.ci_id = ci.ci_id
    ";
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute($value);

    my $course_reserves = $sth->fetchall_arrayref( {} );

    if ($include_items) {
        foreach my $cr (@$course_reserves) {
            $cr->{'course_item'} = GetCourseItem( ci_id => $cr->{'ci_id'} );
            $cr->{'item'}        = GetBiblioFromItemNumber( $cr->{'itemnumber'} );
            $cr->{'issue'}       = GetOpenIssue( $cr->{'itemnumber'} );
        }
    }

    if ($include_count) {
        foreach my $cr (@$course_reserves) {
            $cr->{'reserves_count'} = CountCourseReservesForItem( ci_id => $cr->{'ci_id'} );
        }
    }

    if ($include_courses) {
        foreach my $cr (@$course_reserves) {
            $cr->{'courses'} = GetCourses( itemnumber => $cr->{'itemnumber'} );
        }
    }

    return $course_reserves;
}

=head2 DelCourseReserve {

  DelCourseReserve( cr_id => $cr_id );

=cut

sub DelCourseReserve {
    my (%params) = @_;
    warn identify_myself(%params) if $DEBUG;

    my $cr_id = $params{'cr_id'};

    return unless ($cr_id);

    my $dbh = C4::Context->dbh;

    my $course_reserve = GetCourseReserve( cr_id => $cr_id );

    my $query = "
        DELETE FROM course_reserves
        WHERE cr_id = ?
    ";
    $dbh->do( $query, undef, $cr_id );

    ## If there are no other course reserves for this item
    ## delete the course_item as well
    unless ( CountCourseReservesForItem( ci_id => $course_reserve->{'ci_id'} ) ) {
        DelCourseItem( ci_id => $course_reserve->{'ci_id'} );
    }

}

=head2 GetReservesInfo

    my $arrayref = GetItemCourseReservesInfo( itemnumber => $itemnumber );

    For a given item, returns an arrayref of reserves hashrefs,
    with a course hashref under the key 'course'

=cut

sub GetItemCourseReservesInfo {
    my (%params) = @_;
    warn identify_myself(%params) if $DEBUG;

    my $itemnumber = $params{'itemnumber'};

    return unless ($itemnumber);

    my $course_item = GetCourseItem( itemnumber => $itemnumber );

    return unless ( keys %$course_item );

    my $course_reserves = GetCourseReserves( ci_id => $course_item->{'ci_id'} );

    foreach my $cr (@$course_reserves) {
        $cr->{'course'} = GetCourse( $cr->{'course_id'} );
    }

    return $course_reserves;
}

=head2 CountCourseReservesForItem

    $bool = CountCourseReservesForItem( %params );

    ci_id - course_item id
    OR
    itemnumber - course_item itemnumber

    enabled = 'yes' or 'no'
    Optional, if not supplied, counts reserves
    for both enabled and disabled courses

=cut

sub CountCourseReservesForItem {
    my (%params) = @_;
    warn identify_myself(%params) if $DEBUG;

    my $ci_id      = $params{'ci_id'};
    my $itemnumber = $params{'itemnumber'};
    my $enabled    = $params{'enabled'};

    return unless ( $ci_id || $itemnumber );

    my $course_item = GetCourseItem( ci_id => $ci_id, itemnumber => $itemnumber );

    my @params = ( $course_item->{'ci_id'} );
    push( @params, $enabled ) if ($enabled);

    my $query = "
        SELECT COUNT(*) AS count
        FROM course_reserves cr
        LEFT JOIN courses c ON ( c.course_id = cr.course_id )
        WHERE ci_id = ?
    ";
    $query .= "AND c.enabled = ?" if ($enabled);

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute(@params);

    my $row = $sth->fetchrow_hashref();

    return $row->{'count'};
}

=head2 SearchCourses

    my $courses = SearchCourses( term => $search_term, enabled => 'yes' );

=cut

sub SearchCourses {
    my (%params) = @_;
    warn identify_myself(%params) if $DEBUG;

    my $term = $params{'term'};

    my $enabled = $params{'enabled'} || '%';

    my @params;
    my $query = "SELECT c.* FROM courses c";

    $query .= "
        LEFT JOIN course_instructors ci
            ON ( c.course_id = ci.course_id )
        LEFT JOIN borrowers b
            ON ( ci.borrowernumber = b.borrowernumber )
        LEFT JOIN authorised_values av
            ON ( c.department = av.authorised_value )
        WHERE
            ( av.category = 'DEPARTMENT' OR av.category = 'TERM' )
            AND
            (
                department LIKE ? OR
                course_number LIKE ? OR
                section LIKE ? OR
                course_name LIKE ? OR
                term LIKE ? OR
                public_note LIKE ? OR
                CONCAT(surname,' ',firstname) LIKE ? OR
                CONCAT(firstname,' ',surname) LIKE ? OR
                lib LIKE ? OR
                lib_opac LIKE ?
           )
           AND
           c.enabled LIKE ?
        GROUP BY c.course_id
    ";

    $term   = "%$term%";
    @params = ($term) x 10;

    $query .= " ORDER BY department, course_number, section, term, course_name ";

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);

    $sth->execute( @params, $enabled );

    my $courses = $sth->fetchall_arrayref( {} );

    foreach my $c (@$courses) {
        $c->{'instructors'} = GetCourseInstructors( $c->{'course_id'} );
    }

    return $courses;
}

sub whoami  { ( caller(1) )[3] }
sub whowasi { ( caller(2) )[3] }

sub stringify_params {
    my (%params) = @_;

    my $string = "\n";

    foreach my $key ( keys %params ) {
        $string .= "    $key => " . $params{$key} . "\n";
    }

    return "( $string )";
}

sub identify_myself {
    my (%params) = @_;

    return whowasi() . stringify_params(%params);
}

1;

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut
