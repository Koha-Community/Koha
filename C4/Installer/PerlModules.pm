package C4::Installer::PerlModules;

use warnings;
use strict;

use File::Spec;

use C4::Installer::PerlDependencies;


our $PERL_DEPS = $C4::Installer::PerlDependencies::PERL_DEPS;

sub new {
    my $invocant = shift;
    my $self = {
        missing_pm  => [],
        upgrade_pm  => [],
        current_pm  => [],
    };
    my $type = ref($invocant) || $invocant;
    bless ($self, $type);
    return $self;
}

sub prereq_pm {
    my $self = shift;
    my $prereq_pm = {};
    for (keys %$PERL_DEPS) {
        $prereq_pm->{$_} = $PERL_DEPS->{$_}->{'min_ver'};
    }
    return $prereq_pm;
}

sub required {
    my $self = shift;
    my %params = @_;
    if ($params{'module'}) {
        return -1 unless grep {m/$params{'module'}/} keys(%$PERL_DEPS);
        return $PERL_DEPS->{$params{'module'}}->{'required'};
    }
    elsif ($params{'required'}) {
        my $required_pm = [];
        for (keys %$PERL_DEPS) {
            push (@$required_pm, $_) if $PERL_DEPS->{$_}->{'required'} == 1;
        }
        return $required_pm;
    }
    elsif ($params{'optional'}) {
        my $optional_pm = [];
        for (keys %$PERL_DEPS) {
            push (@$optional_pm, $_) if $PERL_DEPS->{$_}->{'required'} == 0;
        }
        return $optional_pm;
    }
    else {
        return -1; # unrecognized parameter passed in
    }
}

sub versions_info {
    my $self = shift;

    #   Reset these arrayref each pass through to ensure current information
    $self->{'missing_pm'} = [];
    $self->{'upgrade_pm'} = [];
    $self->{'current_pm'} = [];

    for my $module ( sort keys %$PERL_DEPS ) {
        my $module_infos = $self->version_info($module);
        my $status       = $module_infos->{status};
        push @{ $self->{"${status}_pm"} }, { $module => $module_infos };
    }
}

sub version_info {
    no warnings
      ;  # perl throws warns for invalid $VERSION numbers which some modules use
    my ( $self, $module ) = @_;
    return -1 unless grep { /^$module$/ } keys(%$PERL_DEPS);

    $Readonly::XS::MAGIC_COOKIE="Do NOT use or require Readonly::XS unless you're me.";
    eval "require $module";
    my $pkg_version = $module->can("VERSION") ? $module->VERSION : 0;
    my $min_version = $PERL_DEPS->{$module}->{'min_ver'} // 0;

    my ( $cur_ver, $upgrade, $status );
    if ($@) {
        ( $cur_ver, $upgrade, $status ) = ( 0, 0, 'missing' );
    }
    elsif ( version->parse("$pkg_version") < version->parse("$min_version") ) {
        ( $cur_ver, $upgrade, $status ) = ( $module->VERSION, 1, 'upgrade' );
    }
    else {
        ( $cur_ver, $upgrade, $status ) = ( $module->VERSION, 0, 'current' );
    }

    return {
        cur_ver  => $cur_ver,
        min_ver  => $PERL_DEPS->{$module}->{min_ver},
        required => $PERL_DEPS->{$module}->{required},
        usage    => $PERL_DEPS->{$module}->{usage},
        upgrade  => $upgrade,
        status   => $status,
    };
}


sub get_attr {
    return $_[0]->{$_[1]};
}

sub module_count {
    return scalar(keys(%$PERL_DEPS));
}

sub module_list {
    return keys(%$PERL_DEPS);
}

1;
__END__

=head1 NAME

C4::Installer::PerlModules

=head1 ABSTRACT

A module for manipulating Koha Perl dependency list objects.

=head1 METHODS

=head2 new()

    Creates a new PerlModules object 

    example:
        C<my $perl_modules = C4::Installer::PerlModules->new;>

=head2 prereq_pm()

    Returns a hashref of a hash of module information suitable for use in Makefile.PL

    example:
        C<my $perl_modules = C4::Installer::PerlModules->new;

        ...

        PREREQ_PM    => $perl_modules->prereq_pm,>

=head2 required()

    This method accepts a single parameter with three possible values: a module name, the keyword 'required,' the keyword 'optional.' If passed the name of a module, a boolean value is returned indicating whether the module is required (1) or not (0). If on of the two keywords is passed in, it returns an arrayref to an array who's elements are the names of the modules specified either required or optional.

    example:
        C<my $is_required = $perl_modules->required(module => 'CGI::Carp');>

        C<my $optional_pm_names = $perl_modules->required(optional => 1);>

=head2 version_info()

    Depending on the parameters passed when invoking, this method will give the current status of modules currently used in Koha as well as the currently installed version if the module is installed, the current minimum required version, and the upgrade status. If passed C<module => module_name>, the method evaluates only that module. If passed C<all => 1>, all modules are evaluated.

    example:
        C<my $module_status = $perl_modules->version_info('foo');>

        This usage returns a hashref with a single key/value pair. The key is the module name. The value is an anonymous hash with the following keys:

        cur_ver = version number of the currently installed version (This is 0 if the module is not currently installed.)
        min_ver = minimum version required by Koha
        upgrade = upgrade status of the module relative to Koha's requirements (0 if the installed module does not need upgrading; 1 if it does)
        required = 0 of the module is optional; 1 if required

        {
           'required' => 1,
           'cur_ver' => '1.30_01',
           'upgrade' => 0,
           'min_ver' => '1.29'
        };

        C<$perl_modules->version_info;>

        This usage loads the same basic data as the previous usage into three accessors: missing_pm, upgrade_pm, and current_pm. Each of these may be accessed by using the C<get_attr> method. Each accessor returns an anonymous array who's elements are anonymous hashes. They follow this format (NOTE: Upgrade status is indicated by the accessor name.):

        [
                  {
                    'Text::CSV::Encoded' => {
                                              'required' => 1,
                                              'cur_ver' => 0.09,
                                              'min_ver' => '0.09'
                                            }
                  },
                  {
                    'Biblio::EndnoteStyle' => {
                                                'required' => 1,
                                                'cur_ver' => 0,
                                                'min_ver' => '0.05'
                                              }
                  },
        }

=head2 get_attr(attr_name)

    Returns an anonymous array containing the contents of the passed in accessor. Valid accessors are:

    missing_pm - Perl modules used by Koha but not currently installed.

    upgrade_pm - Perl modules currently installed but below the minimum version required by Koha.

    current_pm - Perl modules currently installed and up to date as required by Koha.

    example:
        C<my $missing_pm = $perl_modules->get_attr('missing_pm');>

=head2 module_count

    Returns a scalar value representing the current number of Perl modules used by Koha.

    example:
        C<my $module_count = $perl_modules->module_count;>

=head2 module_list

    Returns an array who's elements are the names of the Perl modules used by Koha.

    example:
        C<my @module_list = $perl_modules->module_list;>

    This is useful for commandline exercises such as:

        perl -MC4::Installer::PerlModules -e 'my $deps = C4::Installer::PerlModule->new; print (join("\n",$deps->module_list));'

=head1 AUTHOR

Chris Nighswonger <cnighswonger AT foundations DOT edu>

=head1 COPYRIGHT

Copyright 2010 Foundations Bible College.

=head1 LICENSE

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later version.

You should have received a copy of the GNU General Public License along with Koha; if not, write to the Free Software Foundation, Inc., 51 Franklin Street,
Fifth Floor, Boston, MA 02110-1301 USA.

=head1 DISCLAIMER OF WARRANTY

Koha is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

=cut
