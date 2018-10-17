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
    qr{^\s*LAST},
);

sub fix_filters {
    return _process_tt_content( @_ )->{new_content};
}

sub missing_filters {
    return @{_process_tt_content( @_ )->{errors}};

}

sub _process_tt_content {
    my ($content) = @_;
    my ( $use_raw, $has_use_raw );
    my @errors;
    my @new_lines;
    my $line_number;
    for my $line ( split "\n", $content ) {
        my $new_line = $line;
        $line_number++;
        if ( $line =~ m{\[%[^%]+%\]} ) {

            # handle exceptions first
            if ( $line =~ m{\|\s*\$raw} ) {    # Is the file use the raw filter?
                $use_raw = 1;
            }

            # Do we have Asset without the raw filter?
            if ( $line =~ m{^\s*\[% Asset} && $line !~ m{\|\s*\$raw} ) {
                push @errors,
                  {
                    error       => 'asset_must_be_raw',
                    line        => $line,
                    line_number => $line_number
                  };
                $new_line =~ s/\)\s*%]/) | \$raw %]/;
                $use_raw = 1;
                push @new_lines, $new_line;
                next;
            }

            $has_use_raw++
              if $line =~ m{\[%(\s|-|~)*USE raw(\s|-|~)*%\]};    # Does [% Use raw %] exist?

            my $e;
            if ( $line =~ qr{<a href="([^"]+)} ) {
                my $to_uri_escape = $1;
                while (
                    $to_uri_escape =~ m{
                        \[%
                        (?<pre_chomp>(\s|\-|~)*)
                        (?<tt_block>[^%\-~]+)
                        (?<post_chomp>(\s|\-|~)*)
                        %\]}gmxs
                  )
                {
                    ( $new_line, $e ) = process_tt_block($new_line, { %+, filter => 'uri' });
                    push @errors, { line => $line, line_number => $line_number, error => $e } if $e;
                }
            }

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
                ( $new_line, $e ) = process_tt_block($new_line, \%+);
                push @errors, { line => $line, line_number => $line_number, error => $e } if $e;
            }

            push @new_lines, $new_line;
        }
        else {
            push @new_lines, $new_line;
        }

    }

    # Adding [% USE raw %] on top if the filter is used
    @new_lines = ( '[% USE raw %]', @new_lines )
      if $use_raw and not $has_use_raw;

    my $new_content = join "\n", @new_lines;
    return { errors => \@errors, new_content => $new_content };
}

sub process_tt_block {
    my ( $line, $params ) = @_;
    my $tt_block   = $params->{tt_block};
    my $pre_chomp  = $params->{pre_chomp};
    my $post_chomp = $params->{post_chomp};
    my $filter     = $params->{filter} || 'html';
    my $error;

    return ( $line, $error ) if
        # It's a TT directive, no filters needed
        grep { $tt_block =~ $_ } @tt_directives

        # It is a comment
        or $tt_block =~ m{^\#}

        # Already escaped with a special filter
        # We could escape it but should be safe
        or $tt_block =~ m{\s?\|\s?\$KohaDates\s?$}
        or $tt_block =~ m{\s?\|\s?\$Price\s?$}

        # Already escaped correctly with raw
        or $tt_block =~ m{\|\s?\$raw}

        # Assignment, maybe we should require to use SET (?)
        or $tt_block =~ m{=}

        # Already has url or uri filter
        or $tt_block =~ m{\|\s?ur(l|i)}

        # Specific for [% foo UNLESS bar %]
        or $tt_block =~ m{^(?<before>\S+)\s+UNLESS\s+(?<after>\S+)}
    ;

    $pre_chomp =
        $pre_chomp
      ? $pre_chomp =~ m|-|
          ? q|- |
          : $pre_chomp =~ m|~|
            ? q|~ |
            : q| |
      : q| |;
    $post_chomp =
        $post_chomp
      ? $post_chomp =~ m|-|
          ? q| -|
          : $post_chomp =~ m|~|
            ? q| ~|
            : q| |
      : q| |;

    if (
        # Use the uri filter is needed
        # If html filtered or not filtered
        $filter ne 'html'
            and (
                    $tt_block !~ m{\|}
                or  $tt_block =~ m{\|\s?html}
                or $tt_block !~ m{\s*|\s*(uri|url)}
      )
    ) {
        $tt_block =~ s/^\s*|\s*$//g;    # trim
        $tt_block =~ s/\s*\|\s*html\s*//;
        $line =~ s{
                \[%
                \s*$pre_chomp\s*
                \Q$tt_block\E(\s*\|\s*html)?
                \s*$post_chomp\s*
                %\]
            }{[%$pre_chomp$tt_block | uri$post_chomp%]}xms;

        $error = 'wrong_html_filter';
    }
    elsif (
        $tt_block !~ m{\|\s?html} # already has html filter
      )
    {
        $tt_block =~ s/^\s*|\s*$//g; # trim
        $line =~ s{
            \[%
            \s*$pre_chomp\s*
            \Q$tt_block\E
            \s*$post_chomp\s*
            %\]
        }{[%$pre_chomp$tt_block | html$post_chomp%]}xms;

        $error = 'missing_filter';
    }
    return ( $line, $error );
}

1;

=head1 NAME

t::lib::QA::TemplateFilters - Module used by tests and QA script to catch missing filters in template files

=head1 SYNOPSIS

    my $content = read_file($filename);
    my $new_content = t::lib::QA::TemplateFilters::fix_filters($content);
    my $errors      = t::lib::QA::TemplateFilters::missing_filters($content);

=head1 DESCRIPTION

The goal of this module is to make the subroutine reusable from the QA scripts
and to not duplicate the code.

=head1 METHODS

=head2 fix_filters

    Take a template content file in parameter and return the same content with
    the correct (guessed) filters.
    It will also add the [% USE raw %] statement if it is needed.

=head2 missing_filters

    Take a template content file in parameter and return an arrayref of errors.

    An error is a hashref with 3 keys, error and line, line_number.
    * error can be:
    asset_must_be_raw - When Asset is called without using raw
    missing_filter    - When a TT variable is displayed without filter
    wrong_html_filter - When a TT variable is using the html filter when uri (or url)
                        should be used instead.

    * line is the line where the error has been found.
    * line_number is the line number where the error has been found.


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
