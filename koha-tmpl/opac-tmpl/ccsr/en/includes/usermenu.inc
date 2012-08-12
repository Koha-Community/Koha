[% IF ( opacuserlogin ) %][% IF ( loggedinusername ) %]
<div id="menu">
<ul>
  [% IF ( userview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/opac-user.pl">my summary</a></li>
  [% IF ( OPACFinesTab ) %]
  [% IF ( accountview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/opac-account.pl">my fines</a></li>
  [% END %]
  [% IF ( userupdateview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/opac-userupdate.pl">my personal details</a></li>
  [% IF ( TagsEnabled ) %]
    [% IF ( tagsview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/opac-tags.pl?mine=1">my tags</a></li>
  [% END %]
  [% IF ( OpacPasswordChange ) %]
    [% IF ( passwdview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/opac-passwd.pl">change my password</a></li>
  [% END %]
  [% IF ( ShowOpacRecentSearchLink ) %]
  [% IF ( searchhistoryview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/opac-search-history.pl">my search history</a></li>
  [% END %]
  [% IF ( opacreadinghistory ) %]
  [% IF ( readingrecview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/opac-readingrecord.pl">my reading history</a></li>
     [% IF ( OPACPrivacy ) %]
       [% IF ( privacyview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/opac-privacy.pl">my privacy</a></li>
     [% END %]
  [% END %]
  [% IF ( suggestion ) %]
    [% UNLESS ( AnonSuggestions ) %]
      [% IF ( suggestionsview ) %]<li class="active suggestions">[% ELSE %]<li class="suggestions">[% END %]<a href="/cgi-bin/koha/opac-suggestions.pl">my purchase suggestions</a></li>
    [% END %]
  [% END %]
  [% IF ( EnhancedMessagingPreferences ) %]
    [% IF ( messagingview ) %]<li class="active messaging">[% ELSE %]<li class="messaging">[% END %]<a href="/cgi-bin/koha/opac-messaging.pl">my messaging</a></li>
  [% END %]
  [% IF ( virtualshelves ) %]
  [% IF ( listsview ) %]<li class="active privateshelves">[% ELSE %]<li class="privateshelves">[% END %]<a href="/cgi-bin/koha/opac-shelves.pl?display=privateshelves">my lists</a></li>
  [% END %]

</ul>
</div>
[% END %][% ELSE %][% END %]
