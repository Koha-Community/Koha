[%# Lists the data quality problems recorded for a bibliographic record's stored metadata, i.e. the faults repaired when it was saved or read (bug 43777). %]
[%# Call it with WRAPPER, passing 'errors' (Koha::Biblio::Metadata::Error objects), and optionally 'heading'. %]
[%# The wrapped content is shown below the introductory sentence, e.g. to say what to do next. %]
[%# Pass 'resolvable' (with 'biblionumber') to add the links to the affected fields and the "Mark resolved" buttons; %]
[%# these are only wired up in the cataloguing editor. %]
[% IF errors.size %]
    <div class="alert alert-warning metadata-repairs" [% IF resolvable %]id="nonxml-errors-notice"[% END %]>
        <h1>[% heading || "Data quality warnings" | html %]</h1>
        <p><strong class="text-danger">This record had problems that were automatically repaired when it was last saved or loaded.</strong></p>
        [% content | $raw %]
        <table class="table table-sm metadata-repairs-table">
            <thead>
                <tr>
                    <th>Field</th>
                    <th>Problem</th>
                    <th>Where</th>
                    [% IF resolvable %]<th class="no-sort"></th>[% END %]
                </tr>
            </thead>
            <tbody [% IF resolvable %]id="nonxml-error-list"[% END %]>
                [% FOREACH err IN errors %]
                    [% parts = err.message.split('\n', 2) %]
                    <tr [% IF resolvable %]id="nonxml-error-[% err.id | html %]"[% END %]>
                        <td>
                            [% IF resolvable && err.tag %]
                                <a class="nonxml-linkfield" href="#" data-tag="[% err.tag | html %]" [% IF err.subfield %]data-subfield="[% err.subfield | html %]"[% END %]>
                                    [% err.tag | html %][% IF err.subfield %]$[% err.subfield | html %][% END %]
                                </a>
                            [% ELSIF err.tag %]
                                [% err.tag | html %][% IF err.subfield %]$[% err.subfield | html %][% END %]
                            [% END %]
                        </td>
                        <td>[% parts.0.replace('^\S+: ', '') | html %]</td>
                        <td>[% IF parts.1 %]<pre class="mb-0">[% parts.1 | html %]</pre>[% END %]</td>
                        [% IF resolvable %]
                            <td><button class="nonxml-resolve btn btn-default btn-xs" data-error-id="[% err.id | html %]" data-biblio-id="[% biblionumber | html %]"> Mark resolved </button></td>
                        [% END %]
                    </tr>
                [% END %]
            </tbody>
        </table>
    </div>
[% END %]
