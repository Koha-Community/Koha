[% USE Context %]
[% SET current_article_requests = Context.Scalar( Context.Scalar( patron, 'article_requests' ), 'filter_by_current' ) %]
[% IF current_article_requests.count > 0 %]
    <table id="article-requests-table" class="table table-bordered table-striped">
        <thead>
            <tr>
                <th class="article-request-record-title anti-the">Record title</th>
                <th class="article-request-created_on psort">Placed on</th>
                <th class="article-request-title anti-the">Title</th>
                <th class="article-request-author">Author</th>
                <th class="article-request-volume">Volume</th>
                <th class="article-request-issue">Issue</th>
                <th class="article-request-date">Date</th>
                <th class="article-request-toc" title="Table of contents">TOC</th>
                <th class="article-request-pages">Pages</th>
                <th class="article-request-chapters">Chapters</th>
                <th class="article-request-notes">Notes</th>
                <th class="article-request-format">Format</th>
                <th class="article-request-status">Status</th>
                <th class="article-request-branchcode">Pickup library</th>
            </tr>
        </thead>

        <tbody>
            [% FOREACH ar IN current_article_requests %]
                <tr>
                    <td class="article-request-record-title">
                        <a class="article-request-record-link-title" href="/cgi-bin/koha/circ/request-article.pl?biblionumber=[% ar.biblionumber | html %]">
                            [% ar.biblio.title | html %]
                            [% ar.item.enumchron | html %]
                        </a>
                        [% ar.biblio.author | html %]
                        [% IF ar.itemnumber %]<em>(only [% ar.item.barcode | html %])</em>[% END %]
                    </td>

                    <td class="article-request-created_on"> [% ar.created_on | $KohaDates %] </td>

                    <td class="article-request-title"> [% ar.title | html %] </td>

                    <td class="article-request-author"> [% ar.author | html %] </td>

                    <td class="article-request-volume"> [% ar.volume | html %] </td>

                    <td class="article-request-issue"> [% ar.issue | html %] </td>

                    <td class="article-request-date"> [% ar.date | html %] </td>

                    <td class="article-request-toc"> [% IF ar.toc_request %]<span>Yes</span>[% END %] </td>

                    <td class="article-request-pages"> [% ar.pages | html %] </td>

                    <td class="article-request-chapters"> [% ar.chapters | html %] </td>

                    <td class="article-request-patron-notes"> [% ar.patron_notes | html %] </td>

                    <td class="article-request-format">
                        [% IF ar.format == 'PHOTOCOPY' %]
                            <span>Copy</span>
                        [% ELSIF ar.format == 'SCAN' %]
                            <span>Scan</span>
                        [% END %]
                    </td>

                    <td class="article-request-status">
                        [% IF ar.status == 'PENDING' %]
                            <span>Pending</span>
                        [% ELSIF ar.status == 'PROCESSING' %]
                            <span>Processing</span>
                        [% ELSIF ar.status == 'COMPLETED' %]
                            <span>Completed</span>
                        [% ELSIF ar.status == 'CANCELED' %]
                            <span>Canceled</span>
                        [% END %]
                    </td>

                    <td class="article-request-branchcode"> [% ar.branch.branchname | html %] </td>
                </tr>
            [% END %]
        </tbody>
    </table>
[% ELSE %]
    <span>Patron has no current article requests.</span>
[% END %]
