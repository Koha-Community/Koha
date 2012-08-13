package C4::Installer::PerlDependencies;

use warnings;
use strict;

our $PERL_DEPS = {
    'XML::LibXSLT' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.59'
    },
    'Text::CSV::Encoded' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.09'
    },
    'Storable' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '2.20'
    },
    'PDF::API2' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '2'
    },
    'Text::CSV_XS' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.32'
    },
    'Schedule::At' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.06'
    },
    'MIME::Lite' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '3'
    },
    'GD' => {
        'usage'    => 'Patron Images Feature',
        'required' => '0',
        'min_ver'  => '2.39'
    },
    'List::MoreUtils' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.21'
    },
    'DBI' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.53'
    },
    'Net::Z3950::ZOOM' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.16'
    },
    'Biblio::EndnoteStyle' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.05'
    },
    'Date::Calc' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '5.4'
    },
    'Mail::Sendmail' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.79'
    },
    'DBD::mysql' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '4.004'
    },
    'XML::LibXML' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.59'
    },
    'POE' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.9999'
    },
    'Email::Date' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.103'
    },
    'HTML::Scrubber' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.08'
    },
    'XML::Dumper' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.81'
    },
    'URI::Escape' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.36'
    },
    'Unicode::Normalize' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.32'
    },
    'Text::Wrap' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '2005.082401'
    },
    'Test' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.25'
    },
    'Locale::PO' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.17'
    },
    'LWP::Simple' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.41'
    },
    'DBD::SQLite2' => {
        'usage'    => 'Offline Circulation Feature',
        'required' => '0',
        'min_ver'  => '0.33'
    },
    'SMS::Send' => {
        'usage'    => 'SMS Messaging Feature',
        'required' => '0',
        'min_ver'  => '0.05'
    },
    'XML::SAX::ParserFactory' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.01'
    },
    'Test::Harness' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '2.56'
    },
    'PDF::API2::Util' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '2'
    },
    'Class::Accessor' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.3'
    },
    'HTTP::OAI' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '3.2'
    },
    'LWP::UserAgent' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '2.033'
    },
    'MIME::Base64' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '3.07'
    },
    'Algorithm::CheckDigits' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.5'
    },
    'Net::LDAP' => {
        'usage'    => 'LDAP Interface Feature',
        'required' => '0',
        'min_ver'  => '0.33'
    },
    'PDF::Reuse' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.33'
    },
    'DateTime' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.58'
    },
    'DateTime::TimeZone' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.26'
    },
    'DateTime::Format::DateParse' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.04'
    },
    'DateTime::Format::MySQL' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.04'
    },
    'DateTime::Set' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.28'
    },
    'DateTime::Event::ICal' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.08'
    },
    'Readonly' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.03'
    },
    'Readonly::XS' => {
        'usage'    => 'Core',
        'required' => '0',
        'min_ver'  => '1.02'
    },
    'Graphics::Magick' => {
        'usage'    => 'Patron Card Creator Feature',
        'required' => '0',
        'min_ver'  => '1.3.05'
    },
    'MARC::Charset' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.98'
    },
    'Memoize::Memcached' => {
        'usage'    => 'Memcached Feature (Experimental)',
        'required' => '0',
        'min_ver'  => '0.03'
    },
    'Cache::Memcached::Fast' => {
        'usage'    => 'Caching',
        'required' => '0',
        'min_ver'  => '0.17'
    },
    'CHI' => {
        'usage'    => 'Caching',
        'required' => '0',
        'min_ver'  => '0.36'
    },
    'CHI::Driver::Memcached' => {
        'usage'    => 'Caching',
        'required' => '0',
        'min_ver'  => '0.12'
    },
    'Net::LDAP::Filter' => {
        'usage'    => 'LDAP Interface Feature',
        'required' => '0',
        'min_ver'  => '0.14'
    },
    'Text::CSV' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.01'
    },
    'PDF::Table' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.9.3'
    },
    'CGI' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '3.15'
    },
    'Class::Factory::Util' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.6'
    },
    'List::Util' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.18'
    },
    'Lingua::Stem::Snowball' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.952'
    },
    'Time::localtime' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.02'
    },
    'Digest::SHA' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '5.43'
    },
    'MARC::Crosswalk::DublinCore' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.02'
    },
    'CGI::Session::Serialize::yaml' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '4.2'
    },
    'CGI::Carp' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.29'
    },
    'Getopt::Long' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '2.35'
    },
    'Term::ANSIColor' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.1'
    },
    'Getopt::Std' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.05'
    },
    'Data::Dumper' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '2.121'
    },
    'Lingua::Stem' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.82'
    },
    'MIME::QuotedPrint' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '3.07'
    },
    'IPC::Cmd' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.46'
    },
    'HTTP::Cookies' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.39'
    },
    'HTTP::Request::Common' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.26'
    },
    'PDF::Reuse::Barcode' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.05'
    },
    'Test::More' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.8'
    },
    'GD::Barcode::UPCE' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.1'
    },
    'Text::Iconv' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.7'
    },
    'File::Temp' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.16'
    },
    'Date::Manip' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '5.44'
    },
    'Locale::Language' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '2.07'
    },
    'PDF::API2::Simple' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1'
    },
    'XML::RSS' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.31'
    },
    'XML::Simple' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '2.14'
    },
    'PDF::API2::Page' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '2'
    },
    'CGI::Session' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '4.2'
    },
    'CGI::Session::Driver::memcached' => {
        'usage'    => 'Memcached Feature (Experimental)',
        'required' => '0',
        'min_ver'  => '0.04',
    },
    'POSIX' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.09'
    },
    'Digest::MD5' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '2.36'
    },
    'Authen::CAS::Client' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.05'
    },
    'Data::ICal' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.13'
    },
    'MARC::Record' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '2'
    },
    'Locale::Currency::Format' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.28'
    },
    'Number::Format' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.52'
    },
    'YAML::Syck' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.71'
    },
    'Time::HiRes' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.86'
    },
    'MARC::File::XML' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.88'
    },
    'XML::SAX::Writer' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.44'
    },
    'JSON' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '2.07'
    },
    'YAML' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.71'
    },
    'UNIVERSAL::require' => {
        'usage'    => 'SipServer',
        'required' => '0',
        'min_ver'  => '0.13',
    },
    'Net::Server' => {
        'usage'    => 'SipServer',
        'required' => '0',
        'min_ver'  => '0.97',
    },
    'Business::ISBN' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '2.05',
    },
    'Template' => {
	'usage'    => 'Core',
	'required' => '1',
	'min_ver'  => '2.22',
    },
    'Gravatar::URL' => {
        'usage'    => 'Photos in OPAC reviews',
        'required' => '0',
        'min_ver'  => '1.03',
    },
    'Modern::Perl' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.03',
    },
    'DateTime::Format::ICal' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.09',
    },
    'Template::Plugin::HtmlToText' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '0.03',
    },
    'Data::Paginator' => {
        'usage'    => 'Core',
        'required' => '0',
        'min_ver'  => '0.04',
    },
    'Data::Pagination' => {
        'usage'    => 'Core',
        'required' => '0',
        'min_ver'  => '0.44',
    },
    'JSON::Any' => {
        'usage'    => 'Core',
        'required' => '0',
        'min_ver'  => '1.28',
    },
    'MooseX::Storage' => {
        'usage'    => 'Core',
        'required' => '0',
        'min_ver'  => '0.30',
    },
    'MooseX::Types' => {
        'usage'    => 'Core',
        'required' => '0',
        'min_ver'  => '0.30',
    },
    'String::RewritePrefix' => {
        'usage'    => 'Core',
        'required' => '0',
        'min_ver'  => '0.006',
    },
    'Time::Progress' => {
        'usage'    => 'Core',
        'required' => '0',
        'min_ver'  => '1.7',
    },
    'Test::MockModule' => {
        'usage'    => 'Core',
        'required' => '0',
        'min_ver'  => '0.05',
    },
    'Test::Strict' => {
        'usage'    => 'Core',
        'required' => '0',
        'min_ver'  => '0.14',

    },
    'Test::YAML::Valid' => {
        'usage'    => 'Core',
        'required' => '0',
        'min_ver'  => '0.04',
    },
    'Text::Unaccent' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.08',
    },
    'HTML::FormatText' => {
        'usage'    => 'Core',
        'required' => '1',
        'min_ver'  => '1.23',
    },
};

1;

__END__

=head1 NAME

C4::Installer::PerlDependencies

=head1 ABSTRACT

A module for cataloging Koha Perl dependencies.

=head1 SYNOPSIS

This module's sole purpose for existence is to provide a single location to catalog all Koha Perl dependencies. New dependencies should be added to the
end of the outer hash and follow the key/value pattern used in the other dependencies.

=head2 Debian

If you change the list of dependencies, and you use Debian, please also
run the debian/update-control script and commit the modified version of
debian/control into git as well. If you're not running Debian, don't
worry about it.

=head1 AUTHOR

Chris Nighswonger <cnighswonger AT foundations DOT edu>

=head1 COPYRIGHT

Copyright 2010 Foundations Bible College.

=head1 LICENSE

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later version.

You should have received a copy of the GNU General Public License along with Koha; if not, write to the Free Software Foundation, Inc., 51 Franklin Street,
Fifth Floor, Boston, MA 02110-1301 USA.

=head1 DISCLAIMER OF WARRANTY

Koha is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

=cut
