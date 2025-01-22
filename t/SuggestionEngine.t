#!/usr/bin/perl

use Modern::Perl;
use File::Spec;

use Test::NoWarnings qw( had_no_warnings );
use Test::More;

BEGIN {
    use_ok('Koha::SuggestionEngine');
}

my $plugindir = File::Spec->rel2abs('Koha/SuggestionEngine/Plugin');

opendir( my $dh, $plugindir );
my @installed_plugins = map {
    my $p = $_;
    ( $p =~ /\.pm$/ && -f "$plugindir/$p" && $p =~ s/\.pm$// ) ? "Koha::SuggestionEngine::Plugin::$p" : ()
} readdir($dh);
my @available_plugins = Koha::SuggestionEngine::AvailablePlugins();

foreach my $plugin (@installed_plugins) {
    ok( grep( $plugin, @available_plugins ), "Found plugin $plugin" );
}

my $suggestor = Koha::SuggestionEngine->new( { plugins => ['ABCD::EFGH::IJKL'] } );

is( ref($suggestor), 'Koha::SuggestionEngine', 'Created suggestion engine with invalid plugin' );
is( scalar @{ $suggestor->get_suggestions( { 'search' => 'books' } ) }, 0, 'Request suggestions with empty suggestor' );

$suggestor = Koha::SuggestionEngine->new( { plugins => ['Null'] } );
is(
    ref( $suggestor->plugins->[0] ), 'Koha::SuggestionEngine::Plugin::Null',
    'Created record suggestor with implicitly scoped Null filter'
);

$suggestor = Koha::SuggestionEngine->new( { plugins => ['Koha::SuggestionEngine::Plugin::Null'] } );
is(
    ref( $suggestor->plugins->[0] ), 'Koha::SuggestionEngine::Plugin::Null',
    'Created record suggestor with explicitly scoped Null filter'
);

my $suggestions = $suggestor->get_suggestions( { 'search' => 'books' } );

is_deeply( $suggestions->[0], { 'search' => 'book', label => 'Book!', relevance => 1 }, "Good suggestion" );

$suggestions = $suggestor->get_suggestions( { 'search' => 'silliness' } );

eval {
    $suggestor = Koha::SuggestionEngine->new( { plugins => ['Koha::SuggestionEngine::Plugin::Null'] } );
    undef $suggestor;
};
ok( !$@, 'Destroyed suggestor successfully' );

had_no_warnings;
done_testing();
