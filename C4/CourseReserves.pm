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

use List::MoreUtils qw(any);

use C4::Context;
use C4::Circulation qw(GetOpenIssue);

use Koha::Courses;
use Koha::Course::Instructors;
use Koha::Course::Items;
use Koha::Course::Reserves;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $DEBUG @FIELDS);

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
    @FIELDS = ( 'itype', 'ccode', 'homebranch', 'holdingbranch', 'location' );
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

    my $course = Koha::Courses->find( $course_id );
    return undef unless $course;
    $course = $course->unblessed;

    my $dbh = C4::Context->dbh;
    my $query = "
        SELECT b.* FROM course_instructors ci
        LEFT JOIN borrowers b ON ( ci.borrowernumber = b.borrowernumber )
        WHERE course_id =  ?
    ";
    my $sth = $dbh->prepare($query);
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
        SELECT c.course_id, c.department, c.course_number, c.section, c.course_name, c.term, c.staff_note, c.public_note, c.students_count, c.enabled, c.timestamp
        FROM courses c
        LEFT JOIN course_reserves ON course_reserves.course_id = c.course_id
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

    $query .= " GROUP BY c.course_id, c.department, c.course_number, c.section, c.course_name, c.term, c.staff_note, c.public_note, c.students_count, c.enabled, c.timestamp ";

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
                );
            }
        }
    }
}

=head2 EnableOrDisableCourseItem

    EnableOrDisableCourseItem( ci_id => $ci_id );

=cut

sub EnableOrDisableCourseItem {
    my (%params) = @_;
    warn identify_myself(%params) if $DEBUG;

    my $ci_id   = $params{'ci_id'};

    return unless ( $ci_id );

    my $course_item = GetCourseItem( ci_id => $ci_id );

    my $info = GetItemCourseReservesInfo( itemnumber => $course_item->{itemnumber} );

    my $enabled = any { $_->{course}->{enabled} eq 'yes' } @$info;
    $enabled = $enabled ? 'yes' : 'no';

    ## We don't want to 'enable' an already enabled item,
    ## or disable and already disabled item,
    ## as that would cause the fields to swap
    if ( $course_item->{'enabled'} ne $enabled ) {
        _SwapAllFields($ci_id, $enabled );

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

    my $itemnumber = $params{'itemnumber'};

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

    $params{homebranch} ||= undef; # Can't be empty string, FK constraint
    $params{holdingbranch} ||= undef; # Can't be empty string, FK constraint

    my %data = map { $_ => $params{$_} } @FIELDS;
    my %enabled = map { $_ . "_enabled" => $params{ $_ . "_enabled" } } @FIELDS;

    my $ci = Koha::Course::Item->new(
        {
            itemnumber => $params{itemnumber},
            %data,
            %enabled,
        }
    )->store();

    return $ci->id;
}

=head2 _UpdateCourseItem

  _UpdateCourseItem( %params );

=cut

sub _UpdateCourseItem {
    my (%params) = @_;
    warn identify_myself(%params) if $DEBUG;

    my $ci_id         = $params{'ci_id'};
    my $course_item   = $params{'course_item'};

    $params{homebranch} ||= undef; # Can't be empty string, FK constraint
    $params{holdingbranch} ||= undef; # Can't be empty string, FK constraint

    return unless ( $ci_id || $course_item );

    $course_item = Koha::Course::Items->find( $ci_id || $course_item->{ci_id} );

    my %data = map { $_ => $params{$_} } @FIELDS;
    my %enabled = map { $_ . "_enabled" => $params{ $_ . "_enabled" } } @FIELDS;

    my $item = Koha::Items->find( $course_item->itemnumber );

    # Handle updates to changed fields for a course item, both adding and removing
    if ( $course_item->is_enabled ) {
        my $item_fields = {};

        for my $field ( @FIELDS ) {

            my $field_enabled = $field . '_enabled';
            my $field_storage = $field . '_storage';

            # Find newly enabled field and add item value to storage
            if ( $params{$field_enabled} && !$course_item->$field_enabled ) {
                $enabled{$field_storage} = $item->$field;
                $item_fields->{$field}   = $params{$field};
            }
            # Find newly disabled field and copy the storage value to the item, unset storage value
            elsif ( !$params{$field_enabled} && $course_item->$field_enabled ) {
                $item_fields->{$field}   = $course_item->$field_storage;
                $enabled{$field_storage} = undef;
            }
            # The field was already enabled, copy the incoming value to the item.
            # The "original" ( when not on course reserve ) value is already in the storage field
            elsif ( $course_item->$field_enabled) {
                $item_fields->{$field} = $params{$field};
            }
        }

        $item->set( $item_fields )->store
            if keys %$item_fields;
    }

    $course_item->update( { %data, %enabled } );

}

=head2 _RevertFields

    _RevertFields( ci_id => $ci_id, fields => \@fields_to_revert );

    Copies fields from course item storage back to the actual item

=cut

sub _RevertFields {
    my (%params) = @_;
    warn identify_myself(%params) if $DEBUG;

    my $ci_id = $params{'ci_id'};

    return unless $ci_id;

    my $course_item = Koha::Course::Items->find( $ci_id );

    my $item_fields = {};
    $item_fields->{itype}         = $course_item->itype_storage         if $course_item->itype_enabled;
    $item_fields->{ccode}         = $course_item->ccode_storage         if $course_item->ccode_enabled;
    $item_fields->{location}      = $course_item->location_storage      if $course_item->location_enabled;
    $item_fields->{homebranch} = $course_item->homebranch_storage if $course_item->homebranch_enabled;
    $item_fields->{holdingbranch} = $course_item->holdingbranch_storage if $course_item->holdingbranch_enabled;

    Koha::Items->find( $course_item->itemnumber )
               ->set( $item_fields )
               ->store
        if keys %$item_fields;

    $course_item->itype_storage(undef);
    $course_item->ccode_storage(undef);
    $course_item->location_storage(undef);
    $course_item->homebranch_storage(undef);
    $course_item->holdingbranch_storage(undef);
    $course_item->store();
}

=head2 _SwapAllFields

    _SwapAllFields( $ci_id );

=cut

sub _SwapAllFields {
    my ( $ci_id, $enabled ) = @_;
    warn "C4::CourseReserves::_SwapFields( $ci_id )" if $DEBUG;

    my $course_item = Koha::Course::Items->find( $ci_id );
    my $item = Koha::Items->find( $course_item->itemnumber );

    if ( $enabled eq 'yes' ) { # Copy item fields to course item storage, course item fields to item
        $course_item->itype_storage( $item->effective_itemtype )    if $course_item->itype_enabled;
        $course_item->ccode_storage( $item->ccode )                 if $course_item->ccode_enabled;
        $course_item->location_storage( $item->location )           if $course_item->location_enabled;
        $course_item->homebranch_storage( $item->homebranch )       if $course_item->homebranch_enabled;
        $course_item->holdingbranch_storage( $item->holdingbranch ) if $course_item->holdingbranch_enabled;
        $course_item->store();

        my $item_fields = {};
        $item_fields->{itype}         = $course_item->itype         if $course_item->itype_enabled;
        $item_fields->{ccode}         = $course_item->ccode         if $course_item->ccode_enabled;
        $item_fields->{location}      = $course_item->location      if $course_item->location_enabled;
        $item_fields->{homebranch}    = $course_item->homebranch    if $course_item->homebranch_enabled;
        $item_fields->{holdingbranch} = $course_item->holdingbranch if $course_item->holdingbranch_enabled;

        Koha::Items->find( $course_item->itemnumber )
                   ->set( $item_fields )
                   ->store
            if keys %$item_fields;

    } else { # Copy course item storage to item
        my $item_fields = {};
        $item_fields->{itype}         = $course_item->itype_storage         if $course_item->itype_enabled;
        $item_fields->{ccode}         = $course_item->ccode_storage         if $course_item->ccode_enabled;
        $item_fields->{location}      = $course_item->location_storage      if $course_item->location_enabled;
        $item_fields->{homebranch}    = $course_item->homebranch_storage    if $course_item->homebranch_enabled;
        $item_fields->{holdingbranch} = $course_item->holdingbranch_storage if $course_item->holdingbranch_enabled;

        Koha::Items->find( $course_item->itemnumber )
                   ->set( $item_fields )
                   ->store
            if keys %$item_fields;

        $course_item->itype_storage(undef);
        $course_item->ccode_storage(undef);
        $course_item->location_storage(undef);
        $course_item->homebranch_storage(undef);
        $course_item->holdingbranch_storage(undef);
        $course_item->store();
    }
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

    my $course_item = Koha::Course::Items->find( $ci_id );
    return unless $course_item;

    _RevertFields( ci_id => $ci_id ) if $course_item->enabled eq 'yes';

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

    EnableOrDisableCourseItem(
        ci_id   => $params{'ci_id'},
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
            my $item = Koha::Items->find( $cr->{itemnumber} );
            my $biblio = $item->biblio;
            my $biblioitem = $biblio->biblioitem;
            $cr->{'course_item'} = GetCourseItem( ci_id => $cr->{'ci_id'} );
            $cr->{'item'}        = $item;
            $cr->{'biblio'}      = $biblio;
            $cr->{'biblioitem'}  = $biblioitem;
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

=head2 GetItemCourseReservesInfo

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
    my $query = "
        SELECT c.course_id, c.department, c.course_number, c.section, c.course_name, c.term, c.staff_note, c.public_note, c.students_count, c.enabled, c.timestamp
        FROM courses c
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
        GROUP BY c.course_id, c.department, c.course_number, c.section, c.course_name, c.term, c.staff_note, c.public_note, c.students_count, c.enabled, c.timestamp
    ";

    $term //= '';
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
