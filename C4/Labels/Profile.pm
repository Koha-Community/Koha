package C4::Labels::Profile;

# Copyright 2009 Foundations Bible College.
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

use strict;
use warnings;
use Sys::Syslog qw(syslog);
use Data::Dumper;

use C4::Context;
use C4::Debug;

BEGIN {
    use version; our $VERSION = qv('1.0.0_1');
}

my $unit_values = {
    POINT       => 1,
    INCH        => 72,
    MM          => 2.83464567,
    CM          => 28.3464567,
};

sub _check_params {
    my $given_params = {};
    my $exit_code = 0;
    my @valid_profile_params = (
        'printer_name',
        'tmpl_id',
        'paper_bin',
        'offset_horz',
        'offset_vert',
        'creep_horz',
        'creep_vert',
        'unit',
    );
    if (scalar(@_) >1) {
        $given_params = {@_};
        foreach my $key (keys %{$given_params}) {
            if (!(grep m/$key/, @valid_profile_params)) {
                syslog("LOG_ERR", "C4::Labels::Profile : Unrecognized parameter type of \"%s\".", $key);
                $exit_code = 1;
            }
        }
    }
    else {
        if (!(grep m/$_/, @valid_profile_params)) {
            syslog("LOG_ERR", "C4::Labels::Profile : Unrecognized parameter type of \"%s\".", $_);
            $exit_code = 1;
        }
    }
    return $exit_code;
}

sub _conv_points {
    my $self = shift;
    $self->{offset_horz}        = $self->{offset_horz} * $unit_values->{$self->{unit}};
    $self->{offset_vert}        = $self->{offset_vert} * $unit_values->{$self->{unit}};
    $self->{creep_horz}         = $self->{creep_horz} * $unit_values->{$self->{unit}};
    $self->{creep_vert}         = $self->{creep_vert} * $unit_values->{$self->{unit}};
    return $self;
}

=head1 NAME

C4::Labels::Profile - A class for creating and manipulating profile objects in Koha

=cut

=head1 METHODS

=head2 C4::Labels::Profile->new()

    Invoking the I<new> method constructs a new profile object containing the default values for a template.

    example:
        my $profile = Profile->new(); # Creates and returns a new profile object

    B<NOTE:> This profile is I<not> written to the database untill $profile->save() is invoked. You have been warned!

=cut

sub new {
    my $invocant = shift;
    if (_check_params(@_) eq 1) {
        return 1;
    }
    my $type = ref($invocant) || $invocant;
    my $self = {
        printer_name    => '',
        tmpl_id         => '',
        paper_bin       => '',
        offset_horz     => 0,
        offset_vert     => 0,
        creep_horz      => 0,
        creep_vert      => 0,
        unit            => 'POINT',
        @_,
    };
    bless ($self, $type);
    return $self;
}

=head2 C4::Labels::Profile->retrieve(profile_id => profile_id, convert => 1)

    Invoking the I<retrieve> method constructs a new profile object containing the current values for profile_id. The method returns
    a new object upon success and 1 upon failure. Errors are logged to the syslog. One further option maybe accessed. See the examples
    below for further description.

    examples:

        my $profile = C4::Labels::Profile->retrieve(profile_id => 1); # Retrieves profile record 1 and returns an object containing the record

        my $profile = C4::Labels::Profile->retrieve(profile_id => 1, convert => 1); # Retrieves profile record 1, converts the units to points,
        and returns an object containing the record

=cut

sub retrieve {
    my $invocant = shift;
    my %opts = @_;
    my $type = ref($invocant) || $invocant;
    my $query = "SELECT * FROM printers_profile WHERE prof_id = ?";  
    my $sth = C4::Context->dbh->prepare($query);
    $sth->execute($opts{profile_id});
    if ($sth->err) {
        syslog("LOG_ERR", "Database returned the following error: %s", $sth->errstr);
        return 1;
    }
    my $self = $sth->fetchrow_hashref;
    $self = _conv_points($self) if ($opts{convert} && $opts{convert} == 1);
    bless ($self, $type);
    return $self;
}

=head2 C4::Labels::Profile->delete(prof_id => profile_id) |  $profile->delete()

    Invoking the delete method attempts to delete the profile from the database. The method returns 0 upon success
    and 1 upon failure. Errors are logged to the syslog.

    examples:
        my $exitstat = $profile->delete(); # to delete the record behind the $profile object
        my $exitstat = C4::Labels::Profile->delete(prof_id => 1); # to delete profile record 1

=cut

sub delete {
    my $self = shift;
    if (!$self->{'prof_id'}) {   # If there is no profile prof_id then we cannot delete it
        syslog("LOG_ERR", "Cannot delete profile as it has not been saved.");
        return 1;
    }
    my $query = "DELETE FROM printers_profile WHERE prof_id = ?";  
    my $sth = C4::Context->dbh->prepare($query);
    $sth->execute($self->{'prof_id'});
    return 0;
}

=head2 $profile->save()

    Invoking the I<save> method attempts to insert the profile into the database if the profile is new and
    update the existing profile record if the profile exists. The method returns the new record prof_id upon
    success and -1 upon failure (This avoids conflicting with a record prof_id of 1). Errors are logged to the syslog.

    example:
        my $exitstat = $profile->save(); # to save the record behind the $profile object

=cut

sub save {
    my $self = shift;
    if ($self->{'prof_id'}) {        # if we have an prof_id, the record exists and needs UPDATE
        my @params;
        my $query = "UPDATE printers_profile SET ";
        foreach my $key (keys %{$self}) {
            next if $key eq 'prof_id';
            push (@params, $self->{$key});
            $query .= "$key=?, ";
        }
        $query = substr($query, 0, (length($query)-2));
        push (@params, $self->{'prof_id'});
        $query .= " WHERE prof_id=?;";
        warn "DEBUG: Updating: $query\n" if $debug;
        my $sth = C4::Context->dbh->prepare($query);
        $sth->execute(@params);
        if ($sth->err) {
            syslog("LOG_ERR", "C4::Labels::Profile : Database returned the following error: %s", $sth->errstr);
            return -1;
        }
        return $self->{'prof_id'};
    }
    else {                      # otherwise create a new record
        my @params;
        my $query = "INSERT INTO printers_profile (";
        foreach my $key (keys %{$self}) {
            push (@params, $self->{$key});
            $query .= "$key, ";
        }
        $query = substr($query, 0, (length($query)-2));
        $query .= ") VALUES (";
        for (my $i=1; $i<=(scalar keys %$self); $i++) {
            $query .= "?,";
        }
        $query = substr($query, 0, (length($query)-1));
        $query .= ");";
        warn "DEBUG: Saving: $query\n" if $debug;
        my $sth = C4::Context->dbh->prepare($query);
        $sth->execute(@params);
        if ($sth->err) {
            syslog("LOG_ERR", "C4::Labels::Profile : Database returned the following error: %s", $sth->errstr);
            return -1;
        }
        my $sth1 = C4::Context->dbh->prepare("SELECT MAX(prof_id) FROM printers_profile;");
        $sth1->execute();
        my $tmpl_id = $sth1->fetchrow_array;
        return $tmpl_id;
    }
}

=head2 $profile->get_attr(attr)

    Invoking the I<get_attr> method will return the value of the requested attribute or 1 on errors.

    example:
        my $value = $profile->get_attr(attr);

=cut

sub get_attr {
    my $self = shift;
    if (_check_params(@_) eq 1) {
        return 1;
    }
    my ($attr) = @_;
    if (exists($self->{$attr})) {
        return $self->{$attr};
    }
    else {
        syslog("LOG_ERR", "C4::Labels::Profile : %s is currently undefined.", $attr);
        return 1;
    }
}

=head2 $profile->set_attr(attr => value)

    Invoking the I<set_attr> method will set the value of the supplied attribute to the supplied value.

    example:
        $profile->set_attr(attr => value);

=cut

sub set_attr {
    my $self = shift;
    if (_check_params(@_) eq 1) {
        return 1;
    }
    my ($attr, $value) = @_;
    $self->{$attr} = $value;
    return 0;
}


1;
__END__

=head1 AUTHOR

Chris Nighswonger <cnighswonger AT foundations DOT edu>

=cut


=head1
drawbox( ($left_margin), ($top_margin), ($page_width-(2*$left_margin)), ($page_height-(2*$top_margin)) ); # FIXME: Breakout code to print alignment page for printer profile setup

ead2 draw_boundaries

 sub draw_boundaries ($llx_spine, $llx_circ1, $llx_circ2,
                $lly, $spine_width, $label_height, $circ_width)  

This sub draws boundary lines where the label outlines are, to aid in printer testing, and debugging.

=cut

#       FIXME: Template use for profile adjustment...
#sub draw_boundaries {
#
#    my (
#        $llx_spine, $llx_circ1,  $llx_circ2, $lly,
#        $spine_width, $label_height, $circ_width
#    ) = @_;
#
#    my $lly_initial = ( ( 792 - 36 ) - 90 );
#    $lly            = $lly_initial; # FIXME - why are we ignoring the y_pos parameter by redefining it?
#    my $i             = 1;
#
#    for ( $i = 1 ; $i <= 8 ; $i++ ) {
#
#        _draw_box( $llx_spine, $lly, ($spine_width), ($label_height) );
#
#   #warn "OLD BOXES  x=$llx_spine, y=$lly, w=$spine_width, h=$label_height";
#        _draw_box( $llx_circ1, $lly, ($circ_width), ($label_height) );
#        _draw_box( $llx_circ2, $lly, ($circ_width), ($label_height) );
#
#        $lly = ( $lly - $label_height );
#
#    }
#}



=cut
