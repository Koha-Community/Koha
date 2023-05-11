package t::lib::Mocks;

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

use Test::MockModule;
use Test::MockObject;

=head1 NAME

t::lib::Mocks - A library to mock things for testing

=head1 API

=head2 Methods

=cut

my %configs;

=head3 mock_config

    t::lib::Mocks::mock_config( $config_entry, $value );

Mock the configuration I<$config_entry> with the specified I<$value>.

NOTE: We are only mocking config entries here, so no entries from other
sections of koha-conf.xml. Bug 33718 fixed the section parameter of
mocked Koha::Config->get calls for other sections (not cached).

=cut

sub mock_config {
    my ( $config_entry, $value ) = @_;
    my $koha_config = Test::MockModule->new('Koha::Config');
    $configs{$config_entry} = $value;
    $koha_config->mock('get', sub {
        my ( $self, $key, $section ) = @_;
        $section ||= 'config';
        if( $section eq 'config' && exists $configs{$key} ) {
            return $configs{$key};
        }
        my $method = $koha_config->original('get');
        return $method->( $self, $key, $section );
    });
}

my %preferences;

=head3 mock_preference

    t::lib::Mocks::mock_preference( $preference, $value );

Mock the I<$preference> with the specified I<value>.

=cut

sub mock_preference {
    my ( $pref, $value ) = @_;

    $preferences{lc($pref)} = $value;

    my $context = Test::MockModule->new('C4::Context');
    $context->mock('preference', sub {
        my ( $self, $pref ) = @_;
        $pref = lc($pref);
        if ( exists $preferences{$pref} ) {
            return $preferences{$pref}
        } else {
            my $method = $context->original('preference');
            return $method->($self, $pref);
        }
    });
}

=head3 mock_userenv

    t::lib::Mocks::mock_userenv(
        {
          [ patron         => $patron,
            borrowernumber => $borrowernumber,
            userid         => $userid,
            cardnumber     => $cardnumber,
            firstname      => $firstname,
            surname        => $surname,
            branchcode     => $branchcode,
            branchname     => $branchname,
            flags          => $flags,
            emailaddress   => $emailaddress,
            desk_id        => $desk_id,
            desk_name      => $desk_name,
            register_id    => $register_id,
            register_name  => $register_name, ]
        }
    );

Mock userenv in the context of tests. A I<patron> param is usually expected, but
some other session attributes might be passed as well, that will override the patron's.

Also, some sane defaults are set if no parameters are passed.

=cut

sub mock_userenv {
    my ( $params ) = @_;

    C4::Context->_new_userenv(42);

    my $userenv;
    if ( $params and my $patron = $params->{patron} ) {
        $userenv = $patron->unblessed;
        $userenv->{branchcode} = $params->{branchcode} || $patron->library->branchcode;
        $userenv->{branchname} = $params->{branchname} || $patron->library->branchname;
    }
    my $usernum    = $params->{borrowernumber} || $userenv->{borrowernumber} || 51;
    my $userid     = $params->{userid}         || $userenv->{userid}         || 'userid4tests';
    my $cardnumber = $params->{cardnumber}     || $userenv->{cardnumber};
    my $firstname  = $params->{firstname}      || $userenv->{firstname}      || 'firstname';
    my $surname    = $params->{surname}        || $userenv->{surname}        || 'surname';
    my $branchcode = $params->{branchcode}     || $userenv->{branchcode}     || 'Branch4T';
    my $branchname   = $params->{branchname}   || $userenv->{branchname};
    my $flags        = $params->{flags}        || $userenv->{flags}          || 0;
    my $emailaddress = $params->{emailaddress} || $userenv->{email};
    my $desk_id       = $params->{desk_id}       || $userenv->{desk_id};
    my $desk_name     = $params->{desk_name}     || $userenv->{desk_name};
    my $register_id   = $params->{register_id}   || $userenv->{register_id};
    my $register_name = $params->{register_name} || $userenv->{register_name};
    my ( $shibboleth );

    C4::Context->set_userenv(
        $usernum,      $userid,     $cardnumber, $firstname,
        $surname,      $branchcode, $branchname, $flags,
        $emailaddress, $shibboleth, $desk_id,    $desk_name,
        $register_id,  $register_name
    );
}

1;
