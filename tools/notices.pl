#!/usr/bin/perl

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

use Modern::Perl;

use CGI      qw ( -utf8 );
use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Notice::Messages;
use Koha::Notice::Templates;
use Koha::Patrons;

my $query = CGI->new;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "tools/notices.tt",
        query         => $query,
        type          => "intranet",
        flagsrequired => { tools => 'view_generated_notices' },
    }
);

unless ( C4::Context->preference('NoticesManagement') ) {
    print $query->redirect('/cgi-bin/koha/tools/tools-home.pl');
    exit;
}

# Converting a notice to a print notice changes it, so it needs a POST with a valid CSRF token
my $op = $query->param('op') || q{};
if ( $op eq 'cud-convert_to_print' ) {
    my ($message_id) = ( $query->param('message_id') // q{} ) =~ /^(\d+)$/;
    my $message =
        $message_id ? Koha::Notice::Messages->search_limited( { 'me.message_id' => $message_id } )->next : undef;
    my $converted = $message && $message->can_be_converted_to_print && eval { $message->convert_to_print };
    print $query->redirect( '/cgi-bin/koha/tools/notices.pl?conversion=' . ( $converted ? 'converted' : 'failed' ) );
    exit;
}

my $letter_code  = $query->param('letter_code')  || undef;
my $categorycode = $query->param('categorycode') || undef;
my $branchcode   = $query->param('branchcode')   || undef;
my $from         = $query->param('from')         || undef;
my $to           = $query->param('to')           || undef;
my $status       = $query->param('status')       || undef;

my %where = ();
$where{'me.letter_code'}              = $letter_code  if ($letter_code);
$where{'borrowernumber.categorycode'} = $categorycode if ($categorycode);
$where{'borrowernumber.branchcode'}   = $branchcode   if ($branchcode);
$where{'me.status'}                   = $status       if ($status);

# The 'to' date is inclusive: the notices queued during that whole day are included
my $dtf     = Koha::Database->new->schema->storage->datetime_parser;
my $from_dt = _day_start($from);
my $to_dt   = _day_start($to);
$to_dt->add( days => 1 ) if $to_dt;
my @time_queued = (
    ( $from_dt ? ( { '>=' => $dtf->format_datetime($from_dt) } ) : () ),
    ( $to_dt   ? ( { '<'  => $dtf->format_datetime($to_dt) } )   : () ),
);
$where{'me.time_queued'} = [ -and => @time_queued ] if @time_queued;

# Every notice is rendered in the page, so only the most recent ones are listed
my $limit    = 1000;
my $matching = Koha::Notice::Messages->search_limited( {%where} );
my $notices  = $matching->search( undef, { order_by => { -desc => 'me.time_queued' }, rows => $limit } );

# There is nothing to filter on when the notices of the patrons of a single library can be seen
my @visible_libraries = Koha::Patrons->find($loggedinuser)->libraries_where_can_see_patrons;

$template->param(
    show_library_filter => ( !@visible_libraries || @visible_libraries > 1 ) ? 1 : 0,
    conversion          => scalar $query->param('conversion'),
    notices             => $notices,
    limit               => $limit,
    truncated           => $matching->count > $limit ? 1 : 0,
    letter_code         => $letter_code,
    categorycode        => $categorycode,
    branchcode          => $branchcode,
    from                => $from,
    to                  => $to,
    status              => $status,
    letters             => Koha::Notice::Templates->search(
        {}, { select => [ 'name', 'code' ], group_by => [ 'name', 'code' ], order_by => { -asc => 'code' } }
    ),
);

output_html_with_http_headers $query, $cookie, $template->output;

# The start of the given day as a DateTime, undef if there is no valid date
sub _day_start {
    my ($date) = @_;
    return unless $date;
    my $dt = eval { dt_from_string($date) };
    return $dt ? $dt->truncate( to => 'day' ) : undef;
}
