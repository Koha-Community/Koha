package Koha::Script;

# Copyright PTFS Europe 2019
# Copyright 2019 Koha Development Team
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

=head1 NAME

Koha::Script - Koha scripts base class

=head1 SYNOPSIS

    use Koha::Script
    use Koha::Script -cron;

=head1 DESCRIPTION

This class should be used in all scripts. It sets the interface and userenv appropriately.

=cut

use File::Basename qw( fileparse );
use Fcntl          qw( LOCK_EX LOCK_NB );

use C4::Context;
use Koha::Exceptions;
use Koha::Exception;

sub import {
    my $class = shift;
    my @flags = @_;

    if ( ( $flags[0] || '' ) eq '-cron' ) {

        # Set userenv
        C4::Context->set_userenv(
            undef, undef, undef, 'CRON', 'CRON',
            undef, undef, undef, undef,  undef
        );

        # Set interface
        C4::Context->interface('cron');

    } else {

        # Set userenv
        C4::Context->set_userenv(
            undef, undef, undef, 'CLI', 'CLI',
            undef, undef, undef, undef, undef
        );

        # Set interface
        C4::Context->interface('commandline');
    }
}

=head1 API

=head2 Class methods

=head3 new

    my $script = Koha::Script->new(
        {
            script    => $0, # mandatory
          [ lock_name => 'my_script' ]
        }
    );

Create a new Koha::Script object. The I<script> parameter is mandatory,
and will usually be passed I<$0> in the caller script. The I<lock_name>
parameter is optional, and is used to generate the lock file if passed.

=cut

sub new {
    my ( $class, $params ) = @_;
    my $script = $params->{script};

    Koha::Exceptions::MissingParameter->throw("The 'script' parameter is mandatory. You should usually pass \$0")
        unless $script;

    my $self = { script => $script };
    $self->{lock_name} = $params->{lock_name}
        if exists $params->{lock_name} and $params->{lock_name};

    bless $self, $class;
    return $self;
}

=head3 lock_exec

    # die if cannot get the lock
    try {
        $script->lock_exec;
    }
    catch {
        die "$_";
    };

    # wait for the lock to be released
    $script->lock_exec({ wait => 1 });

This method sets an execution lock to prevent concurrent execution of the caller
script. If passed the I<wait> parameter with a true value, it will make the caller
wait until it can be granted the lock (flock's LOCK_NB behaviour). It will
otherwise throw an exception immediately.

=cut

sub lock_exec {
    my ( $self, $params ) = @_;

    $self->_initialize_locking
        unless $self->{lock_file};

    my $lock_params = ( $params->{wait} ) ? LOCK_EX : LOCK_EX | LOCK_NB;

    open my $lock_handle, '>', $self->{lock_file}
        or Koha::Exception->throw( "Unable to open the lock file " . $self->{lock_file} . ": $!" );
    $self->{lock_handle} = $lock_handle;
    flock( $lock_handle, $lock_params )
        or Koha::Exception->throw( "Unable to acquire the lock " . $self->{lock_file} . ": $!" );
}

=head2 Internal methods

=head3 _initialize_locking

    $self->_initialize_locking

This method initializes the locking configuration.

=cut

sub _initialize_locking {
    my ($self) = @_;

    my $lock_dir = C4::Context->config('lockdir') // C4::Context->temporary_directory();

    my $lock_name = $self->{lock_name} // fileparse( $self->{script} );
    $self->{lock_file} = "$lock_dir/$lock_name";

    return $self;
}

=head1 AUTHOR

Martin Renvoize <martin.renvoize@ptfs-europe.com>

=cut

1;
