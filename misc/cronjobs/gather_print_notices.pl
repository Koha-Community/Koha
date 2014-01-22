#!/usr/bin/perl -w

use Modern::Perl;

BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use
  CGI; # NOT a CGI script, this is just to keep C4::Templates::gettemplate happy
use C4::Context;
use C4::Dates;
use C4::Debug;
use C4::Letters;
use C4::Templates;
use File::Spec;
use Pod::Usage;
use Getopt::Long;
use C4::Log;

use Koha::DateUtils;

my ( $stylesheet, $help, $split, $html, $csv, @letter_codes );

GetOptions(
    'h|help'  => \$help,
    's|split' => \$split,
    'html'    => \$html,
    'csv'     => \$csv,
    'letter_code:s' => \@letter_codes,
) || pod2usage(1);

pod2usage(0) if $help;

my $output_directory = $ARGV[0];

if ( !$output_directory || !-d $output_directory || !-w $output_directory ) {
    pod2usage({
        -exitval => 1,
        -msg => qq{\nError: You must specify a valid and writeable directory to dump the print notices in.\n},
    });
}

# Default value is html
$html = 1 unless $html or $csv;

if ( $csv and @letter_codes != 1 ) {
    pod2usage({
        -exitval => 1,
        -msg => qq{\nIt is not consistent to use --csv without one (and only one) letter_code\n},
    });
}

cronlogaction();

my $today        = C4::Dates->new();
my @all_messages = @{ GetPrintMessages() };

# Filter by letter_code
@all_messages = map {
    my $letter_code = $_->{letter_code};
    (
        grep { /^$letter_code$/ } @letter_codes
    ) ? $_ : ()
} @all_messages;
exit unless @all_messages;

## carriage return replaced by <br/> as output is html
foreach my $message (@all_messages) {
    local $_ = $message->{'content'};
    s/\n/<br \/>/g;
    s/\r//g;
    $message->{'content'} = $_;
}

print_notices_html({ messages => \@all_messages, split => $split })
    if $html;

print_notices_csv({ messages => \@all_messages, split => $split })
    if $csv;

sub print_notices_html {
    my ( $params ) = @_;

    my $messages = $params->{messages};
    my $split = $params->{split};

    my $messages_by_branch;
    if ( $split ) {
        foreach my $message (@$messages) {
            push( @{ $messages_by_branch->{ $message->{'branchcode'} } }, $message );
        }
    } else {
        $messages_by_branch->{all_branches} = $messages;
    }

    while ( my ( $branchcode, $branch_messages ) = each %$messages_by_branch ) {
        my $filename = $split
            ? 'holdnotices-' . $today->output('iso') . "-$branchcode.html"
            : 'holdnotices-' . $today->output('iso') . ".html";

        my $template =
          C4::Templates::gettemplate( 'batch/print-notices.tt', 'intranet',
            new CGI );

        $template->param(
            stylesheet => C4::Context->preference("NoticeCSS"),
            today      => $today->output(),
            messages   => $branch_messages,
        );

        my $output_file = File::Spec->catdir( $output_directory, $filename )
        open my $OUTPUT, '>', $output_file
            or die "Could not open $output_file: $!";
        print $OUTPUT $template->output;
        close $OUTPUT;

        foreach my $message ( @$branch_messages ) {
            C4::Letters::_set_message_status(
                {
                    message_id => $message->{'message_id'},
                    status => 'sent'
                }
            );
            $message->{status} = 'sent';
        }
    }
}

sub print_notices_csv {
    my ( $params ) = @_;

    my $messages = $params->{messages};
    my $split = $params->{split};

    my $messages_by_branch;
    if ( $split ) {
        foreach my $message (@$messages) {
            push( @{ $messages_by_branch->{ $message->{'branchcode'} } }, $message );
        }
    } else {
        $messages_by_branch->{all_branches} = $messages;
    }

    while ( my ( $branchcode, $branch_messages ) = each %$messages_by_branch ) {
        my $filename = $split
            ? 'holdnotices-' . $today->output('iso') . "-$branchcode.csv"
            : 'holdnotices-' . $today->output('iso') . ".csv";

        open my $OUTPUT, '>', File::Spec->catdir( $output_directory, $filename );
        my ( @csv_lines, $headers );
        foreach my $message ( @$branch_messages ) {
            my @lines = split /\n/, $message->{content};

            # We don't have headers, get them
            unless ( $headers ) {
                $headers = $lines[0];
                chomp $headers;
                say $OUTPUT $headers;
            }

            shift @lines;
            for my $line ( @lines ) {
                chomp $line;
                next if $line =~ /^\s$/;
                say $OUTPUT $line;
            }

            C4::Letters::_set_message_status(
                {
                    message_id => $message->{'message_id'},
                    status => 'sent'
                }
            ) if $message->{status} ne 'sent';
        }
        close $OUTPUT;
    }
}

=head1 NAME

gather_print_notices - Print waiting print notices

=head1 SYNOPSIS

gather_print_notices output_directory [-s|--split] [--html] [--csv] [--letter_code=LETTER_CODE] [-h|--help]

Will print all waiting print notices to the output_directory.

The generated filename will be holdnotices-TODAY.[csv|html] or holdnotices-TODAY-BRANCHCODE.[csv|html] if the --split parameter is given.

=head1 OPTIONS

=over

=item B<output_directory>

Define the output directory where the files will be generated.

=item B<-s|--split>

Split messages into separate file by borrower home library to OUTPUT_DIRECTORY/notices-CURRENT_DATE-BRANCHCODE.[csv|html]

=item B<--html>

Generate the print notices in a html file (default if --html and --csv are not given).

=item B<--csv>

Generate the print notices in a csv file.
If you use this parameter, the template should contain 2 lines.
The first one the the csv headers and the second one the value list.

For example:
cardnumber:patron:email:item
<<borrowers.cardnumber>>:<<borrowers.firstname>> <<borrowers.surname>>:<<borrowers.email>>:<<items.barcode>>

You have to combine this option without one (and only one) letter_code.

=item B<--letter_code>

Filter print messages by letter_code.
Several letter_code parameters can be given.

=item B<-h|--help>

Print a brief help message

=back

=head1 AUTHOR

Jesse Weaver <pianohacker@gmail.com>

Jonathan Druart <jonathan.druart@biblibre.com>

=head1 COPYRIGHT

Copyright 2009 Jesse Weaver

Copyright 2014 BibLibre

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

=cut
