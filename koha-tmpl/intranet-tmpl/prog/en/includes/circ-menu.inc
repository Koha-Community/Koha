[% USE Koha %]
[% USE KohaDates %]
[% PROCESS 'member-display-address-style.inc' %]
[% IF ( patron.borrowernumber ) %]
    [% SET patron_is_staff = patron.has_permission({ 'catalogue' => 1 }) %]
    [% SET patron_is_sco = patron.has_permission({ 'self_check' => 'self_checkout_module'}) %]
    [% SET patron_is_sci = patron.has_permission({ 'self_check' => 'self_checkin_module'}) %]
    [% SET patron_is_superlibrarian = patron.is_superlibrarian %]
    [% SET patron_type_class = 'is-not-staff' %]
    [% IF ( patron_is_superlibrarian ) %]
        [% patron_type_class = 'is-staff is-superlibrarian' %]
    [% ELSIF ( patron_is_staff ) %]
        [% patron_type_class = 'is-staff' %]
    [% END %]

    <div class="patroninfo [% patron_type_class | html %]">
        <h5>
            [% IF ( patron_is_staff ) %]
                <i class="fa-solid fa-shield fa-fw" title="Staff patron"></i>
            [% END %]
            [% IF ( patron_is_superlibrarian ) %]
                <i class="fa fa-bolt fa-fw" title="Superlibrarian patron"></i>
            [% END %]
            [% IF ( patron.protected ) %]
                <i class="fa fa-lock fa-fw" title="Protected patron"></i>
            [% END %]
            [% IF ( patron_is_sco ) %]
                <i class="fa-solid fa-upload fa-fw" title="Self checkout patron"></i>
            [% END %]
            [% IF ( patron_is_sci ) %]
                <i class="fa-solid fa-download fa-fw" title="Self check-in patron"></i>
            [% END %]
            [% INCLUDE 'patron-title.inc' %]
        </h5>

        [% IF Koha.Preference('showLastPatron') %]
            <input type="hidden" id="hiddenborrowernumber" value="[% patron.borrowernumber | html %]" />
            <input type="hidden" id="hiddenborrowername" value="[% patron.surname | html %] [% patron.preferred_name | html %]" />
            <input type="hidden" id="hiddenborrowercard" value="[% patron.cardnumber | html %]" />
        [% END %]

        <div class="patroninfo-container">
            [% IF ( patronimages ) %]
                <div class="patronimage-container">
                    [% IF ( patron.image ) %]
                        <img src="/cgi-bin/koha/members/patronimage.pl?borrowernumber=[% patron.borrowernumber | uri %]" class="patronimage" alt="[% patron.firstname | html %] [% patron.surname | html %] ([% patron.cardnumber | html %])" />
                        [% IF ( CAN_user_tools_batch_upload_patron_images ) %]
                            <div class="patronimage-controls">
                                <div class="patronimage-control">
                                    <a data-borrowernumber="[% patron.borrowernumber | uri %]" data-cardnumber="[% patron.cardnumber | html %]" class="btn btn-default edit-patronimage" title="Patron photo" href="#"
                                        ><i class="fa-solid fa-pencil" aria-hidden="true"></i> Edit</a
                                    >
                                </div>
                            </div>
                        [% END %]
                    [% ELSE %]
                        <div class="patronimage empty"></div>
                        [% IF ( CAN_user_tools_batch_upload_patron_images ) %]
                            <div class="patronimage-controls">
                                <div class="patronimage-control">
                                    <a data-borrowernumber="[% patron.borrowernumber | uri %]" data-cardnumber="[% patron.cardnumber | html %]" class="btn btn-default edit-patronimage" title="Patron photo" href="#"
                                        ><i class="fa fa-plus"></i> Add</a
                                    >
                                </div>
                            </div>
                        [% END %]
                    [% END # /IF patron.image %]
                </div>
                <!-- /.patronimage-container -->
            [% END # /IF patronimages %]
            <div class="patronbriefinfo-container">
                <ul class="patronbriefinfo">
                    [% IF patron.pronouns %]
                        <li class="patronpronouns">([% patron.pronouns | html %])</li>
                    [% END %]

                    [% IF !(Koha.Preference('HidePersonalPatronDetailOnCirculation')) %]

                        [% PROCESS 'display-address-style' %]

                        [% IF ( patron.phone || patron.mobile || patron.phonepro ) %]
                            <li class="patronphone">
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
                                [% END %]
                            </li>
                        [% END # /IF phones %]
                        [% IF ( patron.email ) %]
                            <li class="email">
                                <a href="mailto:[% patron.email | url %]" title="[% patron.email | html %]">[% patron.email | html %]</a>
                            </li>
                        [% ELSE %]
                            [% IF ( patron.emailpro ) %]
                                <li class="email">
                                    <a href="mailto:[% patron.emailpro | url %]" title="[% patron.emailpro | html %]">[% patron.emailpro | html %]</a>
                                </li>
                            [% END %]
                        [% END # /IF emails %]
                        [% IF ( patron.dateofbirth ) %]
                            <li class="patrondateofbirth">
                                <span>Born:</span>
                                [% INCLUDE 'patron-age.inc' %]
                            </li>
                        [% END %]

                        [% UNLESS ( patron.address or patron.address2 ) %]
                            <li class="empty"><span id="noaddressstored">No address stored.</span></li>
                        [% END %]
                        [% UNLESS ( patron.city ) %]
                            <li class="empty"><span id="nocitystored">No city stored.</span></li>
                        [% END %]
                        [% UNLESS ( patron.phone or patron.mobile or patron.phonepro) %]
                            <li class="empty"><span>No phone stored.</span></li>
                        [% END %]
                        [% UNLESS ( patron.email or patron.emailpro) %]
                            <li class="empty"><span>No email stored.</span></li>
                        [% END %]
                        [% UNLESS ( patron.dateofbirth ) %]
                            <li class="empty"><span>No date of birth stored.</span></li>
                        [% END %]
                    [% END # /IF HidePersonalPatronDetailOnCirculation %]

                    [% IF Koha.Preference('ExtendedPatronAttributes') %]
                        [% FOREACH extendedattribute IN patron.extended_attributes %]
                            [% IF ( extendedattribute.type.display_checkout ) %]
                                [%# FIXME We should filter in the line above %]
                                [% IF ( extendedattribute.attribute.defined  ) %]
                                    <li class="patronattribute">
                                        <span class="patronattributelabel">[% extendedattribute.type.description | html %]</span>:
                                        [% IF extendedattribute.type.is_date %]
                                            [% extendedattribute.description | $KohaDates %]
                                        [% ELSE %]
                                            [% extendedattribute.description | html %]
                                        [% END %]
                                    </li>
                                    <!-- /.patronattribute -->
                                [% END %]
                            [% END # /IF display_checkout %]
                        [% END # /FOREACH extendedattribute %]
                    [% END # /IF ExtendedPatronAttributes %]

                    <li class="patroncategory"> Category: <span class="patroncategory_description">[% patron.category.description | html %]</span> <span class="patroncategory_code">([% patron.categorycode | html %])</span> </li>
                    <li class="patronlibrary"> Home library: [% Branches.GetName( patron.branchcode ) | html %] </li>
                    <li class="patronborrowernumber"> Borrowernumber: [% patron.borrowernumber | html %] </li>
                    <li class="patronupdatedon">Updated on: [% patron.updated_on | $KohaDates with_hours => 1 %]</li>
                    [% IF Koha.Preference('TrackLastPatronActivityTriggers') %]
                        [% IF ( patron.lastseen ) %]
                            <li class="patronlastseenon"> Last seen on: [% patron.lastseen | $KohaDates with_hours => 1 %] </li>
                        [% ELSE %]
                            <li class="patronlastseenon"> Last seen on: not recorded </li>
                        [% END %]
                    [% END %]
                    [% IF patron.account_locked %]
                        [% IF patron.login_attempts < 0 %]
                            <li class="blocker account_admin_locked">Account has been administratively locked</li>
                        [% ELSE %]
                            <li class="blocker account_locked">Account has been locked</li>
                        [% END %]
                    [% END %]
                </ul>
                <!-- /.patronbriefinfo -->
            </div>
        </div>
    </div>
    <!-- /.patronifo -->

    <div id="circ-menu" class="sidebar_menu">
        <ul>
            [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
                <li [% IF circview %]class="active"[% END %]>
                    <a href="/cgi-bin/koha/circ/circulation.pl?borrowernumber=[% patron.borrowernumber | uri %]">Check out</a>
                </li>
                [% IF Koha.Preference('BatchCheckouts') && Koha.Preference('BatchCheckoutsValidCategories').split(',').grep('^' _ patron.categorycode _ '$').size > 0 %]
                    <li [% IF batch_checkout_view %]class="active"[% END %]>
                        <a href="/cgi-bin/koha/circ/circulation.pl?borrowernumber=[% patron.borrowernumber | uri %]&amp;batch=1">Batch check out</a>
                    </li>
                [% END %]
            [% END # /IF CAN_user_circulate_circulate_remaining_permissions %]
            [% IF CAN_user_borrowers_edit_borrowers %]
                <li [% IF detailview %]class="active"[% END %]>
                    <a href="/cgi-bin/koha/members/moremember.pl?borrowernumber=[% patron.borrowernumber | uri %]">Details</a>
                </li>
            [% END %]
            [% IF ( CAN_user_updatecharges_remaining_permissions ) %]
                <li [% IF finesview %]class="active"[% END %]>
                    <a href="/cgi-bin/koha/members/pay.pl?borrowernumber=[% patron.borrowernumber | uri %]">Accounting</a>
                </li>
            [% END %]
            [% IF ( CAN_user_circulate_circulate_remaining_permissions  ) %]
                [% IF Koha.Preference("RoutingSerials") %]
                    <li [% IF routinglistview %]class="active"[% END %]>
                        <a href="/cgi-bin/koha/members/routing-lists.pl?borrowernumber=[% patron.borrowernumber | uri %]">Routing lists</a>
                    </li>
                [% END %]
            [% END %]
            [% IF CAN_user_borrowers_edit_borrowers %]
                [% IF ( intranetreadinghistory ) %]
                    <li [% IF readingrecordview %]class="active"[% END %]>
                        <a href="/cgi-bin/koha/members/readingrec.pl?borrowernumber=[% patron.borrowernumber | uri %]">Circulation history</a>
                    </li>
                [% END %]
            [% END %]
            [% IF CAN_user_borrowers_edit_borrowers %]
                [% IF ( IntranetReadingHistoryHolds ) %]
                    <li [% IF holdshistoryview %]class="active"[% END %]>
                        <a href="/cgi-bin/koha/members/holdshistory.pl?borrowernumber=[% patron.borrowernumber | uri %]">Holds history</a>
                    </li>
                [% END %]
            [% END %]
            [% IF ( CAN_user_tools_view_system_logs ) %]
                <li [% IF logview %]class="active"[% END %]>
                    <a href="/cgi-bin/koha/tools/viewlog.pl?do_it=1&amp;modules=MEMBERS&amp;modules=CIRCULATION&amp;modules=APIKEYS&amp;object=[% patron.borrowernumber | uri %]&amp;src=circ">Modification log</a>
                </li>
            [% END %]
            [% IF CAN_user_borrowers_edit_borrowers %]
                <li [% IF sentnotices %]class="active"[% END %]>
                    <a href="/cgi-bin/koha/members/notices.pl?borrowernumber=[% patron.borrowernumber | uri %]">Notices</a>
                </li>
            [% END %]
            [% IF CAN_user_borrowers_edit_borrowers %]
                <li [% IF statisticsview %]class="active"[% END %]>
                    <a href="/cgi-bin/koha/members/statistics.pl?borrowernumber=[% patron.borrowernumber | uri %]">Statistics</a>
                </li>
            [% END %]
            [% IF CAN_user_borrowers_edit_borrowers %]
                [% IF ( EnableBorrowerFiles ) %]
                    <li [% IF borrower_files %]class="active"[% END %]>
                        <a href="/cgi-bin/koha/members/files.pl?borrowernumber=[% patron.borrowernumber | uri %]">Files</a>
                    </li>
                [% END %]
            [% END %]

            [% IF CAN_user_suggestions_suggestions_create || CAN_user_suggestions_suggestions_manage || CAN_user_suggestions_suggestions_delete %]
                <li [% IF suggestionsview %]class="active"[% END %]>
                    <a href="/cgi-bin/koha/members/purchase-suggestions.pl?borrowernumber=[% patron.borrowernumber | uri %]">Purchase suggestions</a>
                </li>
            [% END %]
            [% IF CAN_user_borrowers_edit_borrowers && useDischarge %]
                <li [% IF dischargeview %]class="active"[% END %]>
                    <a href="/cgi-bin/koha/members/discharge.pl?borrowernumber=[% patron.borrowernumber | uri %]">Discharges</a>
                </li>
            [% END %]
            [% IF Koha.Preference('HouseboundModule') %]
                <li [% IF houseboundview %]class="active"[% END %]>
                    <a href="/cgi-bin/koha/members/housebound.pl?borrowernumber=[% patron.borrowernumber | uri %]">Housebound</a>
                </li>
            [% END %]
            [% IF Koha.Preference('ILLModule') && CAN_user_ill %]
                <li [% IF illview %]class="active"[% END %]>
                    <a href="/cgi-bin/koha/members/ill-requests.pl?borrowernumber=[% patron.borrowernumber | uri %]">ILL requests history</a>
                </li>
            [% END %]
            [% IF Koha.Preference('UseRecalls') && CAN_user_recalls %]
                <li [% IF recallsview %]class="active"[% END %]>
                    <a href="/cgi-bin/koha/members/recallshistory.pl?borrowernumber=[% patron.borrowernumber | uri %]">Recalls history</a>
                </li>
            [% END %]
            [% IF ( CAN_user_serials && patron.alert_subscriptions.count ) %]
                <li [% IF alertsview %]class="active"[% END %]>
                    <a href="/cgi-bin/koha/members/alert-subscriptions.pl?borrowernumber=[% patron.borrowernumber | uri %]">Alert subscriptions ([% patron.alert_subscriptions.count | html %])</a>
                </li>
            [% END %]
        </ul>
    </div>
    <!-- /.sidebar_menu -->

    [% IF patronimages && CAN_user_tools_batch_upload_patron_images %]
        <!-- Modal -->
        <div class="modal" id="patronImageEdit" tabindex="-1" role="dialog" aria-labelledby="patronImageEditLabel">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h1 class="modal-title" id="patronImageEditLabel">Patron photo</h1>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <!-- /.modal-header -->
                    <div class="modal-body">
                        [% IF ( patron.cardnumber ) %]
                            <div id="upload-patron-image" class="patroninfo-section">
                                <h5>Upload patron photo</h5>
                                <form method="post" id="picture-upload" action="/cgi-bin/koha/tools/picture-upload.pl" enctype="multipart/form-data">
                                    [% IF ( patron.image ) %]
                                        <div class="hint">
                                            To update the image for [% patron.title | html %] [% patron.firstname | html %] [% patron.surname | html %], select a new image file and click 'Upload.' <br />Click the 'Delete' button to remove
                                            the current image.
                                        </div>
                                    [% ELSE %]
                                        <div class="hint">
                                            [% patron.title | html %] [% patron.firstname | html %] [% patron.surname | html %] does not currently have an image available. To import an image for [% patron.title | html %]
                                            [% patron.firstname | html %]
                                            [% patron.surname | html %],
                                            enter the name of an image file to upload.
                                        </div>
                                    [% END # /IF patron.image %]
                                    <p>Only PNG, GIF, JPEG, XPM formats are supported.</p>
                                    <label for="uploadfile">Select the file to upload: </label>
                                    <input type="file" id="uploadfile" name="uploadfile" required="required" />
                                    <div class="action">
                                        [% INCLUDE 'csrf-token.inc' %]
                                        <input type="hidden" id="image" name="filetype" value="image" />
                                        <input type="hidden" id="cardnumber" name="cardnumber" value="[% patron.cardnumber | html %]" />
                                        <input type="hidden" id="borrowernumber" name="borrowernumber" value="[% patron.borrowernumber | html %]" />
                                        <button type="submit" class="btn btn-default btn-xs" name="op" value="cud-Upload"><i class="fa fa-upload"></i> Upload photo</button>
                                    </div>
                                    <!-- /.action -->
                                </form>
                                <!-- /#picture-upload -->
                                [% IF ( patron.image ) %]
                                    <form method="post" id="picture-delete" action="/cgi-bin/koha/tools/picture-upload.pl" enctype="multipart/form-data">
                                        <div class="action" style="padding-top:0px;">
                                            [% INCLUDE 'csrf-token.inc' %]
                                            <input type="hidden" id="image" name="filetype" value="image" />
                                            <input type="hidden" id="cardnumber" name="cardnumber" value="[% patron.cardnumber | html %]" />
                                            <input type="hidden" id="borrowernumber" name="borrowernumber" value="[% patron.borrowernumber | html %]" />
                                            <button id="delpicture" type="submit" class="btn btn-default btn-xs delete" name="op" value="cud-Delete"><i class="fa fa-trash-can"></i> Delete</button>
                                        </div>
                                        <!-- /.action -->
                                    </form>
                                    <!-- /#picture-delete -->
                                [% END %]
                            </div>
                            <!-- /#upload-patron-image -->
                            <div id="capture-patron-image" class="patroninfo-section">
                                <h5>Take patron photo</h5>
                                <form method="post" id="camera-upload" action="/cgi-bin/koha/tools/picture-upload.pl">
                                    <div class="btn-toolbar">
                                        <div class="btn-group">
                                            <button class="btn btn-default" id="takebutton"><i class="fa fa-camera"></i> Take photo</button>
                                        </div>
                                        <div class="btn-group">
                                            <button class="btn btn-default" id="retakebutton" style="display:none;"><i class="fa-solid fa-rotate"></i> Retake photo</button>
                                        </div>
                                        <div class="btn-group">
                                            <a id="downloadbutton" href="#" class="btn btn-default" style="display:none;"><i class="fa fa-download"></i> Download photo</a>
                                        </div>
                                        <div class="btn-group">
                                            <button id="savebutton" type="submit" class="btn btn-default" style="display:none;"><i class="fa-solid fa-hard-drive"></i> Upload</button>
                                        </div>
                                    </div>
                                    <!-- /.btn-toolbar -->
                                    <div id="camera">
                                        <video id="viewfinder">Video stream not available.</video>
                                    </div>
                                    <canvas id="canvas" style="display:none"></canvas>
                                    <div id="output" style="display:none">
                                        <img style="width:100%;height:auto;" id="photo" alt="The screen capture will appear in this box." />
                                    </div>
                                    <input type="hidden" name="uploadfilename" value="patron-photo.jpg" />
                                    <textarea id="uploadfiletext" name="uploadfiletext" style="display:none;"></textarea>
                                    [% INCLUDE 'csrf-token.inc' %]
                                    <input type="hidden" name="filetype" value="image" />
                                    <input type="hidden" name="cardnumber" value="[% patron.cardnumber | html %]" />
                                    <input type="hidden" name="borrowernumber" value="[% patron.borrowernumber | html %]" />
                                    <input name="op" type="hidden" value="cud-Upload" />
                                </form>
                                <!-- /#camera-upload -->
                            </div>
                            <!-- /#capture-patron-image -->
                            <div class="alert alert-info" style="display:none" id="camera-error">
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
                            <!-- /.dialog.message -->
                        [% ELSE %]
                            <div id="missing-cardnumber-picture-upload">
                                <p>The patron must have a card number before a patron photo can be uploaded.</p>
                            </div>
                        [% END # /IF patron.cardnumber %]
                    </div>
                    <!-- /.modal-body -->
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-bs-dismiss="modal">Cancel</button>
                    </div>
                </div>
                <!-- /.modal-content -->
            </div>
            <!-- /.modal-dialog -->
        </div>
        <!-- /#patronImageEdit.modal -->
    [% END # /IF patronimages %]
[% END # /IF patron.borrowernumber %]
