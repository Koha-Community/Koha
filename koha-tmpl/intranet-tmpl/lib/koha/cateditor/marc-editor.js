/**
 * Copyright 2015 ByWater Solutions
 *
 * This file is part of Koha.
 *
 * Koha is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * Koha is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Koha; if not, see <http://www.gnu.org/licenses>.
 */

define( [ 'marc-record', 'koha-backend', 'preferences', 'text-marc', 'widget' ], function( MARC, KohaBackend, Preferences, TextMARC, Widget ) {

    var NOTIFY_TIMEOUT = 250;

    function editorCursorActivity( cm ) {
        var editor = cm.marceditor;
        var field = editor.getCurrentField();
        if ( !field ) return;

        // Set overwrite mode for tag numbers/indicators and contents of fixed fields
        if ( field.isControlField || cm.getCursor().ch < 8 ) {
            cm.toggleOverwrite(true);
        } else {
            cm.toggleOverwrite(false);
        }

        editor.onCursorActivity();
    }

    // This function exists to prevent inserting or partially deleting text that belongs to a
    // widget. The 'marcAware' change source exists for other parts of the editor code to bypass
    // this check.
    function editorBeforeChange( cm, change ) {
        var editor = cm.marceditor;
        if ( editor.textMode || change.origin == 'marcAware' || change.origin == 'widget.clearToText' ) return;

        // FIXME: Should only cancel changes if this is a control field/subfield widget
        if ( change.from.line !== change.to.line || Math.abs( change.from.ch - change.to.ch ) > 1 || change.text.length != 1 || change.text[0].length != 0 ) return; // Not single-char change

        if ( change.from.ch == change.to.ch - 1 && cm.findMarksAt( { line: change.from.line, ch: change.from.ch + 1 } ).length ) {
            change.cancel();
        } else if ( change.from.ch == change.to.ch && cm.findMarksAt(change.from).length && !change.text[0] == '‡' ) {
            change.cancel();
        }
    }

    function editorChanges( cm, changes ) {
        var editor = cm.marceditor;
        if ( editor.textMode ) return;

        for (var i = 0; i < changes.length; i++) {
            var change = changes[i];

            var origin = change.from.line;
            var newTo = CodeMirror.changeEnd(change);

            for (var delLine = origin; delLine <= change.to.line; delLine++) {
                // Line deleted; currently nothing to do
            }

            for (var line = origin; line <= newTo.line; line++) {
                if ( Preferences.user.fieldWidgets ) Widget.UpdateLine( cm.marceditor, line );
                if ( change.origin != 'setValue' && change.origin != 'marcWidgetPrefill' && change.origin != 'widget.clearToText' ) {
                    cm.addLineClass( line, 'wrapper', 'modified-line' );
                    editor.modified = true;
                }
            }
        }

        Widget.ActivateAt( cm, cm.getCursor() );
        cm.marceditor.startNotify();
    }

    function editorSetOverwriteMode( cm, newState ) {
        var editor = cm.marceditor;

        editor.overwriteMode = newState;
    }

    // Editor helper functions
    function activateTabPosition( cm, pos, idx ) {
        // Allow tabbing to as-yet-nonexistent positions
        var lenDiff = pos.ch - cm.getLine( pos.line ).length;
        if ( lenDiff > 0 ) {
            var extra = '';
            while ( lenDiff-- > 0 ) extra += ' ';
            if ( pos.prefill ) extra += pos.prefill;
            cm.replaceRange( extra, { line: pos.line } );
        }

        cm.setCursor( pos );
        Widget.ActivateAt( cm, pos, idx );
    }

    function getTabPositions( editor, cur ) {
        cur = cur || editor.cm.getCursor();
        var field = editor.getFieldAt( cur.line );

        if ( field ) {
            if ( field.isControlField ) {
                var positions = [ { ch: 0 }, { ch: 4 } ];

                $.each( positions, function( undef, pos ) {
                    pos.line = cur.line;
                } );

                return positions;
            } else {
                var positions = [ { ch: 0 }, { ch: 4, prefill: '_' }, { ch: 6, prefill: '_' } ];

                $.each( positions, function( undef, pos ) {
                    pos.line = cur.line;
                } );
                $.each( field.getSubfields(), function( undef, subfield ) {
                    positions.push( { line: cur.line, ch: subfield.contentsStart } );
                } );

                // Allow to tab to start of empty field
                if ( field.getSubfields().length == 0 ) {
                    positions.push( { line: cur.line, ch: 8 } );
                }

                return positions;
            }
        } else {
            return [];
        }
    }
    var _editorKeys = {};

    _editorKeys[insert_copyright] =  function( cm ) {
            cm.replaceRange( '©', cm.getCursor() );
        }

    _editorKeys[insert_copyright_sound] = function( cm ) {
            cm.replaceRange( '℗', cm.getCursor() );
        }

    _editorKeys[new_line] = function( cm ) {
            var cursor = cm.getCursor();
            cm.replaceRange( '\n', { line: cursor.line }, null, 'marcAware' );
            cm.setCursor( { line: cursor.line + 1, ch: 0 } );
        }

    _editorKeys[line_break] =  function( cm ) {
            var cur = cm.getCursor();

            cm.replaceRange( "\n", cur, null );
        }

    _editorKeys[delete_field] =  function( cm ) {
            // Delete line (or cut)
            if ( cm.somethingSelected() ) return true;
            var curLine = cm.getLine( cm.getCursor().line );

            $("#clipboard").prepend('<option>'+curLine+'</option>');
            $("#clipboard option:first-child").prop('selected', true);

            cm.execCommand('deleteLine');
        }

    _editorKeys[link_authorities] =  function( cm ) {
            // Launch the auth search popup
            var field = cm.marceditor.getCurrentField();

            if ( !field ) return;
            if ( authInfo[field.tag] == undefined ) return;
            authtype = authInfo[field.tag].authtypecode;
            index = 'tag_'+field.tag+'_rancor';
            var mainmainstring = '';
            if( field.getSubfields( authInfo[field.tag].subfield ).length != 0 ){
                mainmainstring += field.getSubfields( authInfo[field.tag].subfield )[0].text;
            }

            var subfields = field.getSubfields();
            var mainstring= '';
            for(i=0;i < subfields.length ;i++){
                if ( authInfo[field.tag].subfield == subfields[i].code ) continue;
                if( subfields[i].code == '9' ) continue;
                mainstring += subfields[i].text+' ';
            }
            newin=window.open("../authorities/auth_finder.pl?source=biblio&authtypecode="+authtype+"&index="+index+"&value_mainstr="+encodeURIComponent(mainmainstring)+"&value_main="+encodeURIComponent(mainstring), "_blank",'width=700,height=550,toolbar=false,scrollbars=yes');

        }

    _editorKeys[delete_subfield] = function( cm ) {
            // Delete subfield
            var field = cm.marceditor.getCurrentField();
            if ( !field ) return;

            var curCursor = cm.getCursor();
            var subfield = field.getSubfieldAt( curCursor.ch );
            var subfieldText= cm.getRange({line:curCursor.line,ch:subfield.start},{line:curCursor.line,ch:subfield.end});
            if ( subfield ) {
                $("#clipboard").prepend('<option>'+subfieldText+'</option>');
                $("#clipboard option:first-child").prop('selected', true);
                subfield.delete();
            }
        }

    _editorKeys[copy_line] = function( cm ) {
            // Copy line
            if ( cm.somethingSelected() ) return true;
            var curLine = cm.getLine( cm.getCursor().line );
            $("#clipboard").prepend('<option>'+curLine+'</option>');
            $("#clipboard option:first-child").prop('selected', true);
        }

    _editorKeys[copy_subfield] = function( cm ) {
            // Copy subfield
            var field = cm.marceditor.getCurrentField();
            if ( !field ) return;

            var curCursor = cm.getCursor();
            var subfield = field.getSubfieldAt( curCursor.ch );
            var subfieldText= cm.getRange({line:curCursor.line,ch:subfield.start},{line:curCursor.line,ch:subfield.end});
            if ( subfield ) {
                $("#clipboard").prepend('<option>'+subfieldText+'</option>');
                $("#clipboard option:first-child").prop('selected', true);
            }
        }

    _editorKeys[paste_line] = function( cm ) {
            // Paste line from "clipboard"
            if ( cm.somethingSelected() ) return true;
            var cBoard = document.getElementById("clipboard");
            var strUser = cBoard.options[cBoard.selectedIndex].text;
            cm.replaceRange( strUser, cm.getCursor(), null );
        }

    _editorKeys[insert_line] = function( cm ) {
            // Copy line and insert below
            if ( cm.somethingSelected() ) return true;
            var curLine = cm.getLine( cm.getCursor().line );
            cm.execCommand('newlineAndIndent');
            cm.replaceRange( curLine, cm.getCursor(), null );
        }

     _editorKeys[next_position] =  function( cm ) {
            // Move through parts of tag/fixed fields
            var positions = getTabPositions( cm.marceditor );
            var cur = cm.getCursor();

            for ( var i = 0; i < positions.length; i++ ) {
                if ( positions[i].ch > cur.ch ) {
                    activateTabPosition( cm, positions[i] );
                    return false;
                }
            }

            cm.setCursor( { line: cur.line + 1, ch: 0 } );
        }

    _editorKeys[prev_position] = function( cm ) {
            // Move backwards through parts of tag/fixed fields
            var positions = getTabPositions( cm.marceditor );
            var cur = cm.getCursor();

            for ( var i = positions.length - 1; i >= 0; i-- ) {
                if ( positions[i].ch < cur.ch ) {
                    activateTabPosition( cm, positions[i], -1 );
                    return false;
                }
            }

            if ( cur.line == 0 ) return;

            var prevPositions = getTabPositions( cm.marceditor, { line: cur.line - 1, ch: cm.getLine( cur.line - 1 ).length } );

            if ( prevPositions.length ) {
                activateTabPosition( cm, prevPositions[ prevPositions.length - 1 ], -1 );
            } else {
                cm.setCursor( { line: cur.line - 1, ch: 0 } );
            }
        }

    _editorKeys[insert_delimiter] = function(cm){
        var cur = cm.getCursor();

        cm.replaceRange( "‡", cur, null );
    }

    _editorKeys[toggle_keyboard] = function( cm ) {
       let keyboard = $(cm.getInputField()).getkeyboard();
       keyboard.isVisible()?keyboard.close():keyboard.reveal();
    }

    // The objects below are part of a field/subfield manipulation API, accessed through the base
    // editor object.
    //
    // Each one is tied to a particular line; this means that using a field or subfield object after
    // any other changes to the record will cause entertaining explosions. The objects are meant to
    // be temporary, and should only be reused with great care. The macro code does this only
    // because it is careful to dispose of the object after any other updates.
    //
    // Note, however, tha you can continue to use a field object after changing subfields. It's just
    // the subfield objects that become invalid.

    // This is an exception raised by the EditorSubfield and EditorField when an invalid change is
    // attempted.
    function FieldError(line, message) {
        this.line = line;
        this.message = message;
    };

    FieldError.prototype.toString = function() {
        return 'FieldError(' + this.line + ', "' + this.message + '")';
    };

    // This is the temporary object for a particular subfield in a field. Any change to any other
    // subfields will invalidate this subfield object.
    function EditorSubfield( field, index, start, end ) {
        this.field = field;
        this.index = index;
        this.start = start;
        this.end = end;

        if ( this.field.isControlField ) {
            this.contentsStart = start;
            this.code = '@';
        } else {
            this.contentsStart = start + 2;
            this.code =  this.field.contents.substr( this.start + 1, 1 );
        }

        this.cm = field.cm;

        var marks = this.cm.findMarksAt( { line: field.line, ch: this.contentsStart } );
        if ( marks[0] && marks[0].widget ) {
            this.widget = marks[0].widget;

            this.text = this.widget.text;
            this.setText = this.widget.setText;
            this.getFixed = this.widget.getFixed;
            this.setFixed = this.widget.setFixed;
        } else {
            this.widget = null;
            this.text = this.field.contents.substr( this.contentsStart, end - this.contentsStart );
        }
    };

    $.extend( EditorSubfield.prototype, {
        _invalid: function() {
            return this.field._subfieldsInvalid();
        },

        delete: function() {
            this.cm.replaceRange( "", { line: this.field.line, ch: this.start }, { line: this.field.line, ch: this.end }, 'marcAware' );
        },
        focus: function() {
            this.cm.setCursor( { line: this.field.line, ch: this.contentsStart } );
        },
        focusEnd: function() {
            this.cm.setCursor( { line: this.field.line, ch: this.end } );
        },
        getText: function() {
            return this.text;
        },
        setText: function( text ) {
            if ( !this._invalid() ) throw new FieldError( this.field.line, 'subfield invalid' );
            this.cm.replaceRange( text, { line: this.field.line, ch: this.contentsStart }, { line: this.field.line, ch: this.end }, 'marcAware' );
            this.field._invalidateSubfields();
        },
    } );

    function EditorField( editor, line ) {
        this.editor = editor;
        this.line = line;

        this.cm = editor.cm;

        this._updateInfo();
        this.tag = this.contents.substr( 0, 3 );
        this.isControlField = ( this.tag < '010' );

        if ( this.isControlField ) {
            this._ind1 = this.contents.substr( 4, 1 );
            this._ind2 = this.contents.substr( 6, 1 );
        } else {
            this._ind1 = null;
            this._ind2 = null;
        }

        this.subfields = null;
    }

    $.extend( EditorField.prototype, {
        _subfieldsInvalid: function() {
            return !this.subfields;
        },
        _invalidateSubfields: function() {
            this._subfields = null;
        },

        _updateInfo: function() {
            this.info = this.editor.getLineInfo( { line: this.line, ch: 0 } );
            if ( this.info == null ) throw new FieldError( 'Invalid field' );
            this.contents = this.info.contents;
        },
        _scanSubfields: function() {
            this._updateInfo();

            if ( this.isControlField ) {
                this._subfields = [ new EditorSubfield( this, 0, 4, this.contents.length ) ];
            } else {
                var field = this;
                var subfields = this.info.subfields;
                this._subfields = [];

                for (var i = 0; i < this.info.subfields.length; i++) {
                    var end = i == subfields.length - 1 ? this.contents.length : subfields[i+1].ch;

                    this._subfields.push( new EditorSubfield( this, i, subfields[i].ch, end ) );
                }
            }
        },

        delete: function() {
            this.cm.replaceRange( "", { line: this.line, ch: 0 }, { line: this.line + 1, ch: 0 }, 'marcAware' );
        },
        focus: function() {
            this.cm.setCursor( { line: this.line, ch: 0 } );

            return this;
        },

        getText: function() {
            var result = '';

            $.each( this.getSubfields(), function() {
                if ( this.code != '@' ) result += '‡' + this.code;

                result += this.getText();
            } );

            return result;
        },
        setText: function( text ) {
            var indicator_match = /^([_ 0-9])([_ 0-9])\‡/.exec( text );
            if ( indicator_match ) {
                text = text.substr(2);
                this.setIndicator1( indicator_match[1] );
                this.setIndicator2( indicator_match[2] );
            }

            this.cm.replaceRange( text, { line: this.line, ch: this.isControlField ? 4 : 8 }, { line: this.line }, 'marcAware' );
            this._invalidateSubfields();

            return this;
        },

        getIndicator1: function() {
            return this._ind1;
        },
        getIndicator2: function() {
            return this._ind2;
        },
        setIndicator1: function(val) {
            if ( this.isControlField ) throw new FieldError('Cannot set indicators on control field');

            this._ind1 = ( !val || val == ' ' ) ? '_' : val;
            this.cm.replaceRange( this._ind1, { line: this.line, ch: 4 }, { line: this.line, ch: 5 }, 'marcAware' );

            return this;
        },
        setIndicator2: function(val) {
            if ( this.isControlField ) throw new FieldError('Cannot set indicators on control field');

            this._ind2 = ( !val || val == ' ' ) ? '_' : val;
            this.cm.replaceRange( this._ind2, { line: this.line, ch: 6 }, { line: this.line, ch: 7 }, 'marcAware' );

            return this;
        },

        appendSubfield: function( code ) {
            if ( this.isControlField ) throw new FieldError('Cannot add subfields to control field');

            this._invalidateSubfields();
            this.cm.replaceRange( '‡' + code, { line: this.line }, null, 'marcAware' );
            var subfields = this.getSubfields();

            return subfields[ subfields.length - 1 ];
        },
        insertSubfield: function( code, position ) {
            if ( this.isControlField ) throw new FieldError('Cannot add subfields to control field');

            position = position || 0;

            var subfields = this.getSubfields();
            this._invalidateSubfields();
            this.cm.replaceRange( '‡' + code, { line: this.line, ch: subfields[position] ? subfields[position].start : null }, null, 'marcAware' );
            subfields = this.getSubfields();

            return subfields[ position ];
        },
        getSubfields: function( code ) {
            if ( !this._subfields ) this._scanSubfields();
            if ( code == null ) return this._subfields;

            var result = [];

            $.each( this._subfields, function() {
                if ( code == null || this.code == code ) result.push(this);
            } );

            return result;
        },
        getFirstSubfield: function( code ) {
            var result = this.getSubfields( code );

            return ( result && result.length ) ? result[0] : null;
        },
        getSubfieldAt: function( ch ) {
            var subfields = this.getSubfields();

            for (var i = 0; i < subfields.length; i++) {
                if ( subfields[i].start < ch && subfields[i].end >= ch ) return subfields[i];
            }
        },
    } );

    function MARCEditor( options ) {
        this.frameworkcode = '';

        this.cm = CodeMirror(
            options.position,
            {
                extraKeys: _editorKeys,
                gutters: [
                    'modified-line-gutter',
                ],
                lineWrapping: true,
                mode: {
                    name: 'marc',
                    nonRepeatableTags: KohaBackend.GetTagsBy( '', 'repeatable', '0' ),
                    nonRepeatableSubfields: KohaBackend.GetSubfieldsBy( '', 'repeatable', '0' )
                }
            }
        );
        var inf = this.cm.getInputField();
        var self = this;
        var kb = $(inf).keyboard({
            //keyBinding: "mousedown touchstart",
            usePreview: false,
            lockInput: false,
            autoAccept: true,
            autoAcceptOnEsc: true,
            userClosed: true,
            //alwaysOpen: true,
            openOn : '',
            position: {
              of: $("#statusbar"), // optional - null (attach to input/textarea) or a jQuery object (attach elsewhere)
              my: 'center top',
              at: 'center bottom',
              at2: 'center bottom' // used when "usePreview" is false (centers keyboard at bottom of the input/textarea)
            },
            beforeInsert: function(evnt, keyboard, elem, txt) {
              var position = self.cm.getCursor();
              if (txt === "\b") {
                self.cm.execCommand("delCharBefore");
              }
              if (txt === "\b" && position.ch === 0 && position.line !== 0) {
                elem.value = self.cm.getLine(position.line) || "";
                txt = "";
              }
              return txt;
            },
            visible: function() {
                $('#set-keyboard-layout').removeClass('hide');
            },
            hidden: function(e, keyboard, el, accepted) {
                inf.focus();
                $('#set-keyboard-layout').addClass('hide');
            }
          }).getkeyboard();


        Object.keys($.keyboard.layouts).forEach(function(layout) {
            var div = $('#keyboard-layout .layouts').append('<div class="layout" data-layout="'+layout+'" data-name="'+($.keyboard.layouts[layout].name||layout)+'" >'+($.keyboard.layouts[layout].name||layout)+'</div>')
            if(kb.layout == layout) {
                div.addClass('active');
            }
        });
        $('#keyboard-layout')
            .on('show.bs.modal', function() {
                kb.close();
                $('#keyboard-layout .filter').focus();
                $('#set-keyboard-layout').removeClass('hide');
            })
            .on('hide.bs.modal', function() {
                !kb.isVisible() && kb.reveal();
            });
        $('#keyboard-layout .layout').click(function(event) {
            $('#keyboard-layout .layout').removeClass('active');
            $(this).addClass('active');
            var layout = $(this).data().layout;
            kb.redraw(layout);
            $('#keyboard-layout').modal('hide');
            $('#keyboard-layout .filter').val('');
            $('#keyboard-layout .layout').show();
        });
        $('#keyboard-layout .filter').keyup(function() {
            var val = $(this).val();
            if(!val||!val.length) return $('#keyboard-layout .layout').show();
            var filter = new RegExp(val, 'i');
            $('#keyboard-layout .layout').hide();
            $('#keyboard-layout .layout').each(function() {
                var name = $(this).data().name;
                if(filter.test(name)) $(this).show();
            })
        });

        this.cm.marceditor = this;

        this.cm.on( 'beforeChange', editorBeforeChange );
        this.cm.on( 'changes', editorChanges );
        this.cm.on( 'cursorActivity', editorCursorActivity );
        this.cm.on( 'overwriteToggle', editorSetOverwriteMode );

        this.onCursorActivity = options.onCursorActivity;

        this.subscribers = [];
        this.subscribe( function( marceditor ) {
            Widget.Notify( marceditor );
        } );
    }

    MARCEditor.FieldError = FieldError;

    $.extend( MARCEditor.prototype, {
        setUseWidgets: function( val ) {
            if ( val ) {
                for ( var line = 0; line <= this.cm.lastLine(); line++ ) {
                    Widget.UpdateLine( this, line );
                }
            } else {
                $.each( this.cm.getAllMarks(), function( undef, mark ) {
                    if ( mark.widget ) mark.widget.clearToText();
                } );
            }
        },

        focus: function() {
            this.cm.focus();
        },

        getCursor: function() {
            return this.cm.getCursor();
        },

        refresh: function() {
            this.cm.refresh();
        },

        setFrameworkCode: function( code, updateFields, callback ) {
            this.frameworkcode = code;
            $( 'a.change-framework i.selected' ).addClass( 'hidden' );
            $( 'a.change-framework i.unselected' ).removeClass( 'hidden' );
            $( 'a.change-framework[data-frameworkcode="' + code + '"] i.unselected' ).addClass( 'hidden' );
            $( 'a.change-framework[data-frameworkcode="' + code + '"] i.selected' ).removeClass( 'hidden ');
            var cm = this.cm;
            KohaBackend.InitFramework( code, function ( error ) {
                cm.setOption( 'mode', {
                    name: 'marc',
                    nonRepeatableTags: KohaBackend.GetTagsBy( code, 'repeatable', '0' ),
                    nonRepeatableSubfields: KohaBackend.GetSubfieldsBy( code, 'repeatable', '0' )
                });
                if ( updateFields ) {
                    var record = TextMARC.TextToRecord( cm.getValue() );
                    KohaBackend.FillRecord( code, record );
                    cm.setValue( TextMARC.RecordToText(record) );
                }
                callback( error );
            } );
        },

        displayRecord: function( record ) {
            this.cm.setValue( TextMARC.RecordToText(record) );
            this.modified = false;
            this.setFrameworkCode(
                typeof record.frameworkcode !== 'undefined' ? record.frameworkcode : '',
                false,
                function ( error ) {
                    if ( typeof error !== 'undefined' ) {
                        humanMsg.displayAlert( _(error), { className: 'humanError' } );
                    }
                }
            );
        },

        getRecord: function() {
            this.textMode = true;

            $.each( this.cm.getAllMarks(), function( undef, mark ) {
                if ( mark.widget ) mark.widget.clearToText();
            } );
            var record = TextMARC.TextToRecord( this.cm.getValue() );
            for ( var line = 0; line <= this.cm.lastLine(); line++ ) {
                if ( Preferences.user.fieldWidgets ) Widget.UpdateLine( this, line );
            }

            this.textMode = false;

            record.frameworkcode = this.frameworkcode;
            return record;
        },

        getLineInfo: function( pos ) {
            var contents = this.cm.getLine( pos.line );
            if ( contents == null ) return {};

            var tagNumber = contents.match( /^([A-Za-z0-9]{3})/ );

            if ( !tagNumber ) return null; // No tag at all on this line
            tagNumber = tagNumber[1];

            if ( tagNumber < '010' ) return { tagNumber: tagNumber, contents: contents }; // No current subfield

            var matcher = /‡([a-z0-9%])/g;
            var match;

            var subfields = [];
            var currentSubfield;

            while ( ( match = matcher.exec(contents) ) ) {
                subfields.push( { code: match[1], ch: match.index } );
                if ( match.index < pos.ch ) currentSubfield = match[1];
            }

            return { tagNumber: tagNumber, subfields: subfields, currentSubfield: currentSubfield, contents: contents };
        },

        addError: function( line, error ) {
            var found = false;
            var options = {};

            if ( line == null ) {
                line = 0;
                options.above = true;
            }

            $.each( this.cm.getLineHandle(line).widgets || [], function( undef, widget ) {
                if ( !widget.isErrorMarker ) return;

                found = true;

                $( widget.node ).append( '; ' + error );
                widget.changed();

                return false;
            } );

            if ( found ) return;

            var node = $( '<div class="structure-error"><i class="fa fa-times"></i> ' + error + '</div>' )[0];
            var widget = this.cm.addLineWidget( line, node, options );

            widget.node = node;
            widget.isErrorMarker = true;
        },

        removeErrors: function() {
            for ( var line = 0; line < this.cm.lineCount(); line++ ) {
                $.each( this.cm.getLineHandle( line ).widgets || [], function( undef, lineWidget ) {
                    if ( lineWidget.isErrorMarker ) lineWidget.clear();
                } );
            }
        },

        startNotify: function() {
            if ( this.notifyTimeout ) clearTimeout( this.notifyTimeout );
            this.notifyTimeout = setTimeout( $.proxy( function() {
                this.notifyAll();

                this.notifyTimeout = null;
            }, this ), NOTIFY_TIMEOUT );
        },

        notifyAll: function() {
            $.each( this.subscribers, $.proxy( function( undef, subscriber ) {
                subscriber(this);
            }, this ) );
        },

        subscribe: function( subscriber ) {
            this.subscribers.push( subscriber );
        },

        createField: function( tag, line ) {
            var contents = tag + ( tag < '010' ? ' ' : ' _ _ ' );

            if ( line > this.cm.lastLine() ) {
                contents = '\n' + contents;
            } else {
                contents = contents + '\n';
            }

            this.cm.replaceRange( contents, { line: line, ch: 0 }, null, 'marcAware' );

            return new EditorField( this, line );
        },

        createFieldOrdered: function( tag ) {
            var line, contents;

            for ( line = 0; line <= this.cm.lastLine(); line++ ) {
                contents = this.cm.getLine(line);
                if ( contents && contents.substr(0, 3) > tag ) break;
            }

            return this.createField( tag, line );
        },

        createFieldGrouped: function( tag ) {
            // Control fields should be inserted in actual order, whereas other fields should be
            // inserted grouped
            if ( tag < '010' ) return this.createFieldOrdered( tag );

            var line, contents;

            for ( line = 0; (contents = this.cm.getLine(line)); line++ ) {
                if ( contents && contents[0] > tag[0] ) break;
            }

            return this.createField( tag, line );
        },

        getFieldAt: function( line ) {
            try {
                return new EditorField( this, line );
            } catch (e) {
                return null;
            }
        },

        getCurrentField: function() {
            return this.getFieldAt( this.cm.getCursor().line );
        },

        getFields: function( tag ) {
            var result = [];

            if ( tag != null ) tag += ' ';

            for ( var line = 0; line < this.cm.lineCount(); line++ ) {
                if ( tag && this.cm.getLine(line).substr( 0, 4 ) != tag ) continue;

                // If this throws a FieldError, pretend it doesn't exist
                try {
                    result.push( new EditorField( this, line ) );
                } catch (e) {
                    if ( !( e instanceof FieldError ) ) throw e;
                }
            }

            return result;
        },

        getFirstField: function( tag ) {
            var result = this.getFields( tag );

            return ( result && result.length ) ? result[0] : null;
        },

        getAllFields: function( tag ) {
            return this.getFields( null );
        },
    } );

    return MARCEditor;
} );
