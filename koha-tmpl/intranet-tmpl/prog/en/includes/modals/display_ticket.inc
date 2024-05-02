[% USE AuthorisedValues %]
[% SET status = AuthorisedValues.GetAuthValueDropbox('TICKET_STATUS') %]
[% SET resolutions = AuthorisedValues.GetAuthValueDropbox('TICKET_RESOLUTION') %]
<!-- Display updates concern modal -->
<div class="modal" id="ticketDetailsModal" tabindex="-1" role="dialog" aria-labelledby="ticketDetailsLabel">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="closebtn" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="displayUpdateLabel">Ticket details</h4>
            </div>
            <div class="modal-body">
                <div id="concern-details"></div>
                <fieldset>
                    <ol>
                        <li class="form-group">
                            <label for="message">Update: </label>
                            <textarea id="update_message" class="form-control" name="message"></textarea>
                        </li>
                        <li class="rows">
                            <label for="public">Notify reporter: </label>
                            <input type="checkbox" name="public" id="public">
                            <label for="assignee_id">Change assignee: </label>
                            <select name="assignee_id" id="assignee_id"></select>
                        </li>
                    </ol>
                </fieldset>
            </div> <!-- /.modal-body -->
            <div class="modal-footer">
                <input type="hidden" name="ticket_id" id="ticket_id">
                [% IF resolutions.count %]
                <div class="btn-group">
                  <button type="button" class="btn btn-danger dropdown-toggle" id="resolveTicket" data-toggle="dropdown" aria-expanded="false">
                    Resolve <span class="caret"></span> <i id="resolve-spinner" class="fa fa-spinner fa-pulse fa-fw" style="display:none"></i>
                  </button>
                  <ul class="dropdown-menu">
                    [% FOR resolution IN resolutions %]
                    <li>
                      <a class="dropdown-item resolveSubmit" type="button" data-resolution="[% resolution.authorised_value | html %]">[% resolution.lib | html_entity %]</a>
                    </li>
                    [% END %]
                  </ul>
                </div>
                [% ELSE %]
                <button type="button" class="btn btn-danger resolveSubmit" id="resolveTicket">Resolve <i id="resolve-spinner" class="fa fa-spinner fa-pulse fa-fw" style="display:none"></i></button>
                [% END %]
                [% IF status.count %]
                <div class="btn-group">
                  <button type="button" class="btn btn-primary" id="updateTicket">Update <i id="comment-spinner" class="fa fa-spinner fa-pulse fa-fw" style="display:none"></i></button>
                  <button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                    <span class="caret"></span>
                    <span class="sr-only">Select status</span>
                  </button>
                  <ul class="dropdown-menu">
                    [% FOR st IN status %]
                    <li>
                      <a class="dropdown-item updateSubmit" type="button" data-status="[% st.authorised_value | html %]">[% st.lib | html_entity %]</a>
                    </li>
                    [% END %]
                  </ul>
                </div>
                [% ELSE %]
                <button type="submit" class="btn btn-primary updateSubmit" id="updateTicket">Update <i id="comment-spinner" class="fa fa-spinner fa-pulse fa-fw" style="display:none"></i></button>
                [% END %]
            </div> <!-- /.modal-footer -->
        </div> <!-- /.modal-content -->
    </div> <!-- /.modal-dialog -->
</div> <!-- /#displayUpdateModal -->
