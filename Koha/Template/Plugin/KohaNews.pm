package Koha::Template::Plugin::KohaNews;

# Copyright ByWater Solutions 2012
# Copyright BibLibre 2014
# Parts copyright Athens County Public Libraries 2019

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

use C4::Koha;
use C4::Context;
use Koha::News;

sub get {
    my ( $self, $params ) = @_;

    my $display_location = $params->{location};
    my $blocktitle = $params->{blocktitle};
    my $lang = $params->{lang};
    my $library = $params->{library};
    my $news_lang;

    if( !$display_location ){
        $news_lang = $lang;
    } else {
        $news_lang = $display_location."_".$lang;
    }

    my $search_params;
    $search_params->{lang} = $news_lang;
    $search_params->{branchcode} = [ $library, undef ] if $library;
    $search_params->{-or} = [ expirationdate => { '>=' => \'NOW()' },
                              expirationdate => undef ];
    my $content = Koha::News->search(
        $search_params,
        {
            order_by => 'number'
        });

    if( @$content ){
        return {
            content => $content,
            location => $display_location,
            blocktitle => $blocktitle
        };
    } else {
        return;
    }
}

1;

=head1 NAME

Koha::Template::Plugin::KohaNews - TT Plugin for displaying Koha news

=head1 SYNOPSIS

[% USE KohaNews %]

[% KohaNews.get() %]

=head1 ROUTINES

=head2 get

In a template, you can get the all categories with
the following TT code: [% KohaNews.get() %]

=head1 AUTHOR

Owen Leonard <oleonard@myacpl.org>

=cut
