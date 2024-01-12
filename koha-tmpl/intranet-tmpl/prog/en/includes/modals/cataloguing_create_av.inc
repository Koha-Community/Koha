<div id="avCreate" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="avCreateLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="closebtn" data-dismiss="modal" aria-hidden="true">×</button>
                <h3 id="avCreateLabel">Create a new authorized value</h3>
            </div>
            <form id="add_new_av" method="post">
                [% INCLUDE 'csrf-token.inc' %]
                <div class="modal-body">
                    <fieldset class="rows">
                        <ol>
                            <li>
                                <span class="label">Category:</span>
                                <input type="hidden" name="category" value="" />
                                <span id="new_av_category"></span>
                            </li>
                            <li>
                                <label for="value" class="required">Authorized value:</label>
                                <input class="required" required="required" type="text" id="value" name="value" />
                                <span class="required">Required</span>
                            </li>
                            <li>
                                <label for="description" class="required">Description:</label>
                                <input class="required" required="required" type="text" id="description" name="description" />
                                <span class="required">Required</span>
                            </li>
                            <li>
                                <label for="opac_description">Description (OPAC):</label>
                                <input type="text" id="opac_description" name="opac_description" />
                            </li>
                        </ol>
                    </fieldset>
                    <div class="avCreate_error dialog alert" style="display:none;"></div>
                </div>
                <div class="modal-footer">
                    <input type="hidden" name="select2" value="" />
                    <button type="submit" class="btn btn-default">Save</button>
                    <button class="btn btn-default" data-dismiss="modal" aria-hidden="true">Cancel</button>
                </div>
            </form>
        </div> <!-- /.modal-content -->
    </div> <!-- /.modal-dialog -->
</div> <!-- /#avCreate -->
