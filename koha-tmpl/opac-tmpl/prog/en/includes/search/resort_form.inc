[% IF sort_by == "score asc" %]
  <option value="score asc" selected="selected">Relevance asc</option>
[% ELSE %]
  <option value="score asc">Relevance asc</option>
[% END %]
[% IF sort_by == "score desc" %]
  <option value="score desc" selected="selected">Relevance desc</option>
[% ELSE %]
  <option value="score desc">Relevance desc</option>
[% END %]

[% FOREACH ind IN sortable_indexes %]
  [% IF sort_by == "$ind.code asc" %]
    <option value="[% ind.code %] asc" selected="selected">[% ind.label %] asc</option>
  [% ELSE %]
    <option value="[% ind.code %] asc">[% ind.label %] asc</option>
  [% END %]
  [% IF sort_by == "$ind.code desc" %]
    <option value="[% ind.code %] desc" selected="selected">[% ind.label %] desc</option>
  [% ELSE %]
    <option value="[% ind.code %] desc">[% ind.label %] desc</option>
  [% END %]
[% END %]
