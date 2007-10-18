BEGIN { $| = 1; print "1..25\n"; }
END {print "not ok 1\n" unless $loaded;}
use C4::Output;
$loaded = 1;
print "ok 1\n";

#
# ensure &startpage returns correct value
#
if ("<html>\n" eq startpage()) {
    print "ok 2\n";
} else {
    print "not ok 2\n";
}

#
# Check that &gotopage returns proper value
#
if ("<META HTTP-EQUIV=Refresh CONTENT=\"0;URL=http:foo\">" eq gotopage('foo')) {
    print "ok 3\n";
} else {
    print "not ok 3\n";
}

#
# skipping &startmenu for now
#

#
# skipping &endmenu for now

#
# ensure &mktablehdr returns a proper value
#

if ("<table border=0 cellspacing=0 cellpadding=5>\n" eq mktablehdr()) {
    print "ok 4\n";
} else {
    print "not ok 4\n";
}

#
# ensure &mktablerow returns a proper value
#
# 1 row, no background image
if ("<tr valign=top bgcolor=red><td>text</td></tr>\n" eq
    mktablerow(1,'red','text')) {
    print "ok 5\n";
} else { 
    print "not ok 5\n";
}
# 1 row, background image
if ("<tr valign=top bgcolor=red><td background=\"foo.jpg\">text</td></tr>\n" eq
    mktablerow(1,'red','text','foo.jpg')) {
    print "ok 6\n";
} else {
    print "not ok 6\n";
}
#2 rows, no background image
if ("<tr valign=top bgcolor=red><td>text</td><td>text</td></tr>\n" eq
    mktablerow(2,'red','text','text')) {
    print "ok 7\n";
} else {
    print "not ok 7\n";
}

# 2 rows, background image
if ("<tr valign=top bgcolor=red><td background=\"foo.jpg\">text</td><td background=\"foo.jpg\">text</td></tr>\n" eq 
    mktablerow(2,'red','text','text', 'foo.jpg')) {
    print "ok 8\n";
} else {
    print "not ok 8\n";
}

#
# ensure mktableft returns the proper value
#

if ("</table>\n" eq mktableft()) {
    print "ok 9\n";
} else {
    print "not ok 9\n";
}


#
# skipping mkform for now
#

#
# skipping mkform3 for now
#

#
# skipping mkform2 for now
#

#
# ensure endpage returns the proper value
#

if ("</body></html>\n" eq endpage()) {
    print "ok 10\n";
} else {
    print "not ok 10\n";
}


#
# ensure mklink returns the right value
#

if ("<a href=\"foo.html\">foo</a>" eq mklink('foo.html', 'foo')) {
    print "ok 11\n";
} else {
    print "not ok 11\n";
}

#
# ensure mkheadr returns the proper value
#

if ("<FONT SIZE=6><em>foo</em></FONT><br>" eq mkheadr(1,'foo')) {
    print "ok 12\n";
} else {
    print "not ok 12\n";
}

if ("<FONT SIZE=6><em>foo</em></FONT>" eq mkheadr(2,'foo')) {
    print "ok 13\n";
} else {
    print "not ok 13\n";
}

if ("<FONT SIZE=6><em>foo</em></FONT><p>" eq mkheadr(3,'foo')) {
    print "ok 14\n";
} else {
    print "not ok 14\n";
}

#
# test &center and &endcenter
#

if ("<CENTER>\n" eq center()) {
    print "ok 15\n";
} else { 
    print "not ok15\n";
}

if ("</CENTER>\n" eq endcenter()) {
    print "ok 16\n";
} else { 
    print "not ok 16\n";
}

#
# ensure bold returns proper value
#

if ("<b>foo</b>" eq bold('foo')) {
    print "ok 17\n";
} else {
    print "not ok\n";
}

#
# ensure &mkformnotable returns a valid value
#

@inputHidden = qw(hidden hiddenname hiddenvalue);
@inputRadio = qw(radio radioname radiovalue);
@inputText = qw(text textname textvalue);
@inputTextarea = qw(textarea textareaname textareavalue);
@inputSubmit = qw(submit submitname submitvalue);
@inputReset = qw(reset resetname resetvalue);

# 1 input; hidden
@inputs = (\@inputHidden);
$return ="<form action=actionurl method=post>\n";
$return .= "<input type=hidden name=hiddenname value=\"hiddenvalue\">\n";
$return .= "</form>";

if ($return eq mkformnotable('actionurl', @inputs)) {
    print "ok 18\n";
} else {
    print "not ok 18\n";
}

# 1 input; radio
@inputs = (\@inputRadio);
$return ="<form action=actionurl method=post>\n";
$return .= "<input type=radio name=radioname value=\"radiovalue\">radiovalue\n";
$return .= "</form>";

if ($return eq mkformnotable('actionurl', @inputs)) {
    print "ok 19\n";
} else {
    print "not ok 19\n";
}

# 1 input; text
@inputs = (\@inputText);
$return = "<form action=actionurl method=post>\n";
$return .= "<input type=text name=textname value=\"textvalue\">\n";
$return .= "</form>";

if ($return eq mkformnotable('actionurl', @inputs)) {
    print "ok 20\n";
} else {
    print "not ok 20\n";
}


# 1 input; textarea
@inputs = (\@inputTextarea);
$return = "<form action=actionurl method=post>\n";
$return .= "<textarea name=textareaname wrap=physical cols=40 rows=4>textareavalue</textarea>\n";
$return .= "</form>";

if ($return eq mkformnotable('actionurl', @inputs)) {
    print "ok 21\n";
} else {
    print "not ok 21\n";
}

# 1 input; submit
@inputs = (\@inputSubmit);
$return = "<form action=actionurl method=post>\n";
$return .= "<input type=submit name=submitname value=\"submitvalue\">\n";
$return .= "</form>";

if ($return eq mkformnotable('actionurl', @inputs)) {
    print "ok 22\n";
} else {
    print "not ok 22\n";
}

# 1 input; reset
@inputs = (\@inputReset);
$return = "<form action=actionurl method=post>\n";
$return .= "<input type=reset name=resetname value=\"resetvalue\">\n";
$return .= "</form>";

if ($return eq mkformnotable('actionurl', @inputs)) {
    print "ok 23\n";
} else {
    print "not ok 23\n";
}

# 2 inputs; hidden and submit
@inputs = (\@inputHidden, \@inputSubmit);
$return = "<form action=actionurl method=post>\n";
$return .= "<input type=hidden name=hiddenname value=\"hiddenvalue\">\n";
$return .= "<input type=submit name=submitname value=\"submitvalue\">\n";
$return .= "</form>";

if ($return eq mkformnotable('actionurl', @inputs)) {
    print "ok 24\n";
} else {
    print "not ok 24\n";
}


# 3 inputs; text, submit, and reset
@inputs = (\@inputText, \@inputSubmit, \@inputReset);
$return = "<form action=actionurl method=post>\n";
$return .= "<input type=text name=textname value=\"textvalue\">\n";
$return .= "<input type=submit name=submitname value=\"submitvalue\">\n";
$return .= "<input type=reset name=resetname value=\"resetvalue\">\n";
$return .= "</form>";

if ($return eq mkformnotable('actionurl', @inputs)) {
    print "ok 25\n";
} else {
    print "not ok 25\n";
}





