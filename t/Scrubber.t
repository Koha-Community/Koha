#!/usr/bin/perl

# Copyright 2025 Koha Development team
#
# This file is part of Koha
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
# along with Koha; if not, see <https://www.gnu.org/licenses>

use Modern::Perl;

use Test::More tests => 8;
use Test::NoWarnings;
use Test::Exception;
use Test::Warn;

BEGIN {
    use_ok('C4::Scrubber');
}

subtest 'new() constructor tests' => sub {
    plan tests => 8;

    my $scrubber;
    lives_ok { $scrubber = C4::Scrubber->new() } 'Constructor with no parameters succeeds';
    isa_ok( $scrubber, 'HTML::Scrubber', 'Constructor returns HTML::Scrubber object' );

    lives_ok { $scrubber = C4::Scrubber->new('default') } 'Constructor with default type succeeds';
    isa_ok( $scrubber, 'HTML::Scrubber', 'Constructor with default type returns HTML::Scrubber object' );

    lives_ok { $scrubber = C4::Scrubber->new('comment') } 'Constructor with comment type succeeds';
    isa_ok( $scrubber, 'HTML::Scrubber', 'Constructor with comment type returns HTML::Scrubber object' );

    lives_ok { $scrubber = C4::Scrubber->new('note') } 'Constructor with note type succeeds';
    isa_ok( $scrubber, 'HTML::Scrubber', 'Constructor with note type returns HTML::Scrubber object' );
};

subtest 'constructor error handling' => sub {
    plan tests => 5;

    my $scrubber;
    lives_ok { $scrubber = C4::Scrubber->new(undef) } 'Constructor with undef type succeeds (treated as default)';
    isa_ok( $scrubber, 'HTML::Scrubber', 'Constructor with undef type returns HTML::Scrubber object' );

    throws_ok {
        C4::Scrubber->new('');
    }
    qr/New called with unrecognized type/, 'Constructor throws exception for empty string type';

    throws_ok {
        C4::Scrubber->new('invalid_type');
    }
    qr/New called with unrecognized type/, 'Constructor throws exception for invalid type';

    throws_ok {
        C4::Scrubber->new('Client');
    }
    qr/New called with unrecognized type/, 'Constructor throws exception for Client type';
};

subtest 'default scrubber functionality' => sub {
    plan tests => 5;

    my $scrubber = C4::Scrubber->new('default');

    my $malicious_html = q|
        <![CDATA[selfdestruct]]&#x5d;>
        <?php echo("EVIL EVIL EVIL"); ?>
        <script>alert('XSS Attack!');</script>
        <style type="text/css">body{display:none;}</style>
        <link href="evil.css" rel="stylesheet">
        <img src="x" onerror="alert('XSS')">
        <a href="javascript:alert('XSS')">Click me</a>
        <p onclick="alert('XSS')">Paragraph</p>
        <div style="background:url(javascript:alert('XSS'))">Content</div>
        Plain text content
    |;

    my $result = $scrubber->scrub($malicious_html);

    unlike( $result, qr/<script/i,     'Script tags are removed' );
    unlike( $result, qr/<style/i,      'Style tags are removed' );
    unlike( $result, qr/<link/i,       'Link tags are removed' );
    unlike( $result, qr/javascript:/i, 'JavaScript URLs are removed' );
    like( $result, qr/Plain text content/, 'Plain text content is preserved' );
};

subtest 'comment scrubber functionality' => sub {
    plan tests => 10;

    my $scrubber = C4::Scrubber->new('comment');

    my $test_html =
        '<p>Paragraph</p><b>Bold</b><i>Italic</i><em>Emphasis</em><big>Big</big><small>Small</small><strong>Strong</strong><br><u>Underline</u><hr><span>Span</span><div>Div</div><script>Evil</script>';

    my $result = $scrubber->scrub($test_html);

    like( $result, qr/<b>Bold<\/b>/,             'Bold tags are preserved' );
    like( $result, qr/<i>Italic<\/i>/,           'Italic tags are preserved' );
    like( $result, qr/<em>Emphasis<\/em>/,       'Em tags are preserved' );
    like( $result, qr/<big>Big<\/big>/,          'Big tags are preserved' );
    like( $result, qr/<small>Small<\/small>/,    'Small tags are preserved' );
    like( $result, qr/<strong>Strong<\/strong>/, 'Strong tags are preserved' );
    like( $result, qr/<br>/,                     'Break tags are preserved' );

    unlike( $result, qr/<p>/,      'Paragraph tags are removed' );
    unlike( $result, qr/<span>/,   'Span tags are removed' );
    unlike( $result, qr/<script>/, 'Script tags are removed' );
};

subtest 'note scrubber functionality' => sub {
    plan tests => 22;

    my $scrubber = C4::Scrubber->new('note');

    my $comprehensive_html =
        '<div><span><p><b>Bold</b><i>Italic</i><em>Emphasis</em><big>Big</big><small>Small</small><strong>Strong</strong><br><u>Underline</u><hr><ol><li>Ordered item 1</li><li>Ordered item 2</li></ol><ul><li>Unordered item 1</li><li>Unordered item 2</li></ul><dl><dt>Term</dt><dd>Definition</dd></dl></p></span></div>';

    my $result = $scrubber->scrub($comprehensive_html);

    like( $result, qr/<div>/,                    'Div tags are preserved' );
    like( $result, qr/<span>/,                   'Span tags are preserved' );
    like( $result, qr/<p>/,                      'Paragraph tags are preserved' );
    like( $result, qr/<b>Bold<\/b>/,             'Bold tags are preserved' );
    like( $result, qr/<i>Italic<\/i>/,           'Italic tags are preserved' );
    like( $result, qr/<em>Emphasis<\/em>/,       'Em tags are preserved' );
    like( $result, qr/<big>Big<\/big>/,          'Big tags are preserved' );
    like( $result, qr/<small>Small<\/small>/,    'Small tags are preserved' );
    like( $result, qr/<strong>Strong<\/strong>/, 'Strong tags are preserved' );
    like( $result, qr/<br>/,                     'Break tags are preserved' );
    like( $result, qr/<u>Underline<\/u>/,        'Underline tags are preserved' );
    like( $result, qr/<hr>/,                     'HR tags are preserved' );
    like( $result, qr/<ol>/,                     'Ordered list tags are preserved' );
    like( $result, qr/<ul>/,                     'Unordered list tags are preserved' );
    like( $result, qr/<li>/,                     'List item tags are preserved' );
    like( $result, qr/<dl>/,                     'Description list tags are preserved' );
    like( $result, qr/<dt>Term<\/dt>/,           'Description term tags are preserved' );
    like( $result, qr/<dd>Definition<\/dd>/,     'Description definition tags are preserved' );

    is( $result, $comprehensive_html, 'All allowed tags in note scrubber are preserved exactly' );

    my $malicious_note = '<p>Safe content</p><script>alert("XSS")</script><iframe src="evil.html"></iframe>';
    my $safe_result    = $scrubber->scrub($malicious_note);

    like( $safe_result, qr/<p>Safe content<\/p>/, 'Safe content is preserved' );
    unlike( $safe_result, qr/<script>/, 'Script tags are removed from notes' );
    unlike( $safe_result, qr/<iframe>/, 'Iframe tags are removed from notes' );
};

subtest 'record_display profile tests' => sub {
    plan tests => 26;

    my $scrubber = C4::Scrubber->new('record_display');

    # Test basic allowed elements
    is(
        $scrubber->scrub('<div>Koha is awesome!</div>'),
        '<div>Koha is awesome!</div>',
        'div element allowed'
    );

    is(
        $scrubber->scrub('<span class="highlight">Perl is awesome!</span>'),
        '<span class="highlight">Perl is awesome!</span>',
        'span with class allowed'
    );

    is(
        $scrubber->scrub('<p id="lukeG">lukeG</p>'),
        '<p id="lukeG">lukeG</p>',
        'p with id allowed'
    );

    is(
        $scrubber->scrub('<h1>Title</h1><h2>Subtitle</h2>'),
        '<h1>Title</h1><h2>Subtitle</h2>',
        'heading elements allowed'
    );

    is(
        $scrubber->scrub('<ul class="list-style" id="mylist"><li>Item</li></ul>'),
        '<ul class="list-style" id="mylist"><li>Item</li></ul>',
        'ul with class and id attributes allowed'
    );

    is(
        $scrubber->scrub('<ol class="numbered" id="ordered-list"><li class="item">Item</li></ol>'),
        '<ol class="numbered" id="ordered-list"><li class="item">Item</li></ol>',
        'ol with class and id, li with class allowed'
    );

    is(
        $scrubber->scrub('<a href="https://example.com" target="_blank" title="External">Link</a>'),
        '<a href="https://example.com" target="_blank" title="External">Link</a>',
        'https links with attributes allowed'
    );

    is(
        $scrubber->scrub('<a href="/cgi-bin/koha/script.pl">Internal</a>'),
        '<a href="/cgi-bin/koha/script.pl">Internal</a>',
        'internal cgi-bin links allowed'
    );

    is(
        $scrubber->scrub('<a href="mailto:test@example.com">Email</a>'),
        '<a href="mailto:test@example.com">Email</a>',
        'mailto links allowed'
    );

    is(
        $scrubber->scrub('<a href="#anchor">Anchor</a>'),
        '<a href="#anchor">Anchor</a>',
        'anchor links allowed'
    );

    is(
        $scrubber->scrub('<strong>Bold</strong> <em>Italic</em> <u>Underline</u>'),
        '<strong>Bold</strong> <em>Italic</em> <u>Underline</u>',
        'text formatting elements allowed'
    );

    is(
        $scrubber->scrub('<table><thead><tr><th>Header</th></tr></thead><tbody><tr><td>Data</td></tr></tbody></table>'),
        '<table><thead><tr><th>Header</th></tr></thead><tbody><tr><td>Data</td></tr></tbody></table>',
        'table elements allowed'
    );

    is(
        $scrubber->scrub('<pre><code>var x = 1;</code></pre>'),
        '<pre><code>var x = 1;</code></pre>',
        'code formatting elements allowed'
    );

    is(
        $scrubber->scrub('<i class="fa fa-book" aria-label="Book icon"></i>'),
        '<i class="fa fa-book" aria-label="Book icon"></i>',
        'Font awesome is allowed'
    );

    is(
        $scrubber->scrub('<script>alert("xss")</script><div>Safe content</div>'),
        '<div>Safe content</div>',
        'script tags removed while safe content preserved'
    );

    is(
        $scrubber->scrub('<div onclick="evil()" class="safe">Content</div>'),
        '<div class="safe">Content</div>',
        'onclick handler is removed, class is preserved'
    );

    is(
        $scrubber->scrub('<div class="valid-class_name">Test</div>'),
        '<div class="valid-class_name">Test</div>',
        'valid class with hyphens and underscores allowed'
    );

    is(
        $scrubber->scrub('<span class="multiple valid classes">Test</span>'),
        '<span class="multiple valid classes">Test</span>',
        'multiple valid classes allowed'
    );

    is(
        $scrubber->scrub('<div class="freak@rico">Test</div>'),
        '<div>Test</div>',
        'invalid class with special characters removed'
    );

    is(
        $scrubber->scrub('<span class="koha.is.cool">Koha is cool</span>'),
        '<span>Koha is cool</span>',
        'class with dots removed'
    );

    is(
        $scrubber->scrub('<p id="valid_id-123">Test</p>'),
        '<p id="valid_id-123">Test</p>',
        'valid id with underscores, hyphens, and numbers allowed'
    );

    is(
        $scrubber->scrub('<p id="invalid id with spaces">Test</p>'),
        '<p>Test</p>',
        'id with spaces removed'
    );

    is(
        $scrubber->scrub('<div id="rico@freak">Test</div>'),
        '<div>Test</div>',
        'id with special characters removed'
    );

    is(
        $scrubber->scrub('<a href="javascript:alert(1)">Bad actor link</a>'),
        '<a>Bad actor link</a>',
        'javascript href removed'
    );

    is(
        $scrubber->scrub('<ol class="roman-numerals" id="list1"><li>Roman numeral list</li></ol>'),
        '<ol class="roman-numerals" id="list1"><li>Roman numeral list</li></ol>',
        'ordered list with class and id attributes'
    );

    is(
        $scrubber->scrub('<ul class="invalid@class"><li>Bad class</li></ul>'),
        '<ul><li>Bad class</li></ul>',
        'invalid list class attribute removed'
    );
};
