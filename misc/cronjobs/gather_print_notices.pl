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

my ( $stylesheet, $help, $split );

GetOptions(
    'h|help'  => \$help,
    's|split' => \$split,
) || pod2usage(1);

pod2usage(0) if $help;

my $output_directory = $ARGV[0];

if ( !$output_directory || !-d $output_directory || !-w $output_directory ) {
    pod2usage({
        -exitval => 1,
        -msg => qq{\nError: You must specify a valid and writeable directory to dump the print notices in.\n},
    });
}

cronlogaction();

my $today        = C4::Dates->new();
my @all_messages = @{ GetPrintMessages() };
exit unless (@all_messages);

## carriage return replaced by <br/> as output is html
foreach my $message (@all_messages) {
    local $_ = $message->{'content'};
    s/\n/<br \/>/g;
    s/\r//g;
    $message->{'content'} = $_;
}

my $OUTPUT;

print_notices_html({ messages => \@all_messages, split => $split });

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
        }
    }
}

=head1 NAME

gather_print_notices - Print waiting print notices

=head1 SYNOPSIS

gather_print_notices output_directory [-s|--split] [-h|--help]

Will print all waiting print notices to the output_directory.

The generated filename will be holdnotices-TODAY.html or holdnotices-TODAY-BRANCHCODE.html if the --split parameter is given.

=head1 OPTIONS

=over

=item B<output_directory>

Define the output directory where the files will be generated.

=item B<-s|--split>

Split messages into separate file by borrower home library to OUTPUT_DIRECTORY/notices-CURRENT_DATE-BRANCHCODE.html

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
