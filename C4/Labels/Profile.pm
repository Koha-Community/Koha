package C4::Labels::Profile;

use strict;
use warnings;
use Sys::Syslog qw(syslog);

use C4::Context;
use C4::Debug;
use C4::Labels::Lib 1.000000 qw(get_unit_values);

BEGIN {
    use version; our $VERSION = qv('1.0.0_1');
}

sub _check_params {
    my $given_params = {};
    my $exit_code = 0;
    my @valid_profile_params = (
        'printer_name',
        'template_id',
        'paper_bin',
        'offset_horz',
        'offset_vert',
        'creep_horz',
        'creep_vert',
        'units',
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
    my @unit_value = grep {$_->{'type'} eq $self->{units}} @{get_unit_values()};
    $self->{offset_horz}        = $self->{offset_horz} * $unit_value[0]->{'value'};
    $self->{offset_vert}        = $self->{offset_vert} * $unit_value[0]->{'value'};
    $self->{creep_horz}         = $self->{creep_horz} * $unit_value[0]->{'value'};
    $self->{creep_vert}         = $self->{creep_vert} * $unit_value[0]->{'value'};
    return $self;
}

sub new {
    my $invocant = shift;
    if (_check_params(@_) eq 1) {
        return -1;
    }
    my $type = ref($invocant) || $invocant;
    my $self = {
        printer_name    => 'Default Printer',
        template_id     => '',
        paper_bin       => 'Tray 1',
        offset_horz     => 0,
        offset_vert     => 0,
        creep_horz      => 0,
        creep_vert      => 0,
        units           => 'POINT',
        @_,
    };
    bless ($self, $type);
    return $self;
}

sub retrieve {
    my $invocant = shift;
    my %opts = @_;
    my $type = ref($invocant) || $invocant;
    my $query = "SELECT * FROM printers_profile WHERE profile_id = ?";  
    my $sth = C4::Context->dbh->prepare($query);
    $sth->execute($opts{profile_id});
    if ($sth->err) {
        syslog("LOG_ERR", "Database returned the following error: %s", $sth->errstr);
        return -1;
    }
    my $self = $sth->fetchrow_hashref;
    $self = _conv_points($self) if ($opts{convert} && $opts{convert} == 1);
    bless ($self, $type);
    return $self;
}

sub delete {
    my $self = {};
    my %opts = ();
    my $call_type = '';
    my $query_param = '';
    if (ref($_[0])) {
        $self = shift;  # check to see if this is a method call
        $call_type = 'C4::Labels::Profile->delete';
        $query_param = $self->{'profile_id'};
    }
    else {
        %opts = @_;
        $call_type = 'C4::Labels::Profile::delete';
        $query_param = $opts{'profile_id'};
    }
    if ($query_param eq '') {   # If there is no profile id then we cannot delete it
        syslog("LOG_ERR", "%s : Cannot delete layout as the profile id is invalid or non-existant.", $call_type);
        return -1;
    }
    my $query = "DELETE FROM printers_profile WHERE profile_id = ?";  
    my $sth = C4::Context->dbh->prepare($query);
#    $sth->{'TraceLevel'} = 3;
    $sth->execute($query_param);
}

sub save {
    my $self = shift;
    if ($self->{'profile_id'}) {        # if we have an profile_id, the record exists and needs UPDATE
        my @params;
        my $query = "UPDATE printers_profile SET ";
        foreach my $key (keys %{$self}) {
            next if $key eq 'profile_id';
            push (@params, $self->{$key});
            $query .= "$key=?, ";
        }
        $query = substr($query, 0, (length($query)-2));
        push (@params, $self->{'profile_id'});
        $query .= " WHERE profile_id=?;";
        my $sth = C4::Context->dbh->prepare($query);
#        $sth->{'TraceLevel'} = 3;
        $sth->execute(@params);
        if ($sth->err) {
            syslog("LOG_ERR", "C4::Labels::Profile : Database returned the following error on attempted UPDATE: %s", $sth->errstr);
            return -1;
        }
        return $self->{'profile_id'};
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
        my $sth = C4::Context->dbh->prepare($query);
        $sth->execute(@params);
        if ($sth->err) {
            syslog("LOG_ERR", "C4::Labels::Profile : Database returned the following error on attempted INSERT: %s", $sth->errstr);
            return -1;
        }
        my $sth1 = C4::Context->dbh->prepare("SELECT MAX(profile_id) FROM printers_profile;");
        $sth1->execute();
        my $tmpl_id = $sth1->fetchrow_array;
        return $tmpl_id;
    }
}

sub get_attr {
    my $self = shift;
    if (_check_params(@_) eq 1) {
        return -1;
    }
    my ($attr) = @_;
    if (exists($self->{$attr})) {
        return $self->{$attr};
    }
    else {
        syslog("LOG_ERR", "C4::Labels::Profile : %s is currently undefined.", $attr);
        return -1;
    }
}

sub set_attr {
    my $self = shift;
    if (_check_params(@_) eq 1) {
        return -1;
    }
    my %attrs = @_;
    foreach my $attrib (keys(%attrs)) {
        $self->{$attrib} = $attrs{$attrib};
    };
    return 0;
}

1;
__END__

=head1 NAME

C4::Labels::Profile - A class for creating and manipulating profile objects in Koha

=head1 ABSTRACT

This module provides methods for creating, retrieving, and otherwise manipulating label profile objects used by Koha to create and export labels.

=head1 METHODS

=head2 new()

    Invoking the I<new> method constructs a new profile object containing the default values for a template.
    The following parameters are optionally accepted as key => value pairs:

        C<printer_name>         The name of the printer to which this profile applies.
        C<template_id>          The template to which this profile may be applied. NOTE: There may be multiple profiles which may be applied to the same template.
        C<paper_bin>            The paper bin of the above printer to which this profile applies. NOTE: printer name, template id, and paper bin must form a unique combination.
        C<offset_horz>          Amount of compensation for horizontal offset (position of text on a single label). This amount is measured in the units supplied by the units parameter in this profile.
        C<offset_vert>          Amount of compensation for vertical offset.
        C<creep_horz>           Amount of compensation for horizontal creep (tendency of text to 'creep' off of the labels over the span of the entire page).
        C<creep_vert>           Amount of compensation for vertical creep.
        C<units>                The units of measure used for this template. These B<must> match the measures you supply above or
                                bad things will happen to your document. NOTE: The only supported units at present are:

=over 9

=item .
POINT   = Postscript Points (This is the base unit in the Koha label creator.)

=item .
AGATE   = Adobe Agates (5.1428571 points per)

=item .
INCH    = US Inches (72 points per)

=item .
MM      = SI Millimeters (2.83464567 points per)

=item .
CM      = SI Centimeters (28.3464567 points per)

=back

    example:
        C<my $profile = C4::Labels::Profile->new(); # Creates and returns a new profile object>

        C<my $profile = C4::Labels::Profile->new(template_id => 1, paper_bin => 'Bypass Tray', offset_horz => 0.02, units => 'POINT'); # Creates and returns a new profile object using
            the supplied values to override the defaults>

    B<NOTE:> This profile is I<not> written to the database until save() is invoked. You have been warned!

=head2 retrieve(profile_id => $profile_id, convert => 1)

    Invoking the I<retrieve> method constructs a new profile object containing the current values for profile_id. The method returns a new object upon success and 1 upon failure.
    Errors are logged to the syslog. One further option maybe accessed. See the examples below for further description.

    examples:

        C<my $profile = C4::Labels::Profile->retrieve(profile_id => 1); # Retrieves profile record 1 and returns an object containing the record>

        C<my $profile = C4::Labels::Profile->retrieve(profile_id => 1, convert => 1); # Retrieves profile record 1, converts the units to points and returns an object containing the record>

=head2 delete()

    Invoking the delete method attempts to delete the profile from the database. The method returns -1 upon failure. Errors are logged to the syslog.
    NOTE: This method may also be called as a function and passed a key/value pair simply deleteing that profile from the database. See the example below.

    examples:
        C<my $exitstat = $profile->delete(); # to delete the record behind the $profile object>
        C<my $exitstat = C4::Labels::Profile::delete(profile_id => 1); # to delete profile record 1>

=head2 save()

    Invoking the I<save> method attempts to insert the profile into the database if the profile is new and update the existing profile record if the profile exists. The method returns
    the new record profile_id upon success and -1 upon failure (This avoids conflicting with a record profile_id of 1). Errors are logged to the syslog.

    example:
        C<my $exitstat = $profile->save(); # to save the record behind the $profile object>

=head2 get_attr($attribute)

    Invoking the I<get_attr> method will return the value of the requested attribute or -1 on errors.

    example:
        C<my $value = $profile->get_attr($attribute);>

=head2 set_attr(attribute => value, attribute_2 => value)

    Invoking the I<set_attr> method will set the value of the supplied attributes to the supplied values. The method accepts key/value pairs separated by commas.

    example:
        $profile->set_attr(attribute => value);

=head1 AUTHOR

Chris Nighswonger <cnighswonger AT foundations DOT edu>

=head1 COPYRIGHT

Copyright 2009 Foundations Bible College.

=head1 LICENSE

This file is part of Koha.
       
Koha is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later version.

You should have received a copy of the GNU General Public License along with Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
Suite 330, Boston, MA  02111-1307 USA

=head1 DISCLAIMER OF WARRANTY

Koha is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

=cut

#=head1
#drawbox( ($left_margin), ($top_margin), ($page_width-(2*$left_margin)), ($page_height-(2*$top_margin)) ); # FIXME: Breakout code to print alignment page for printer profile setup
#
#=head2 draw_boundaries
#
# sub draw_boundaries ($llx_spine, $llx_circ1, $llx_circ2,
#                $lly, $spine_width, $label_height, $circ_width)  
#
#This sub draws boundary lines where the label outlines are, to aid in printer testing, and debugging.
#
#=cut
#
##       FIXME: Template use for profile adjustment...
##sub draw_boundaries {
##
##    my (
##        $llx_spine, $llx_circ1,  $llx_circ2, $lly,
##        $spine_width, $label_height, $circ_width
##    ) = @_;
##
##    my $lly_initial = ( ( 792 - 36 ) - 90 );
##    $lly            = $lly_initial; # FIXME - why are we ignoring the y_pos parameter by redefining it?
##    my $i             = 1;
##
##    for ( $i = 1 ; $i <= 8 ; $i++ ) {
##
##        _draw_box( $llx_spine, $lly, ($spine_width), ($label_height) );
##
##   #warn "OLD BOXES  x=$llx_spine, y=$lly, w=$spine_width, h=$label_height";
##        _draw_box( $llx_circ1, $lly, ($circ_width), ($label_height) );
##        _draw_box( $llx_circ2, $lly, ($circ_width), ($label_height) );
##
##        $lly = ( $lly - $label_height );
##
##    }
##}
#
#
#
#=cut
