[% USE Koha %]
[% USE KohaDates %]
[% PROCESS 'member-display-address-style.inc' %]
[% IF ( patron.borrowernumber ) %]
[% SET patron_is_staff = patron.has_permission({ 'catalogue' => 1 }) %]
[% SET patron_is_superlibrarian = patron.is_superlibrarian %]
[% SET patron_type_class = 'is-not-staff' %]
[% IF ( patron_is_superlibrarian ) %]
    [% patron_type_class = 'is-staff is-superlibrarian' %]
[% ELSIF ( patron_is_staff ) %]
    [% patron_type_class = 'is-staff' %]
[% END %]
<div class="patroninfo [% patron_type_class | html %]">

[% IF ( patronimages ) %]
    <h5 class="text-center">
[% ELSE %]
    <h5>
[% END %]
        [% IF ( patron_is_staff ) %]
            <i class="fa fa-shield fa-fw" title="Staff patron"></i>
        [% END %]
        [% IF ( patron_is_superlibrarian ) %]
            <i class="fa fa-bolt fa-fw" title="Superlibrarian patron"></i>
        [% END %]
        [% INCLUDE 'patron-title.inc' %]
    </h5>
[% IF Koha.Preference('showLastPatron') %]
    <input type="hidden" id="hiddenborrowernumber" value="[% patron.borrowernumber | html %]">
    <input type="hidden" id="hiddenborrowername" value="[% patron.surname | html %] [% patron.firstname | html %]">
    <input type="hidden" id="hiddenborrowercard" value="[% patron.cardnumber | html %]">
[% END %]

[% IF ( patronimages ) %]
    <div>
        <div class="patronimage-container">
            [% IF ( patron.image ) %]
                <img src="/cgi-bin/koha/members/patronimage.pl?borrowernumber=[% patron.borrowernumber | uri %]" class="patronimage" alt="[% patron.firstname | html %] [% patron.surname | html %] ([% patron.cardnumber | html %])" />
                [% IF ( CAN_user_tools_batch_upload_patron_images ) %]
                    <div class="patronimage-controls">
                        <div class="patronimage-control"><a data-borrowernumber="[% patron.borrowernumber | uri %]" data-cardnumber="[% patron.cardnumber | html %]" class="btn btn-default edit-patronimage" title="Patron photo" href="#"><i class="fa fa-pencil"></i> Edit</a></div>
                    </div>
                [% END %]
            [% ELSE %]
                <div class="patronimage empty"></div>
                [% IF ( CAN_user_tools_batch_upload_patron_images ) %]
                    <div class="patronimage-controls">
                        <div class="patronimage-control"><a data-borrowernumber="[% patron.borrowernumber | uri %]" data-cardnumber="[% patron.cardnumber | html %]" class="btn btn-default edit-patronimage" title="Patron photo" href="#"><i class="fa fa-plus"></i> Add</a></div>
                    </div>
                [% END %]
            [% END %]
        </div>
    </div>
[% END %]

<ul class="patronbriefinfo">
    [% IF !(Koha.Preference('HidePersonalPatronDetailOnCirculation')) %]
        [% IF patron.pronouns %]
            <li class="patronpronouns">([% patron.pronouns | html %])</li>
        [% END %]

        [% PROCESS 'display-address-style' %]

        [% IF ( patron.phone || patron.mobile || patron.phonepro ) %]<li class="patronphone">
        [% IF ( patron.phone ) %]
            <a href="tel:[% patron.phone | url %]">[% patron.phone | html %]</a>
        [% ELSE %]
            [% IF ( patron.mobile ) %]
                <a href="tel:[% patron.mobile | url %]">[% patron.mobile | html %]</a>
            [% ELSE %]
                [% IF ( patron.phonepro ) %]
                    <a href="tel:[% patron.phonepro | url %]">[% patron.phonepro | html %]</a>
                [% END %]
            [% END %]
        [% END %]</li>[% END %]
        [% IF ( patron.email ) %]
            <li class="email"> <a href="mailto:[% patron.email | url %]" title="[% patron.email | html %]">[% patron.email | html %]</a></li>
        [% ELSE %]
            [% IF ( patron.emailpro ) %]
                <li class="email"> <a href="mailto:[% patron.emailpro | url %]" title="[% patron.emailpro | html %]">[% patron.emailpro | html %]</a></li>
            [% END %]
        [% END %]
        [% IF ( patron.dateofbirth ) %]
            <li class="patrondateofbirth">
                <span>Born:</span>
                [% INCLUDE 'patron-age.inc' %]
            </li>
        [% END %]

        [% UNLESS ( patron.address or patron.address2 ) %]
            <li><span class="empty" id="noaddressstored">No address stored.</span></li>
        [% END %]
        [% UNLESS ( patron.city ) %]
            <li><span class="empty" id="nocitystored">No city stored.</span></li>
        [% END %]
        [% UNLESS ( patron.phone or patron.mobile or patron.phonepro) %]
            <li> <span class="empty">No phone stored.</span></li>
        [% END %]
        [% UNLESS ( patron.email or patron.emailpro) %]
            <li> <span class="empty">No email stored.</span></li>
        [% END %]
        [% UNLESS ( patron.dateofbirth ) %]
            <li> <span class="empty">No date of birth stored.</span></li>
        [% END %]

    [% END %]

    [% IF Koha.Preference('ExtendedPatronAttributes') %]
        [% FOREACH extendedattribute IN patron.extended_attributes %]
            [% IF ( extendedattribute.type.display_checkout ) %] [%# FIXME We should filter in the line above %]
                [% IF ( extendedattribute.attribute ) %] [%# FIXME Why that? why not if == 0? %]
                    <li class="patronattribute">
                        <span class="patronattributelabel">[% extendedattribute.type.description | html %]</span>: [% extendedattribute.description | html %]
                    </li>
                [% END %]
            [% END %]
        [% END %]
    [% END %]
    <li class="patroncategory">Category: [% patron.category.description | html %] ([% patron.categorycode | html %])</li>
    <li class="patronlibrary">Home library: [% Branches.GetName( patron.branchcode ) | html %]</li>
    <li class="patronborrowernumber">Borrowernumber: [% patron.borrowernumber | html %]</li>
    <li><span class="patronupdatedon">Updated on [% patron.updated_on | $KohaDates with_hours => 1 %]</span></li>
    [% IF patron.account_locked %]
        [% IF patron.login_attempts < 0 %]
            <li class="blocker account_admin_locked">Account has been administratively locked</li>
        [% ELSE %]
            <li class="blocker account_locked">Account has been locked</li>
        [% END %]
    [% END %]
  </ul></div>
<div id="menu">
<ul>
    [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
        [% IF ( circview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/circ/circulation.pl?borrowernumber=[% patron.borrowernumber | uri %]">Check out</a></li>
        [% IF Koha.Preference('BatchCheckouts') && Koha.Preference('BatchCheckoutsValidCategories').split(',').grep('^' _ patron.categorycode _ '$').size > 0 %]
          [% IF ( batch_checkout_view ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/circ/circulation.pl?borrowernumber=[% patron.borrowernumber | uri %]&amp;batch=1">Batch check out</a></li>
        [% END %]
    [% END %]
    [% IF CAN_user_borrowers_edit_borrowers %]
        [% IF ( detailview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/moremember.pl?borrowernumber=[% patron.borrowernumber | uri %]">Details</a></li>
    [% END %]
    [% IF ( CAN_user_updatecharges_remaining_permissions ) %]
        [% IF ( finesview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/pay.pl?borrowernumber=[% patron.borrowernumber | uri %]">Accounting</a></li>
    [% END %]
    [% IF ( CAN_user_circulate_circulate_remaining_permissions  )  %]
        [% IF Koha.Preference("RoutingSerials") %][% IF ( routinglistview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/routing-lists.pl?borrowernumber=[% patron.borrowernumber | uri %]">Routing lists</a></li>[% END %]
    [% END %]
    [% IF CAN_user_borrowers_edit_borrowers %]
        [% IF ( intranetreadinghistory ) %]
            [% IF ( readingrecordview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/readingrec.pl?borrowernumber=[% patron.borrowernumber | uri %]">Circulation history</a></li>
        [% END %]
    [% END %]
    [% IF CAN_user_borrowers_edit_borrowers %]
        [% IF ( intranetreadinghistory ) %]
            [% IF ( holdshistoryview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/holdshistory.pl?borrowernumber=[% patron.borrowernumber | uri %]">Holds history</a></li>
        [% END %]
    [% END %]
    [% IF ( CAN_user_tools_view_system_logs ) %]
        [% IF ( logview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/tools/viewlog.pl?do_it=1&amp;modules=MEMBERS&amp;modules=CIRCULATION&amp;object=[% patron.borrowernumber | uri %]&amp;src=circ">Modification log</a></li>
    [% END %]
    [% IF CAN_user_borrowers_edit_borrowers %]
    [% IF ( sentnotices ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/notices.pl?borrowernumber=[% patron.borrowernumber | uri %]">Notices</a></li>
    [% END %]
    [% IF CAN_user_borrowers_edit_borrowers %]
        [% IF (  statisticsview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/statistics.pl?borrowernumber=[% patron.borrowernumber | uri %]">Statistics</a></li>
    [% END %]
    [% IF CAN_user_borrowers_edit_borrowers %]
        [% IF ( EnableBorrowerFiles ) %]
            [% IF ( borrower_files ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/files.pl?borrowernumber=[% patron.borrowernumber | uri %]">Files</a></li>
        [% END %]
    [% END %]

    [% IF CAN_user_suggestions_suggestions_manage %]
        [% IF ( suggestionsview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/purchase-suggestions.pl?borrowernumber=[% patron.borrowernumber | uri %]">Purchase suggestions</a></li>
    [% END %]
    [% IF CAN_user_borrowers_edit_borrowers && useDischarge %]
        [% IF dischargeview %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/discharge.pl?borrowernumber=[% patron.borrowernumber | uri %]">Discharges</a></li>
    [% END %]
    [% IF Koha.Preference('HouseboundModule') %]
        [% IF houseboundview %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/housebound.pl?borrowernumber=[% patron.borrowernumber | uri %]">Housebound</a></li>
    [% END %]
    [% IF Koha.Preference('ILLModule') && CAN_user_ill %]
        [% IF illview %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/ill-requests.pl?borrowernumber=[% patron.borrowernumber | uri %]">ILL requests history</a></li>
    [% END %]
    [% IF Koha.Preference('UseRecalls') && CAN_user_recalls %]
        [% IF recallsview %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/recallshistory.pl?borrowernumber=[% patron.borrowernumber | uri %]">Recalls history</a></li>
    [% END %]
</ul></div>

[% IF patronimages && CAN_user_tools_batch_upload_patron_images %]
<!-- Modal -->
<div class="modal" id="patronImageEdit" tabindex="-1" role="dialog" aria-labelledby="patronImageEditLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="closebtn" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="patronImageEditLabel">Patron photo</h4>
            </div>
            <div class="modal-body">
                <div id="upload-patron-image" class="patroninfo-section">
                    <h5>Upload patron photo</h5>
                    <form method="post" id="picture-upload" action="/cgi-bin/koha/tools/picture-upload.pl"
                        enctype="multipart/form-data">
                        [% IF ( patron.image ) %]
                            <div class="hint">
                                To update the image for [% patron.title | html %] [% patron.firstname | html %] [% patron.surname | html %], select a new image file and click 'Upload.' <br />Click the 'Delete' button to
                                remove the current image.
                            </div>
                        [% ELSE %]
                            <div class="hint">
                                [% patron.title | html %] [% patron.firstname | html %] [% patron.surname | html %] does not currently have an image available. To import an image for [% patron.title | html %] [% patron.firstname | html %] [% patron.surname | html %], enter the name of an image file to upload.
                            </div>
                        [% END %]
                        <p>Only PNG, GIF, JPEG, XPM formats are supported.</p>
                        <label for="uploadfile">Select the file to upload: </label>
                        <input type="file" id="uploadfile" name="uploadfile" required="required" />
                        <div class="action">
                            <input type="hidden" id="csrf_token" name="csrf_token" value="[% csrf_token | html %]" />
                            <input type="hidden" id="image" name="filetype" value="image" />
                            <input type="hidden" id="cardnumber" name="cardnumber" value="[% patron.cardnumber | html %]" />
                            <input type="hidden" id="borrowernumber" name="borrowernumber" value="[% patron.borrowernumber | html %]" />
                            <button type="submit" class="btn btn-default btn-xs"><i class="fa fa-upload"></i> Upload photo</button>
                            <input name="op" type="hidden" value="Upload" />
                            [% IF ( patron.image ) %]
                                <a id="delpicture"
                                    href="/cgi-bin/koha/tools/picture-upload.pl?op=Delete&amp;borrowernumber=[% patron.borrowernumber | html %]&amp;csrf_token=[% csrf_token | html %]"
                                    class="btn btn-default btn-xs delete"><i class="fa fa-trash"></i> Delete</a>
                            [% END %]
                        </div>
                    </form>
                </div>
                <div id="capture-patron-image" class="patroninfo-section">
                    <h5>Take patron photo</h5>
                    <form method="post" id="camera-upload" action="/cgi-bin/koha/tools/picture-upload.pl">
                        <div class="btn-toolbar">
                            <div class="btn-group">
                                <button class="btn btn-default" id="takebutton"><i class="fa fa-camera"></i> Take photo</button>
                            </div>
                            <div class="btn-group">
                                <button class="btn btn-default" id="retakebutton" style="display:none;"><i class="fa fa-refresh"></i> Retake photo</button>
                            </div>
                            <div class="btn-group">
                                <a id="downloadbutton" href="#" class="btn btn-default" style="display:none;"><i class="fa fa-download"></i> Download photo</a>
                            </div>
                            <div class="btn-group">
                                <button id="savebutton" type="submit" class="btn btn-default" style="display:none;"><i class="fa fa-hdd-o"></i> Upload</button>
                            </div>
                        </div>
                        <div id="camera">
                            <video id="viewfinder">Video stream not available.</video>
                        </div>
                        <canvas id="canvas" style="display:none"></canvas>
                        <div id="output" style="display:none">
                            <img style="width:100%;height:auto;" id="photo" alt="The screen capture will appear in this box.">
                        </div>
                        <input type="hidden" name="uploadfilename" value="patron-photo.jpg" />
                        <textarea id="uploadfiletext" name="uploadfiletext" style="display:none;"></textarea>
                        <input type="hidden" name="csrf_token" value="[% csrf_token | html %]" />
                        <input type="hidden" name="filetype" value="image" />
                        <input type="hidden" name="cardnumber" value="[% patron.cardnumber | html %]" />
                        <input type="hidden" name="borrowernumber" value="[% patron.borrowernumber | html %]" />
                        <input name="op" type="hidden" value="Upload" />
                    </form>
                </div>
                <div class="dialog message" style="display:none" id="camera-error">
                    <div>
                        <span class="fa-stack fa-lg">
                            <i class="fa fa-camera fa-stack-1x"></i>
                            <i class="fa fa-ban fa-stack-2x text-danger"></i>
                        </span>
                    </div>
                    <div>
                        <strong>Cannot take patron photo.</strong>
                        <span id="camera-error-message"></span>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
            </div>
        </div>
    </div>
</div>
[% END %]

[% END %]
