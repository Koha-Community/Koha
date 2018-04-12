package Koha::Template::Plugin::Asset;

# Copyright 2018 BibLibre
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Template::Plugin;
use base qw( Template::Plugin );

use File::Basename;
use File::Spec;
use C4::Context;

sub new {
    my ($class, $context) = @_;

    my $self = {
        _CONTEXT => $context,
    };

    return bless $self, $class;
}

sub js {
    my ( $self, $filename, $attributes ) = @_;

    my $url = $self->url($filename);
    unless ($url) {
        warn "File not found : $filename";
        return;
    }

    $attributes->{src} = $url;

    return $self->tag('script', $attributes) . '</script>';
}

sub css {
    my ( $self, $filename, $attributes ) = @_;

    my $url = $self->url($filename);
    unless ($url) {
        warn "File not found : $filename";
        return;
    }

    $attributes->{rel} = 'stylesheet';
    $attributes->{type} = 'text/css';
    $attributes->{href} = $url;

    return $self->tag('link', $attributes);
}

sub url {
    my ( $self, $filename ) = @_;

    my $stash = $self->{_CONTEXT}->stash();
    my $interface = $stash->get('interface');
    my $theme = $stash->get('theme');

    my $configkey = $interface =~ /opac/ ? 'opachtdocs' : 'intrahtdocs';
    my $root = C4::Context->config($configkey);

    my ($basename, $dirname, $suffix) = fileparse($filename, qr/\.[^.]*/);

    my $type = substr $suffix, 1;
    my @dirs = (
        "$theme",
        ".",
    );

    my $version = C4::Context->preference('Version');
    foreach my $dir (@dirs) {
        my $abspath = File::Spec->catfile($root, $dir, $filename);
        if (-e $abspath) {
            return File::Spec->catfile($interface, $dir, $dirname, "${basename}_${version}${suffix}");
        }
    }
}

sub tag {
    my ($self, $name, $attributes) = @_;

    my @attributes_strs;
    if ($attributes) {
        while (my ($key, $value) = each %$attributes) {
            push @attributes_strs, qq{$key="$value"};
        }
    }
    my $attributes_str = join ' ', @attributes_strs;

    return "<$name $attributes_str>";
}

1;
