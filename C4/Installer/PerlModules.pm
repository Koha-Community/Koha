package C4::Installer::PerlModules;

use warnings;
use strict;

use File::Basename qw( dirname );
use Module::CPANfile;

sub new {
    my $invocant = shift;
    my $self     = {
        missing_pm => [],
        upgrade_pm => [],
        current_pm => [],
    };

    my $type = ref($invocant) || $invocant;
    bless( $self, $type );
    return $self;
}

sub prereqs {
    my $self = shift;

    unless ( defined $self->{prereqs} ) {
        my $filename = $INC{'C4/Installer/PerlModules.pm'};
        my $path     = dirname( dirname( dirname($filename) ) );
        $self->{prereqs} = Module::CPANfile->load("$path/cpanfile")->prereqs;
    }

    return $self->{prereqs};
}

sub prereq_pm {
    my $self = shift;

    my $prereq_pm = {};
    my $reqs      = $self->prereqs->merged_requirements;
    foreach my $module ( $reqs->required_modules ) {
        $prereq_pm->{$module} = $reqs->requirements_for_module($module);
    }

    return $prereq_pm;
}

sub versions_info {
    my $self = shift;

    #   Reset these arrayref each pass through to ensure current information
    $self->{'missing_pm'} = [];
    $self->{'upgrade_pm'} = [];
    $self->{'current_pm'} = [];

    foreach my $phase ( $self->prereqs->phases ) {
        foreach my $type ( $self->prereqs->types_in($phase) ) {
            my $reqs = $self->prereqs->requirements_for( $phase, $type );
            foreach my $module ( sort $reqs->required_modules ) {
                my $module_infos = {
                    cur_ver  => 0,
                    required => $type eq 'requires',
                };

                my $vers = $reqs->structured_requirements_for_module($module);
                for my $req (@$vers) {
                    if ( $req->[0] eq '>=' || $req->[0] eq '>' ) {
                        $module_infos->{min_ver} = $req->[1];
                    } elsif ( $req->[0] eq '<=' || $req->[0] eq '<' ) {
                        $module_infos->{max_ver} = $req->[1];
                    } else {
                        push @{ $module_infos->{exc_ver} }, $req->[1];
                    }
                }

                my $attr;
                {
                    # ignore warnings from noisy modules
                    local $SIG{__WARN__} = sub { };
                    eval "require $module";
                }
                if ($@) {
                    $attr = 'missing_pm';
                } else {
                    my $pkg_version = $module->can("VERSION") ? $module->VERSION : 0;
                    $module_infos->{cur_ver} = $pkg_version;
                    if ( $reqs->accepts_module( $module => $pkg_version ) ) {
                        $attr = 'current_pm';
                    } else {
                        $attr = 'upgrade_pm';
                    }
                }

                push @{ $self->{$attr} }, { $module => $module_infos };
            }
        }
    }
}

sub get_attr {
    return $_[0]->{ $_[1] };
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

=head2 prereqs

Missing POD for prereqs.

=head2 prereq_pm()

    Returns a hashref of a hash of module information suitable for use in Makefile.PL

    example:
        C<my $perl_modules = C4::Installer::PerlModules->new;

        ...

        PREREQ_PM    => $perl_modules->prereq_pm,>


=head2 versions_info

        C<$perl_modules->versions_info;>

        This loads info of required modules into three accessors: missing_pm,
        upgrade_pm, and current_pm. Each of these may be accessed by using the
        C<get_attr> method. Each accessor returns an anonymous array who's
        elements are anonymous hashes. They follow this format (NOTE: Upgrade
        status is indicated by the accessor name.):

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


=head1 AUTHOR

Chris Nighswonger <cnighswonger AT foundations DOT edu>

=head1 COPYRIGHT

Copyright 2010 Foundations Bible College.

=head1 LICENSE

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

Koha is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Koha; if not, see <http://www.gnu.org/licenses>.

=head1 DISCLAIMER OF WARRANTY

Koha is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

=cut
