package C4::Labels::Layout;

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
use DBI qw(neat);

use C4::Context;
use C4::Debug;
use Data::Dumper;

BEGIN {
    use version; our $VERSION = qv('1.0.0_1');
}

# FIXME: Consider this style parameter verification instead...
#  my %param = @_;
#   for (keys %param)
#    {   my $lc = lc($_); 
#        if (exists $default{$lc})
#        {  $default{$lc} = $param{$_}; 
#        }
#        else
#        {  print STDERR "Unknown parameter $_ , not used \n";
#        }
#    }

sub _check_params {
    my $exit_code = 0;
    my @valtmpl_id_params = (
        'barcode_type',
        'printing_type',
        'layout_name',
        'guidebox',
        'font',
        'font_size',
        'callnum_split',
        'text_justify',
        'format_string',
    );
    if (scalar(@_) >1) {
        my %given_params = @_;
        foreach my $key (keys %given_params) {
            if (!(grep m/$key/, @valtmpl_id_params)) {
                syslog("LOG_ERR", "C4::Labels::Layout : (Multiple parameters) Unrecognized parameter type of \"%s\".", $key);
                $exit_code = 1;
            }
        }
    }
    else {
        if (!(grep m/$_/, @valtmpl_id_params)) {
            syslog("LOG_ERR", "C4::Labels::Layout : (Single parameter) Unrecognized parameter type of \"%s\".", $_);
            $exit_code = 1;
        }
    }
    return $exit_code;
}

=head1 NAME

C4::Labels::Layout -A class for creating and manipulating layout objects in Koha

=cut

=head1 METHODS

=head2 C4::Labels::Layout->new()

    Invoking the I<new> method constructs a new layout object containing the default values for a layout.

    example:
        my $layout = Layout->new(); # Creates and returns a new layout object

    B<NOTE:> This layout is I<not> written to the database untill $layout->save() is invoked. You have been warned!

=cut

sub new {
    my $invocant = shift;
    if (_check_params(@_) eq 1) {
        return -1;
    }
    my $type = ref($invocant) || $invocant;
    my $self = {
        barcode_type    =>      'CODE39',
        printing_type   =>      'BAR',
        layout_name     =>      'DEFAULT',
        guidebox        =>      0,
        font            =>      'TR',
        font_size       =>      3,
        callnum_split   =>      0,
        text_justify    =>      'L',
        format_string   =>      'title, author, isbn, issn, itemtype, barcode, callnumber',
        @_,
    };
    bless ($self, $type);
    return $self;
}

=head2 Layout->retrieve(layout_id => layout_id)

    Invoking the I<retrieve> method constructs a new layout object containing the current values for layout_id. The method returns
    a new object upon success and 1 upon failure. Errors are logged to the syslog.

    example:
        my $layout = Layout->retrieve(layout_id => 1); # Retrieves layout record 1 and returns an object containing the record

=cut

sub retrieve {
    my $invocant = shift;
    my %opts = @_;
    my $type = ref($invocant) || $invocant;
    my $query = "SELECT * FROM labels_layouts WHERE layout_id = ?";  
    my $sth = C4::Context->dbh->prepare($query);
    $sth->execute($opts{'layout_id'});
    if ($sth->err) {
        syslog("LOG_ERR", "Database returned the following error: %s", $sth->errstr);
        return -1;
    }
    my $self = $sth->fetchrow_hashref;
    bless ($self, $type);
    return $self;
}

=head2 Layout->delete(layout_id => layout_id) |  $layout->delete()

    Invoking the delete method attempts to delete the layout from the database. The method returns 0 upon success
    and 1 upon failure. Errors are logged to the syslog.

    examples:
        my $exitstat = $layout->delete(); # to delete the record behind the $layout object
        my $exitstat = Layout->delete(layout_id => 1); # to delete layout record 1

=cut

sub delete {
    my $self = {};
    my %opts = ();
    my $call_type = '';
    my $query_param = '';
    if (ref($_[0])) {
        $self = shift;  # check to see if this is a method call
        $call_type = 'C4::Labels::Layout->delete';
        $query_param = $self->{'layout_id'};
    }
    else {
        %opts = @_;
        $call_type = 'C4::Labels::Layout::delete';
        $query_param = $opts{'layout_id'};
    }
    if ($query_param eq '') {   # If there is no layout id then we cannot delete it
        syslog("LOG_ERR", "%s : Cannot delete layout as the layout id is invalid or non-existant.", $call_type);
        return -1;
    }
    my $query = "DELETE FROM labels_layouts WHERE layout_id = ?";  
    my $sth = C4::Context->dbh->prepare($query);
    $sth->execute($query_param);
    if ($sth->err) {
        syslog("LOG_ERR", "%s : Database returned the following error: %s", $call_type, $sth->errstr);
        return -1;
    }
    return 0;
}

=head2 $layout->save()

    Invoking the I<save> method attempts to insert the layout into the database if the layout is new and
    update the existing layout record if the layout exists. The method returns the new record id upon
    success and -1 upon failure (This avoids conflicting with a record id of 1). Errors are logged to the syslog.

    example:
        my $exitstat = $layout->save(); # to save the record behind the $layout object

=cut

sub save {
    my $self = shift;
    if ($self->{'layout_id'}) {        # if we have an id, the record exists and needs UPDATE
        my @params;
        my $query = "UPDATE labels_layouts SET ";
        foreach my $key (keys %{$self}) {
            next if $key eq 'layout_id';
            push (@params, $self->{$key});
            $query .= "$key=?, ";
        }
        $query = substr($query, 0, (length($query)-2));
        $query .= " WHERE layout_id=?;";
        push (@params, $self->{'layout_id'});
        my $sth = C4::Context->dbh->prepare($query);
        #local $sth->{TraceLevel} = "3";        # enable DBI trace and set level; outputs to STDERR
        $sth->execute(@params);
        if ($sth->err) {
            syslog("LOG_ERR", "C4::Labels::Layout : Database returned the following error: %s", $sth->errstr);
            return -1;
        }
        return $self->{'layout_id'};
    }
    else {                      # otherwise create a new record
        my @params;
        my $query = "INSERT INTO labels_layouts (";
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
            syslog("LOG_ERR", "C4::Labels::Layout : Database returned the following error: %s", $sth->errstr);
            return -1;
        }
        my $sth1 = C4::Context->dbh->prepare("SELECT MAX(layout_id) FROM labels_layouts;");
        $sth1->execute();
        my $id = $sth1->fetchrow_array;
        return $id;
    }
}

=head2 $layout->get_attr("attr")

    Invoking the I<get_attr> method will return the value of the requested attribute or 1 on errors.

    example:
        my $value = $layout->get_attr("attr");

=cut

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
        return -1;
    }
    return;
}

=head2 $layout->set_attr(attr => value)

    Invoking the I<set_attr> method will set the value of the supplied attribute to the supplied value.

    example:
        $layout->set_attr(attr => value);

=cut

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

=head2 $layout->get_text_wrap_cols()

    Invoking the I<get_text_wrap_cols> method will return the number of columns that can be printed on the
    label before wrapping to the next line.

    examples:
        my $text_wrap_cols = $layout->get_text_wrap_cols();

=cut

sub get_text_wrap_cols {
    my $self = shift;
    my %params = @_;
    my $string = '';
    my $strwidth = 0;
    my $col_count = 0;
    my $textlimit = $params{'label_width'} - ( 3 * $params{'left_text_margin'});

    while ($strwidth < $textlimit) {
        $string .= '0';
        $col_count++;
        $strwidth = C4::Labels::PDF->StrWidth( $string, $self->{'font'}, $self->{'font_size'} );
    }
    return $col_count;
}

1;
__END__

=head1 AUTHOR

Chris Nighswonger <cnighswonger AT foundations DOT edu>

=cut
