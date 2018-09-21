package t::lib::QA::TemplateFilters;

use Modern::Perl;

our @tt_directives = (
    qr{^\s*INCLUDE},
    qr{^\s*USE},
    qr{^\s*IF},
    qr{^\s*UNLESS},
    qr{^\s*ELSE},
    qr{^\s*ELSIF},
    qr{^\s*END},
    qr{^\s*SET},
    qr{^\s*FOR},
    qr{^\s*FOREACH},
    qr{^\s*MACRO},
    qr{^\s*SWITCH},
    qr{^\s*CASE},
    qr{^\s*PROCESS},
    qr{^\s*DEFAULT},
    qr{^\s*TRY},
    qr{^\s*CATCH},
    qr{^\s*BLOCK},
    qr{^\s*FILTER},
    qr{^\s*STOP},
    qr{^\s*NEXT},
);

sub missing_filters {
    my ($content) = @_;
    my ( $use_raw, $has_use_raw );
    my @errors;
    my $line_number;
    for my $line ( split "\n", $content ) {
        $line_number++;
        if ( $line =~ m{\[%[^%]+%\]} ) {

            # handle exceptions first
            $use_raw = 1
              if $line =~ m{|\s*\$raw};    # Is the file use the raw filter?

            # Do we have Asset without the raw filter?
            if ( $line =~ m{^\s*\[% Asset} ) {
                push @errors, { error => 'asset_must_be_raw', line => $line, line_number => $line_number }
                  and next
                  unless $line =~ m{\|\s*\$raw};
            }

            $has_use_raw++
              if $line =~ m{\[% USE raw %\]};    # Does [% Use raw %] exist?

            # Loop on TT blocks
            while (
                $line =~ m{
                    \[%
                    (?<pre_chomp>(\s|\-|~)*)
                    (?<tt_block>[^%\-~]+)
                    (?<post_chomp>(\s|\-|~)*)
                    %\]}gmxs
              )
            {
                my $tt_block = $+{tt_block};

                # It's a TT directive, no filters needed
                next if grep { $tt_block =~ $_ } @tt_directives;

                next
                  if $tt_block =~ m{\s?\|\s?\$KohaDates\s?$}
                  ;    # We could escape it but should be safe
                next if $tt_block =~ m{^\#};    # Is a comment, skip it

                push @errors, { error => 'missing_filter', line => $line, line_number => $line_number }
                  if $tt_block !~ m{\|\s?\$raw}   # already escaped correctly with raw
                  && $tt_block !~ m{=}            # assignment, maybe we should require to use SET (?)
                  && $tt_block !~ m{\|\s?ur(l|i)} # already has url or uri filter
                  && $tt_block !~ m{\|\s?html}    # already has html filter
                  && $tt_block !~ m{^(?<before>\S+)\s+UNLESS\s+(?<after>\S+)} # Specific for [% foo UNLESS bar %]
                ;
            }
        }
    }

    return @errors;
}

1;

=head1 NAME

t::lib::QA::TemplateFilters - Module used by tests and QA script to catch missing filters in template files

=head1 SYNOPSIS

    my $content = read_file($filename);
    my @e = t::lib::QA::TemplateFilters::missing_filters($content);

=head1 DESCRIPTION

The goal of this module is to make the subroutine reusable from the QA scripts
and to not duplicate the code.

=head1 METHODS

=head2 missing_filters

    Take a template content file in parameter and return an array of errors.
    An error is a hashref with 2 keys, error and line.
    * error can be:
    asset_must_be_raw - When Asset is called without using raw
    missing_filter    - When a TT variable is displayed without filter

    * line is the line where the error has been found.

=head1 AUTHORS

Jonathan Druart <jonathan.druart@bugs.koha-community.org>

=head1 COPYRIGHT

Copyright 2017 - Koha Development Team

=head1 LICENSE

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

Koha is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Koha; if not, see <http://www.gnu.org/licenses>.

=cut

1;
