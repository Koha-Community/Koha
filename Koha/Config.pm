package Koha::Config;

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

=head1 NAME

Koha::Config - Read Koha configuration file

=head1 SYNOPSIS

    use Koha::Config;

    my $config = Koha::Config->get_instance;
    my $database = $config->get('database');
    my $serverinfo = $config->get('biblioserver', 'serverinfo');

    my $otherconfig = Koha::Config->get_instance('/path/to/other/koha-conf.xml');

=head1 DESCRIPTION

Koha::Config is a helper module for reading configuration variables from the
main Koha configuration file ($KOHA_CONF)

=cut

use Modern::Perl;

use XML::LibXML qw( XML_ELEMENT_NODE XML_TEXT_NODE );

# Default config file, if none is specified
use constant CONFIG_FNAME => "/etc/koha/koha-conf.xml";

# path to config file set by installer
# __KOHA_CONF_DIR__ is set by rewrite-confg.PL
# when Koha is installed in 'standard' or 'single'
# mode.  If Koha was installed in 'dev' mode,
# __KOHA_CONF_DIR__ is *not* rewritten; instead
# developers should set the KOHA_CONF environment variable
my $INSTALLED_CONFIG_FNAME = '__KOHA_CONF_DIR__/koha-conf.xml';

=head1 CLASS METHODS

=head2 get_instance

    $config = Koha::Config->get_instance;
    $config = Koha::Config->get_instance($file);

Reads C<$file> and returns the corresponding C<Koha::Config> object.

If C<$file> is not given (or undef) it defaults to the result of
C<Koha::Config-E<gt>guess_koha_conf>.

Multiple calls with the same arguments will return the same object, and the
file will be read only the first time.

=cut

our %configs;

sub get_instance {
    my ( $class, $file ) = @_;

    $file //= $class->guess_koha_conf;

    unless ( exists $configs{$file} ) {
        $configs{$file} = $class->read_from_file($file);
    }

    return $configs{$file};
}

=head2 read_from_file

    $config = Koha::Config->read_from_file($file);

Reads C<$file> and returns the corresponding C<Koha::Config> object.

Unlike C<get_instance>, this method will read the file at every call, so use it
carefully. In most cases, you should use C<get_instance> instead.

=cut

sub read_from_file {
    my ( $class, $file ) = @_;

    return if not defined $file;

    my $config = {};
    eval {
        my $dom = XML::LibXML->load_xml( location => $file );
        foreach my $childNode ( $dom->documentElement->nonBlankChildNodes ) {
            $class->_read_from_dom_node( $childNode, $config );
        }
    };

    if ($@) {
        die
            "\nError reading file $file.\nTry running this again as the koha instance user (or use the koha-shell command in debian)\n\n";
    }

    return bless $config, $class;
}

=head2 guess_koha_conf

    $file = Koha::Config->guess_koha_conf;

Returns the path to Koha main configuration file.

Koha's main configuration file koha-conf.xml is searched for according to this
priority list:

=over

=item 1. Path supplied via use C4::Context '/path/to/koha-conf.xml'

=item 2. Path supplied in KOHA_CONF environment variable.

=item 3. Path supplied in INSTALLED_CONFIG_FNAME, as long as value has changed
from its default of '__KOHA_CONF_DIR__/koha-conf.xml', as happens when Koha is
installed in 'standard' or 'single' mode.

=item 4. Path supplied in CONFIG_FNAME.

=back

The first entry that refers to a readable file is used.

=cut

sub guess_koha_conf {

    # If the $KOHA_CONF environment variable is set, use
    # that. Otherwise, use the built-in default.
    my $conf_fname;
    if ( exists $ENV{"KOHA_CONF"} and $ENV{'KOHA_CONF'} and -s $ENV{"KOHA_CONF"} ) {
        $conf_fname = $ENV{"KOHA_CONF"};
    } elsif ( $INSTALLED_CONFIG_FNAME !~ /__KOHA_CONF_DIR/ and -s $INSTALLED_CONFIG_FNAME ) {

        # NOTE: be careful -- don't change __KOHA_CONF_DIR in the above
        # regex to anything else -- don't want installer to rewrite it
        $conf_fname = $INSTALLED_CONFIG_FNAME;
    } elsif ( -s CONFIG_FNAME ) {
        $conf_fname = CONFIG_FNAME;
    }
    return $conf_fname;
}

=head1 INSTANCE METHODS

=head2 get

    $value = $config->get($key);
    $value = $config->get($key, $section);

Returns the configuration entry corresponding to C<$key> and C<$section>.
The returned value can be a string, an arrayref or a hashref.
If C<$key> is not found, it returns undef.

C<$section> can be one of 'listen', 'server', 'serverinfo', 'config'.
If not given, C<$section> defaults to 'config'.

=cut

sub get {
    my ( $self, $key, $section ) = @_;

    $section //= 'config';

    my $value;
    if ( exists $self->{$section} and exists $self->{$section}->{$key} ) {
        $value = $self->{$section}->{$key};
    }

    return $value;
}

=head2 timezone

  $timezone = $config->timezone

  Returns the configured timezone. If not configured or invalid, it returns
  'local'.

=cut

sub timezone {
    my ($self) = @_;

    my $timezone = $self->get('timezone') || $ENV{TZ};
    if ($timezone) {
        require DateTime::TimeZone;
        if ( !DateTime::TimeZone->is_valid_name($timezone) ) {
            warn "Invalid timezone in koha-conf.xml ($timezone)";
            $timezone = 'local';
        }
    } else {
        $timezone = 'local';
    }

    return $timezone;
}

sub _read_from_dom_node {
    my ( $class, $node, $config ) = @_;

    if ( $node->nodeType == XML_TEXT_NODE ) {
        $config->{content} = $node->textContent;
    } elsif ( $node->nodeType == XML_ELEMENT_NODE ) {
        my $subconfig = {};

        foreach my $attribute ( $node->attributes ) {
            my $key   = $attribute->nodeName;
            my $value = $attribute->value;
            $subconfig->{$key} = $value;
        }

        foreach my $childNode ( $node->nonBlankChildNodes ) {
            $class->_read_from_dom_node( $childNode, $subconfig );
        }

        my $key = $node->nodeName;
        if ( $node->hasAttribute('id') ) {
            my $id = $node->getAttribute('id');
            $config->{$key} //= {};
            $config->{$key}->{$id} = $subconfig;
            delete $subconfig->{id};
        } else {
            my @keys = keys %$subconfig;
            if ( !$node->hasAttributes() && 1 == scalar @keys && $keys[0] eq 'content' ) {

                # An element with no attributes and no child elements becomes its text content
                $subconfig = $subconfig->{content};
            } elsif ( 0 == scalar @keys ) {

                # An empty element becomes an empty string
                $subconfig = '';
            }

            if ( exists $config->{$key} ) {
                unless ( ref $config->{$key} eq 'ARRAY' ) {
                    $config->{$key} = [ $config->{$key} ];
                }
                push @{ $config->{$key} }, $subconfig;
            } else {
                if ( grep { $_ eq $key } (qw(listen server serverinfo)) ) {

                    # <listen>, <server> and <serverinfo> are always arrays
                    $config->{$key} = [$subconfig];
                } else {
                    $config->{$key} = $subconfig;
                }
            }
        }
    }
}

1;
