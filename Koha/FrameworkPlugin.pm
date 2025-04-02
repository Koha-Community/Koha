package Koha::FrameworkPlugin;

# Copyright 2014 Rijksmuseum
# Copyright 2025 Biblibre, Koha development team
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

=head1 NAME

Koha::FrameworkPlugin - Facilitate use of plugins in MARC/items editor

=head1 SYNOPSIS

    use Koha::FrameworkPlugin;
    my $plugin = Koha::FrameworkPlugin({ name => 'EXAMPLE.pl' });
    $plugin->build( { id => $id });
    $template->param(
        javascript => $plugin->javascript,
        noclick => $plugin->noclick,
    );

    use Koha::FrameworkPlugin;
    my $plugin = Koha::FrameworkPlugin({ name => 'EXAMPLE.pl' });
    $plugin->launch( { cgi => $query });

=head1 DESCRIPTION

    A framework plugin provides additional functionality to a MARC or item
    field. It can be attached to a field in the framework structure.
    The functionality is twofold:
    - Additional actions on the field via javascript in the editor itself
      via events as onfocus, onblur, etc.
      Focus may e.g. fill an empty field, Blur or Change may validate.
    - Provide an additional form to edit the field value, possibly a
      combination of various subvalues. Look at e.g. MARC leader.
      The additional form is a popup on top of the MARC/items editor.

    The plugin code is a perl script (with template for the popup),
    essentially doing two things:
    1) Build: The plugin returns javascript to the caller (addbiblio.pl a.o.)
    2) Launch: The plugin launches the additional form (popup). Launching is
       centralized via the plugin_launcher.pl script.

    This object support two code styles:
    - In the new style, the plugin returns a hashref with a builder and a
      launcher key pointing to two anynomous subroutines.
    - In the old style, the builder is subroutine plugin_javascript and the
      launcher is subroutine plugin. For each plugin the routines are
      redefined.

    In cataloguing/value_builder/EXAMPLE.pl, you can find a detailed example
    of a new style plugin. As long as we support the old style plugins, the
    unit test t/db_dependent/FrameworkPlugin.t still contains an example
    of the old style too.

=head1 METHODS

=head2 new

    Create object (via Class::Accessor).

=head2 build

    Build uses the builder subroutine of the plugin to build javascript
    for the plugin.

=head2 launch

    Run the popup of the plugin, as defined by the launcher subroutine.

=head1 PROPERTIES

=head2 name

    Filename of the plugin.

=head2 path

    Optional pathname of the plugin.
    By default plugins are found in cataloguing/value_builder.

=head2 errstr

    Error message.
    If set, the plugin will no longer build or launch.

=head2 javascript

    Generated javascript for the caller of the plugin (after building).

=head2 noclick

    Tells you (after building) that this plugin has no action connected to
    to clicking on the buttonDot anchor. (Note that some item plugins
    redirect click to focus instead of launching a popup.)

=head1 ADDITIONAL COMMENTS

=cut

use Modern::Perl;
use Cwd qw//;

use base qw(Class::Accessor);

use C4::Context;

__PACKAGE__->mk_ro_accessors(
    qw|
        name path errstr javascript noclick
        |
);

=head2 new

    Returns new object based on Class::Accessor, loads additional params.
    The params hash currently supports keys: name, path, item_style.
    Name is mandatory. Path is used in unit testing.
    Item_style is used to identify old-style item plugins that still use
    an additional (irrelevant) first parameter in the javascript event
    functions.

=cut

sub new {
    my ( $class, $params ) = @_;
    my $self = $class->SUPER::new();
    if ( ref($params) eq 'HASH' ) {
        foreach ( 'name', 'path', 'item_style' ) {
            $self->{$_} = $params->{$_};
        }
    } elsif ( !ref($params) && $params ) {    # use it as plugin name
        $self->{name} = $params;
        if ( $params =~ /^(.*)\/([^\/]+)$/ ) {
            $self->{name} = $2;
            $self->{path} = $1;
        }
    }
    $self->_error('Plugin needs a name') if !$self->{name};
    return $self;
}

=head2 build

    Generate html and javascript by calling the builder sub of the plugin.

    Params is a hashref supporting keys: id (=html id for the input field),
    record (MARC record or undef), dbh (database handle), tagslib.
    Note that some of these parameters are not used in most (if not all)
    plugins and may be obsoleted in the future (kept for now to provide
    backward compatibility).
    The most important one is id; it is used to construct unique javascript
    function names.

    Returns success or failure.

=cut

sub build {
    my ( $self, $params ) = @_;
    return   if $self->{errstr};
    return 1 if exists $self->{html};    # no rebuild

    $self->_load if !$self->{_loaded};
    return       if $self->{errstr};     # load had error
    return $self->_generate_js($params);
}

=head2 launch

    Launches the popup for this plugin by calling its launcher sub
    Old style plugins still expect to receive a CGI object, new style
    plugins expect a params hashref.
    Returns undef on failure, otherwise launcher return value (if any).

=cut

sub launch {
    my ( $self, $params ) = @_;
    return if $self->{errstr};

    $self->_load if !$self->{_loaded};
    return       if $self->{errstr};              # load had error
    return 1     if !exists $self->{launcher};    #just ignore this request
    if ( defined( &{ $self->{launcher} } ) ) {
        my $arg = $self->{oldschool} ? $params->{cgi} : $params;
        return &{ $self->{launcher} }($arg);
    }
    return $self->_error('No launcher sub defined');
}

# **************  INTERNAL ROUTINES ********************************************

sub _error {
    my ( $self, $info ) = @_;
    $self->{errstr} = 'ERROR: Plugin ' . ( $self->{name} // '' ) . ': ' . $info;
    return;    #always return false
}

sub _load {
    my ($self) = @_;

    # Try to find the class that can handle this plugin
    my @plugins = Koha::Plugins->new()->get_valuebuilders_installed();

    foreach my $vb (@plugins) {
        my $plugin = $vb->{plugin};

        # Check if this plugin provides the value builder we need
        if ( $vb->{name} eq $self->{name} ) {

            # Store the plugin object for later use
            $self->{plugin} = $plugin;

            # Get the builder and launcher directly from the plugin object
            if ( $plugin->can('builder_code') ) {
                $self->{builder} = sub { return $plugin->builder_code(@_); };
            }

            if ( $plugin->can('launcher') ) {
                $self->{launcher} = sub { return $plugin->launcher(@_); };
            }

            if ( !$self->{builder} && !$self->{launcher} ) {
                return $self->_error('Plugin does not contain builder_code nor launcher methods');
            }

            $self->{_loaded} = 1;
            return 1;
        }
    }

    # If not found via plugin, try in standard dir
    my ( $rv, $file );
    return $self->_error('Plugin needs a name') if !$self->{name};    #2chk
    $self->{path} //= _valuebuilderpath();

    #NOTE: Resolve symlinks and relative path components if present,
    #so the base will compare correctly lower down
    my $abs_base_path = Cwd::abs_path( $self->{path} );
    $file = $self->{path} . '/' . $self->{name};

    #NOTE: Resolve relative path components to prevent loading files outside the base path
    my $abs_file_path = Cwd::abs_path($file);
    if ( $abs_file_path !~ /^\Q$abs_base_path\E/ ) {
        warn "Attempt to load $file ($abs_file_path) in framework plugin!";
        return $self->_error('File not found');
    }
    return $self->_error('File not found') if !-e $file;

    # undefine oldschool subroutines before defining them again
    undef &plugin_parameters;
    undef &plugin_javascript;
    undef &plugin;

    $rv = do($file);
    return $self->_error($@) if $@;

    my $type = ref($rv);
    if ( $type eq 'HASH' ) {    # new style
        $self->{oldschool} = 0;
        if ( exists $rv->{builder} && ref( $rv->{builder} ) eq 'CODE' ) {
            $self->{builder} = $rv->{builder};
        } elsif ( exists $rv->{builder} ) {
            return $self->_error('Builder sub is no coderef');
        }
        if ( exists $rv->{launcher} && ref( $rv->{launcher} ) eq 'CODE' ) {
            $self->{launcher} = $rv->{launcher};
        } elsif ( exists $rv->{launcher} ) {
            return $self->_error('Launcher sub is no coderef');
        }
    } else {                    # old school
        $self->{oldschool} = 1;
        if ( defined(&plugin_javascript) ) {
            $self->{builder} = \&plugin_javascript;
        }
        if ( defined(&plugin) ) {
            $self->{launcher} = \&plugin;
        }
    }
    if ( !$self->{builder} && !$self->{launcher} ) {
        return $self->_error('Plugin does not contain builder nor launcher');
    }
    $self->{_loaded} = $self->{oldschool} ? 0 : 1;

    # old style needs reload due to possible sub redefinition
    return 1;
}

sub _valuebuilderpath {
    return C4::Context->config('intranetdir') . "/cataloguing/value_builder";

    #Formerly, intranetdir/cgi-bin was tested first.
    #But the intranetdir from koha-conf already includes cgi-bin for
    #package installs, single and standard installs.
}

sub _generate_js {
    my ( $self, $params ) = @_;

    my $sub = $self->{builder};
    return 1 if !$sub;

    #it is safe to assume here that we do have a launcher
    #we assume that it is launched in an unorthodox fashion
    #just useless to build, but no problem

    if ( !defined(&$sub) ) {    # 2chk: if there is something, it should be code
        return $self->_error('Builder sub not defined');
    }

    # Make a copy of params and add the plugin object to it
    my $builder_params = {%$params};

    # Add the value builder's plugin if available
    if ( $self->{name} && $self->{plugin} ) {
        $builder_params->{plugin} = $self->{plugin};
    }

    my @params = $self->{oldschool} // 0
        ? (
        $params->{dbh}, $params->{record}, $params->{tagslib},
        $params->{id}
        )
        : ($builder_params);
    my @rv = &$sub(@params);
    return $self->_error( 'Builder sub failed: ' . $@ ) if $@;

    my $arg = $self->{oldschool} ? pop @rv : shift @rv;

    #oldschool returns functionname and script; we only use the latter
    if ( $arg && $arg =~ /^\s*\<script/ ) {
        $self->_process_javascript( $params, $arg );
        return 1;    #so far, so good
    }
    return $self->_error('Builder sub returned bad value(s)');
}

sub _process_javascript {
    my ( $self, $params, $script ) = @_;

    #remove the script tags; we add them again later
    $script =~ s/\<script[^>]*\>\s*(\/\/\<!\[CDATA\[)?\s*//s;
    $script =~ s/(\/\/\]\]\>\s*)?\<\/script\>//s;

    my $clickfound = 0;
    my @events     = qw|click focus blur change mousedown mouseup keydown keyup|;
    foreach my $ev (@events) {
        my $scan = $ev eq 'click' && $self->{oldschool} ? 'clic' : $ev;
        if ( $script =~ /function\s+($scan\w+)\s*\(/is ) {
            my $function_name = $1;
            $script .= sprintf( 'registerFrameworkPluginHandler("%s", "%s", %s);', $self->name, $ev, $function_name );
            $clickfound = 1 if $ev eq 'click';
        }
    }
    $self->{noclick}    = !$clickfound;
    $self->{javascript} = <<JS;
<script>
\$(document).ready(function () {
$script
});
</script>
JS
}

=head1 AUTHOR

    Marcel de Rooy, Rijksmuseum Amsterdam, The Netherlands
    Julian Maurice, Biblibre, France

=cut

1;
