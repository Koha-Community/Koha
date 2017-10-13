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

define( [ 'resources' ], function( Resources ) {
    var _widgets = {};

    var Widget = {
        Register: function( tagfield, widget ) {
            _widgets[tagfield] = widget;
        },

        PadNum: function( number, length ) {
            var result = number.toString();

            while ( result.length < length ) result = '0' + result;

            return result;
        },

        PadString: function( result, length ) {
            while ( result.length < length ) result = ' ' + result;

            return result;
        },

        PadStringRight: function( result, length ) {
            result = '' + result;
            while ( result.length < length ) result += ' ';

            return result;
        },

        Base: {
            // Marker utils
            clearToText: function() {
                var range = this.mark.find();
                if ( this.text == null ) throw new Error('Tried to clear widget with no text');
                this.mark.doc.replaceRange( this.text, range.from, range.to, 'widget.clearToText' );
            },

            reCreate: function() {
                this.postCreate( this.node, this.mark );
            },

            // Fixed field utils
            bindFixed: function( sel, start, end ) {
                var $node = $( this.node ).find( sel );
                var val = this.getFixed( start, end );
                $node.val( val );

                var widget = this;
                var $collapsed = $( '<span class="fixed-collapsed" title="' + $node.attr('title') + '">' + val + '</span>' ).insertAfter( $node );

                function show() {
                    $collapsed.hide();
                    $node.val( widget.getFixed( start, end ).replace(/\s+$/, '') );
                    $node.show();
                    $node[0].focus();
                }

                function hide() {
                    $node.hide();
                    var val = $node.val();
                    $collapsed.text( Widget.PadStringRight( val === null ? '' : val, end - start ) ).show();
                }

                $node.on( 'change keyup', function() {
                    widget.setFixed( start, end, $node.val(), '+input' );
                } ).focus( show ).blur( hide );

                hide();

                $collapsed.click( show );
            },

            getFixed: function( start, end ) {
                return this.text.substring( start, end );
            },

            setFixed: function( start, end, value, source ) {
                if ( null === value ) {
                    value = '';
                }
                this.setText( this.text.substring( 0, start ) + Widget.PadStringRight( value.toString().substr( 0, end - start ), end - start ) + this.text.substring( end ), source );
            },

            setText: function( text, source ) {
                if ( source == '+input' ) this.mark.doc.cm.addLineClass( this.mark.find().from.line, 'wrapper', 'modified-line' );
                this.text = text;
                this.editor.startNotify();
            },

            createFromXML: function( resourceId ) {
                var widget = this;

                Resources[resourceId].done( function( xml ) {
                    $(widget.node).find('.widget-loading').remove();
                    var $matSelect = $('<select class="material-select"></select>').appendTo(widget.node);
                    var $contents = $('<span class="material-contents"/>').appendTo(widget.node);
                    var materialInfo = {};

                    $('Tagfield', xml).children('Material').each( function() {
                        $matSelect.append( '<option value="' + $(this).attr('id') + '">' + $(this).attr('id') + ' - ' + $(this).children('name').text() + '</option>' );

                        materialInfo[ $(this).attr('id') ] = this;
                    } );

                    $matSelect.change( function() {
                        widget.loadXMLMaterial( materialInfo[ $matSelect.val() ] );
                        widget.nodeChanged();
                    } ).change();
                } );
            },

            loadXMLMaterial: function( materialInfo ) {
                var $contents = $(this.node).children('.material-contents');
                $contents.empty();

                var widget = this;

                $(materialInfo).children('Position').each( function() {
                    var match = $(this).attr('pos').match(/(\d+)(?:-(\d+))?/);
                    if (!match) return;

                    var start = parseInt(match[1]);
                    var end = ( match[2] ? parseInt(match[2]) : start ) + 1;
                    var $input;
                    var $values = $(this).children('Value');

                    if ($values.length == 0) {
                        $contents.append( '<span title="' + $(this).children('name').text() + '">' + widget.getFixed(start, end) + '</span>' );
                        return;
                    }

                    if ( match[2] ) {
                        $input = $( '<input name="f' + Widget.PadNum(start, 2) + '" title="' + $(this).children('name').text() + '" maxlength="' + (end - start) + '" />' );
                    } else {
                        $input = $( '<select name="f' + Widget.PadNum(start, 2) + '" title="' + $(this).children('name').text() + '"></select>' );

                        $values.each( function() {
                            $input.append( '<option value="' + $(this).attr('code') + '">' + $(this).attr('code') + ' - ' + $(this).children('description').text() + '</option>' );
                        } );
                    }

                    $contents.append( $input );
                    widget.bindFixed( $input, start, end );
                } );
            },

            nodeChanged: function() {
                this.mark.changed();
                var widget = this;

                var $inputs = $(this.node).find('input, select');
                if ( !$inputs.length ) return;

                $inputs.off('keydown.marc-tab');
                var editor = widget.editor;

                $inputs.each( function( i ) {
                    $(this).on( 'keydown.marc-tab', function( e ) {
                        // Handle tab/shift-tab
                        if ( e.which != 9 ) { // 9 = Tab
                            // Cheap hack to disable backspace and special keys
                            if ( e.ctrlKey ) {
                                e.preventDefault();
                            }
                            return;
                        }

                        var span = widget.mark.find();
                        var cur = editor.cm.getCursor();

                        if ( e.shiftKey ) {
                            if ( i > 0 ) {
                                var $input = $inputs.eq( i - 1 );
                                if ( $input.is( ':visible' ) ) {
                                    $input.focus();
                                } else {
                                    $input.next('span').click();
                                }
                            } else {
                                editor.cm.setCursor( span.from );
                                // FIXME: ugly hack
                                editor.cm.options.extraKeys['Shift-Tab']( editor.cm );
                                editor.focus();
                            }
                        } else {
                            if ( i < $inputs.length - 1 ) {
                                var $input = $inputs.eq( i + 1 );
                                if ( $input.is( ':visible' ) ) {
                                    $input.focus();
                                } else {
                                    $input.next('span').click();
                                }
                            } else {
                                editor.cm.setCursor( span.to );
                                editor.focus();
                            }
                        }

                        return false;
                    } );
                } );
            },

            // Template utils
            insertTemplate: function( sel ) {
                var wsOnly = /^\s*$/;
                $( sel ).contents().clone().each( function() {
                    if ( this.nodeType == Node.TEXT_NODE ) {
                        this.data = this.data.replace( /^\s+|\s+$/g, '' );
                    }
                } ).appendTo( this.node );
            },
        },

        ActivateAt: function( editor, cur, idx ) {
            var marks = editor.findMarksAt( cur );
            if ( !marks.length || !marks[0].widget ) return false;

            var $input = $(marks[0].widget.node).find('input, select').eq(idx || 0);
            if ( !$input.length ) return false;

            $input.focus();
            return true;
        },

        Notify: function( editor ) {
            $.each( editor.cm.getAllMarks(), function( undef, mark ) {
                if ( mark.widget && mark.widget.notify ) mark.widget.notify();
            } );
        },

        UpdateLine: function( editor, line ) {
            var info = editor.getLineInfo( { line: line, ch: 0 } );
            var lineh = editor.cm.getLineHandle( line );
            if ( !lineh ) return;

            if ( !info ) {
                if ( lineh.markedSpans ) {
                    $.each( lineh.markedSpans, function ( undef, span ) {
                        var mark = span.marker;
                        if ( !mark.widget ) return;

                        mark.widget.clearToText();
                    } );
                }
                return;
            }

            var subfields = [];

            var end = editor.cm.getLine( line ).length;
            if ( info.tagNumber < '010' ) {
                if ( end >= 4 ) subfields.push( { code: '@', from: 4, to: end } );
            } else {
                for ( var i = 0; i < info.subfields.length; i++ ) {
                    var next = ( i < info.subfields.length - 1 ) ? info.subfields[i + 1].ch : end;
                    subfields.push( { code: info.subfields[i].code, from: info.subfields[i].ch + 2, to: next } );
                }
                // If not a fixed field, and we didn't find any subfields, we need to throw in the
                // '@' subfield so we can properly remove it
                if ( subfields.length == 0 ) subfields.push( { code: '@', from: 4, to: end } );
            }

            $.each( subfields, function ( undef, subfield ) {
                var id = info.tagNumber + subfield.code;
                var marks = editor.cm.findMarksAt( { line: line, ch: subfield.from } );

                if ( marks.length ) {
                    if ( marks[0].id == id ) {
                        return;
                    } else if ( marks[0].widget ) {
                        marks[0].widget.clearToText();
                    }
                }

                if ( !_widgets[id] ) return;
                var fullBase = $.extend( Object.create( Widget.Base ), _widgets[id] );
                var widget = Object.create( fullBase );

                if ( subfield.from == subfield.to ) {
                    editor.cm.replaceRange( widget.makeTemplate ? widget.makeTemplate() : '<empty>', { line: line, ch: subfield.from }, null, 'marcWidgetPrefill' );
                    return; // We'll do the actual work when the change event is triggered again
                }

                var text = editor.cm.getRange( { line: line, ch: subfield.from }, { line: line, ch: subfield.to } );

                widget.text = text;
                var node = widget.init();

                var mark = editor.cm.markText( { line: line, ch: subfield.from }, { line: line, ch: subfield.to }, {
                    atomic: true,
                    inclusiveLeft: false,
                    inclusiveRight: false,
                    replacedWith: node,
                } );

                mark.id = id;
                mark.widget = widget;

                widget.node = node;
                widget.mark = mark;
                widget.editor = editor;

                if ( widget.postCreate ) {
                    widget.postCreate();
                }

                widget.nodeChanged();
            } );
        },
    };

    return Widget;
} );
