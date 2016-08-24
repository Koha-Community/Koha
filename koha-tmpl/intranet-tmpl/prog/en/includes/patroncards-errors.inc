[% IF ( error || CGI.param('pdferr') )  %]
<div class="dialog alert">
  <p>
    <strong>WARNING:</strong>
        [% IF CGI.param('pdferr') %]
        Error while creating PDF file.
        [% IF CGI.param('errnocards') %]No cards created (empty batch or list?)[% END %]
        [% IF CGI.param('errba') %]Batch: [% '<span class="ex">' _ CGI.param('errba') _ '</span>' %][% END %]
        [% IF CGI.param('errpl') %]Patron list: [% '<span class="ex">' _ CGI.param('errpl') _ '</span>' %][% END %]
        [% IF CGI.param('errpt') %]Patron number: [% '<span class="ex">' _ CGI.param('errpt') _ '</span>' %][% END %]
        [% IF CGI.param('errlo') %]Layout: [% '<span class="ex">' _ CGI.param('errlo') _ '</span>' %][% END %]
        [% IF CGI.param('errtpl') %]Template: [% '<span class="ex">' _ CGI.param('errtpl') _ '</span>' %][% END %]

        Please have your system administrator check the error log for details.
        [% END %]
        [% IF ( error == 101 ) %]
        The database returned an error while [% IF ( card_element ) %]saving [% card_element %] [% element_id %][% ELSE %]attempting a save operation[% END %]. Please have your system administrator check the error log for details.
        [% ELSIF ( error == 102 ) %]
        The database returned an error while [% IF ( card_element ) %]deleting [% card_element %] [% element_id %][% ELSIF ( image_ids ) %][% image_ids %][% ELSE %]attempting a delete operation[% END %]. Please have your system administrator check the error log for details.
        [% ELSIF ( error == 201 ) %]
        An unsupported operation was attempted[% IF ( element_id ) %] on [% card_element %] [% element_id %][% END %]. Please have your system administrator check the error log for details.
        [% ELSIF ( error == 202 ) %]
        An error has occurred. Please ask your system administrator to check the error log for more details.
        [% ELSIF ( error == 203 ) %]
        A non-existent or invalid library code was supplied. Please <a href="/cgi-bin/koha/circ/selectbranchprinter.pl">verify</a> that you have a library selected.
        [% ELSIF ( error == 301 ) %]
        An error has occurred while attempting to upload the image file. Please ask your system administrator to check the error log for more details.
        [% ELSIF ( error == 302 ) %]
        Image exceeds 500KB. Please resize and import again.
        [% ELSIF ( error == 303 ) %]
        The database image quota currently only allows a maximum of [% image_limit %] images to be stored at any one time. Please delete one or more images to free up quota space.
        [% ELSIF ( error == 401 ) %]
        An error has occurred and the item(s) was not added to batch [% batch_id %]. Please have your system administrator check the error log for details.
        [% ELSIF ( error == 402 ) %]
        The item(s) was not added because the library is not set. Please set your library before adding items to a batch.
        [% ELSIF ( error == 403 ) %]
        An error has occurred and the item(s) was not removed from batch [% batch_id %]. Please have your system administrator check the error log for details.
        [% ELSIF ( error == 404 ) %]
        An error has occurred and batch [% batch_id %] was not deleted.  Please have your system administrator check the error log for details.
        [% ELSIF ( error == 405 ) %]
        An error has occurred and batch [% batch_id %] not fully de-duplicated.
        [% ELSE %]
        [% END %]
  </p>
</div>
[% END %]
