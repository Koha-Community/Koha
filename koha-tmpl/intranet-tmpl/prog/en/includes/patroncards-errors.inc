[% BLOCK asksysadmin %]<span>Please have your system administrator check the error log for details.</span>[% END %]
[% BLOCK b_batch %]<span>Batch: </span>[% END %]
[% BLOCK b_patronlist %]<span>Patron list: </span>[% END %]
[% BLOCK b_patronnumber %]<span>Patron number: </span>[% END %]
[% BLOCK b_layout %]<span>Layout: </span>[% END %]
[% BLOCK b_template %]<span>Template: </span>[% END %]

[% IF ( error || CGI.param('pdferr') )  %]
<div class="dialog alert">
  <p>
    <strong>WARNING:</strong>
        [% IF CGI.param('pdferr') %]<span>Error while creating PDF file. </span>
            [% IF CGI.param('errnocards') %]<span>No cards created (empty batch or list?) </span>[% END %]
            [% IF CGI.param('errba') %][% INCLUDE b_batch %]<span class="ex">[%- CGI.param('errba') | html -%]</span>[% END %]
            [% IF CGI.param('errpl') %][% INCLUDE b_patronlist %]<span class="ex">[%- CGI.param('errpl') | html -%]</span>][% END %]
            [% IF CGI.param('errpt') %][% INCLUDE b_patronnumber %]<span class="ex">[%- CGI.param('errpt') | html -%]</span>[% END %]
            [% IF CGI.param('errlo') %][% INCLUDE b_layout %]<span class="ex">[%- CGI.param('errlo') | html -%]</span>[% END %]
            [% IF CGI.param('errtpl') %][% INCLUDE b_template %]<span class="ex">[%- CGI.param('errtpl') | html -%]</span>[% END %]
            [% INCLUDE asksysadmin %]
        [% END %]

        [% IF ( error == 101 ) %]
           [% IF ( card_element ) %]<span>The database returned an error while saving [% card_element | html %] [% element_id | html %]. </span>
          [% ELSE %]<span>The database returned an error while attempting a save operation. </span>[% END %][% INCLUDE asksysadmin %]
        [% ELSIF ( error == 102 ) %]
            [% IF ( card_element ) %]<span>The database returned an error while deleting [% card_element | html %] [% element_id | html %]. </span>
            [% ELSIF ( image_ids ) %]<span>The database returned an error while deleting [% image_ids | html %]. </span>
            [% ELSE %]<span>The database returned an error while attempting a delete operation. </span>[% END %][% INCLUDE asksysadmin %]
        [% ELSIF ( error == 201 ) %]
            [%IF ( element_id ) %]<span>An unsupported operation was attempted on [% card_element | html %] [% element_id | html %]. </span>
            [% ELSE %]<span>An unsupported operation was attempted. </span>[% END %][% INCLUDE asksysadmin %]
        [% ELSIF ( error == 202 ) %]
            <span>An error has occurred. </span>[% INCLUDE asksysadmin %]
        [% ELSIF ( error == 203 ) %]
            <span>A non-existent or invalid library code was supplied. Please verify that you have a library set. </span><a href="/cgi-bin/koha/circ/selectbranchprinter.pl">Set library</a>
        [% ELSIF ( error == 301 ) %]
            <span>An error has occurred while attempting to upload the image file. </span>[% INCLUDE asksysadmin %]
        [% ELSIF ( error == 302 ) %]
            <span>Image exceeds 500KB. Please resize and import again. </span>
        [% ELSIF ( error == 303 ) %]
            <span>The database image quota currently only allows a maximum of [% image_limit | html %] images to be stored at any one time. Please delete one or more images to free up quota space. </span>
        [% ELSIF ( error == 304 ) %]
            <span>An image with the name '[% IMAGE_NAME | html %]' already exists.</span>
        [% ELSIF ( error == 401 ) %]
            <span>An error has occurred and no items have been added to batch [% batch_id | html %]. </span>[% INCLUDE asksysadmin %]
        [% ELSIF ( error == 402 ) %]
            <span>No items added because the library is not set. Please set your library before adding items to a batch. </span><a href="/cgi-bin/koha/circ/selectbranchprinter.pl">Set library</a>
        [% ELSIF ( error == 403 ) %]
            <span>An error has occurred and the item(s) was not removed from batch [% batch_id | html %]. </span>[% INCLUDE asksysadmin %]
        [% ELSIF ( error == 404 ) %]
            <span>An error has occurred and batch [% batch_id | html %] was not deleted. </span>[% INCLUDE asksysadmin %]
        [% ELSIF ( error == 405 ) %]
            <span>An error has occurred and batch [% batch_id | html %] was not fully de-duplicated. </span>
        [% END %]
  </p>
</div>
[% END %]
