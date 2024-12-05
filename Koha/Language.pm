package Koha::Language;

=head1 NAME

Koha::Language

=head1 SYNOPSIS

    use Koha::Language;

    Koha::Language->set_requested_language('xx-XX');
    my $language = Koha::Language->get_requested_language();

=head1 DESCRIPTION

This module is essentially a communication tool between the REST API and
C4::Languages::getlanguage so that getlanguage can be aware of the value of
KohaOpacLanguage cookie when not in CGI context.

It can also be used in other contexts, like command line scripts for instance.

=cut

use Modern::Perl;

use Koha::Cache::Memory::Lite;

use constant REQUESTED_LANGUAGE_CACHE_KEY => 'requested_language';

sub set_requested_language {
    my ($class, $language) = @_;

    my $cache = Koha::Cache::Memory::Lite->get_instance;

    $cache->set_in_cache(REQUESTED_LANGUAGE_CACHE_KEY, $language);
}

sub get_requested_language {
    my ($class) = @_;

    my $cache = Koha::Cache::Memory::Lite->get_instance;

    return $cache->get_from_cache(REQUESTED_LANGUAGE_CACHE_KEY);
}

1;
