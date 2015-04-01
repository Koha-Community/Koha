package Koha::FrameworkPlugin;

# Copyright 2014 Rijksmuseum
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

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

use base qw(Class::Accessor);

use C4::Context;
use C4::Biblio qw/GetMarcFromKohaField/;

__PACKAGE__->mk_ro_accessors( qw|
    name path errstr javascript noclick
|);

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
    if( ref($params) eq 'HASH' ) {
        foreach( 'name', 'path', 'item_style' ) {
            $self->{$_} = $params->{$_};
        }
    }
    elsif( !ref($params) && $params ) { # use it as plugin name
        $self->{name} = $params;
        if( $params =~ /^(.*)\/([^\/]+)$/ ) {
            $self->{name} = $2;
            $self->{path} = $1;
        }
    }
    $self->_error( 'Plugin needs a name' ) if !$self->{name};
    return $self;
}

=head2 build

    Generate html and javascript by calling the builder sub of the plugin.

    Params is a hashref supporting keys: id (=html id for the input field),
    record (MARC record or undef), dbh (database handle), tagslib, tabloop.
    Note that some of these parameters are not used in most (if not all)
    plugins and may be obsoleted in the future (kept for now to provide
    backward compatibility).
    The most important one is id; it is used to construct unique javascript
    function names.

    Returns success or failure.

=cut

sub build {
    my ( $self, $params ) = @_;
    return if $self->{errstr};
    return 1 if exists $self->{html}; # no rebuild

    $self->_load if !$self->{_loaded};
    return if $self->{errstr}; # load had error
    return $self->_generate_js( $params );
}

=head2 launch

    Launches the popup for this plugin by calling its launcher sub
    Old style plugins still expect to receive a CGI oject, new style
    plugins expect a params hashref.
    Returns undef on failure, otherwise launcher return value (if any).

=cut

sub launch {
    my ( $self, $params ) = @_;
    return if $self->{errstr};

    $self->_load if !$self->{_loaded};
    return if $self->{errstr}; # load had error
    return 1 if !exists $self->{launcher}; #just ignore this request
    if( defined( &{$self->{launcher}} ) ) {
        my $arg= $self->{oldschool}? $params->{cgi}: $params;
        return &{$self->{launcher}}( $arg );
    }
    return $self->_error( 'No launcher sub defined' );
}

# **************  INTERNAL ROUTINES ********************************************

sub _error {
    my ( $self, $info ) = @_;
    $self->{errstr} = 'ERROR: Plugin '. ( $self->{name}//'' ). ': '. $info;
    return; #always return false
}

sub _load {
    my ( $self ) = @_;

    my ( $rv, $file );
    return $self->_error( 'Plugin needs a name' ) if !$self->{name}; #2chk
    $self->{path} //= _valuebuilderpath();
    $file= $self->{path}. '/'. $self->{name};
    return $self->_error( 'File not found' ) if !-e $file;

    # undefine oldschool subroutines before defining them again
    undef &plugin_parameters;
    undef &plugin_javascript;
    undef &plugin;

    $rv = do( $file );
    return $self->_error( $@ ) if $@;

    my $type = ref( $rv );
    if( $type eq 'HASH' ) { # new style
        $self->{oldschool} = 0;
        if( exists $rv->{builder} && ref($rv->{builder}) eq 'CODE' ) {
            $self->{builder} = $rv->{builder};
        } elsif( exists $rv->{builder} ) {
            return $self->_error( 'Builder sub is no coderef' );
        }
        if( exists $rv->{launcher} && ref($rv->{launcher}) eq 'CODE' ) {
            $self->{launcher} = $rv->{launcher};
        } elsif( exists $rv->{launcher} ) {
            return $self->_error( 'Launcher sub is no coderef' );
        }
    } else { # old school
        $self->{oldschool} = 1;
        if( defined(&plugin_javascript) ) {
            $self->{builder} = \&plugin_javascript;
        }
        if( defined(&plugin) ) {
            $self->{launcher} = \&plugin;
        }
    }
    if( !$self->{builder} && !$self->{launcher} ) {
        return $self->_error( 'Plugin does not contain builder nor launcher' );
    }
    $self->{_loaded} = $self->{oldschool}? 0: 1;
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

    if( !defined(&$sub) ) { # 2chk: if there is something, it should be code
        return $self->_error( 'Builder sub not defined' );
    }

    my @params = $self->{oldschool}//0 ?
        ( $params->{dbh}, $params->{record}, $params->{tagslib},
            $params->{id}, $params->{tabloop} ):
        ( $params );
    my @rv = &$sub( @params );
    return $self->_error( 'Builder sub failed: ' . $@ ) if $@;

    my $arg= $self->{oldschool}? pop @rv: shift @rv;
        #oldschool returns functionname and script; we only use the latter
    if( $arg && $arg=~/^\s*\<script/ ) {
        $self->_process_javascript( $params, $arg );
        return 1; #so far, so good
    }
    return $self->_error( 'Builder sub returned bad value(s)' );
}

sub _process_javascript {
    my ( $self, $params, $script ) = @_;

    #remove the script tags; we add them again later
    $script =~ s/\<script[^>]*\>\s*(\/\/\<!\[CDATA\[)?\s*//s;
    $script =~ s/(\/\/\]\]\>\s*)?\<\/script\>//s;

    my $id = $params->{id}//'';
    my $bind = '';
    my $clickfound = 0;
    my @events = qw|click focus blur change mouseover mouseout mousedown
        mouseup mousemove keydown keypress keyup|;
    foreach my $ev ( @events ) {
        my $scan = $ev eq 'click' && $self->{oldschool}? 'clic': $ev;
        if( $script =~ /function\s+($scan\w+)\s*\(([^\)]*)\)/is ) {
            my ( $bl, $sl ) = $self->_add_binding( $1, $2, $ev, $id );
            $script .= $sl;
            $bind .= $bl;
            $clickfound = 1 if $ev eq 'click';
        }
    }
    if( !$clickfound ) { # make buttonDot do nothing
        my ( $bl ) = $self->_add_binding( 'noclick', '', 'click', $id );
        $bind .= $bl;
    }
    $self->{noclick} = !$clickfound;
    $self->{javascript}= _merge_script( $id, $script, $bind );
}

sub _add_binding {
# adds some jQuery code for event binding:
# $bind contains lines for the actual event binding: .click, .focus, etc.
# $script contains function definitions (if needed)
    my ( $self, $fname, $pars, $ev, $id ) = @_;
    my ( $bind, $script );
    my $ctl= $ev eq 'click'? 'buttonDot_'.$id: $id;
        #click event applies to buttonDot

    if( $pars =~ /^(e|ev|event)$/i ) { # new style event handler assumed
        $bind= qq|    \$("#$ctl").$ev(\{id: '$id'\}, $fname);\n|;
        $script='';
    } elsif( $fname eq 'noclick' ) { # no click: return false, no scroll
        $bind= qq|    \$("#$ctl").$ev(function () { return false; });\n|;
        $script='';
    } else { # add real event handler calling the function found
        $bind=qq|    \$("#$ctl").$ev(\{id: '$id'\}, ${fname}_handler);\n|;
        $script = $self->_add_handler( $ev, $fname );
    }
    return ( $bind, $script );
}

sub _add_handler {
# adds a handler with event parameter
# event.data.id is passed to the plugin function in parameters
# for the click event we always return false to prevent scrolling
    my ( $self, $ev, $fname ) = @_;
    my $first= $self->_first_item_par( $ev );
    my $prefix= $ev eq 'click'? '': 'return ';
    my $suffix= $ev eq 'click'? "\n    return false;": '';
    return <<HERE;
function ${fname}_handler(event) {
    $prefix$fname(${first}event.data.id);$suffix
}
HERE
}

sub _first_item_par {
    my ( $self, $event ) = @_;
    # needed for backward compatibility
    # js event functions in old style item plugins have an extra parameter
    # BUT.. not for all events (exceptions provide employment :)
    if( $self->{item_style} && $self->{oldschool} &&
            $event=~/focus|blur|change/ ) {
        return qq/'0',/;
    }
    return '';
}

sub _merge_script {
# Combine script and event bindings, enclosed in script tags.
# The BindEvents function is added to easily repeat event binding;
# this is used in additem.js for dynamically created item blocks.
    my ( $id, $script, $bind ) = @_;
    chomp ($script, $bind);
    return <<HERE;
<script type="text/javascript">
//<![CDATA[
$script
function BindEvents$id() {
$bind
}
\$(document).ready(function() {
    BindEvents$id();
});
//]]>
</script>
HERE
}

=head1 AUTHOR

    Marcel de Rooy, Rijksmuseum Amsterdam, The Netherlands

=cut

1;
