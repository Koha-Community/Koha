/* global PREF_OPACPlayMusicalInscripts interface verovio */
$(document).ready(function () {
    if ($(".musical_inscripts").length > 0) {
        // Check support for WebAssembly
        // https://stackoverflow.com/questions/47879864/how-can-i-check-if-a-browser-supports-webassembly
        var webassenbly_supported = (() => {
            try {
                if (
                    typeof WebAssembly === "object" &&
                    typeof WebAssembly.instantiate === "function"
                ) {
                    const module = new WebAssembly.Module(
                        Uint8Array.of(
                            0x0,
                            0x61,
                            0x73,
                            0x6d,
                            0x01,
                            0x00,
                            0x00,
                            0x00
                        )
                    );
                    if (module instanceof WebAssembly.Module)
                        return (
                            new WebAssembly.Instance(module) instanceof
                            WebAssembly.Instance
                        );
                }
            } catch (e) {}
            return false;
        })();

        if (webassenbly_supported) {
            $.ajaxSetup({
                cache: true,
            });

            $.getScript(
                interface + "/lib/verovio/verovio-toolkit.js",
                function (data, textStatus, jqxhr) {
                    $(".musical_inscripts .inscript").each(function () {
                        var vrvToolkit = new verovio.toolkit();
                        var $t = $(this);
                        var data =
                            "@clef:" +
                            $t.data("clef") +
                            "\n@keysig:" +
                            $t.data("keysig") +
                            "\n@timesig:" +
                            $t.data("timesig") +
                            "\n@data:" +
                            $t.data("notation") +
                            "\n";
                        var svg = vrvToolkit.renderData(data, {
                            inputFormat: $t.data("system"),
                            spacingStaff: 0,
                            adjustPageHeight: 1,
                            scale: 40,
                            pageHeight: 300,
                        });
                        $t.html(svg);
                        var base64midi = vrvToolkit.renderToMIDI();
                        var song = "data:audio/midi;base64," + base64midi;
                        var play_btn = $(".play_btn", $t.parent());
                        if (play_btn.length) {
                            play_btn.data("song", song);
                            play_btn.data("toolkit", vrvToolkit);
                        }
                    });
                    if (PREF_OPACPlayMusicalInscripts) {
                        $(".audio_controls").show();
                        var playmusic_1 = $.getScript(
                            interface +
                                "/lib/verovio/000_acoustic_grand_piano.js"
                        );
                        var playmusic_2 = $.getScript(
                            interface + "/lib/verovio/midiplayer.js"
                        );
                        $.when(playmusic_1, playmusic_2).done(function () {
                            var ids = [];

                            var currentToolkit;
                            var player = $(".inscript_audio");

                            var midiUpdate = function (time) {
                                // time needs to - 400 for adjustment
                                var vrvTime = Math.max(0, time - 400);
                                var elementsattime =
                                    currentToolkit.getElementsAtTime(vrvTime);
                                if (elementsattime.page > 0) {
                                    if (
                                        elementsattime.notes.length > 0 &&
                                        ids != elementsattime.notes
                                    ) {
                                        ids.forEach(function (noteid) {
                                            if (
                                                $.inArray(
                                                    noteid,
                                                    elementsattime.notes
                                                ) == -1
                                            ) {
                                                $("#" + noteid)
                                                    .attr("fill", "#000")
                                                    .attr("stroke", "#000");
                                            }
                                        });
                                        ids = elementsattime.notes;
                                        ids.forEach(function (noteid) {
                                            if (
                                                $.inArray(
                                                    noteid,
                                                    elementsattime.notes
                                                ) != -1
                                            ) {
                                                $("#" + noteid)
                                                    .attr("fill", "#c00")
                                                    .attr("stroke", "#c00");
                                            }
                                        });
                                    }
                                }
                            };

                            var midiStop = function () {
                                ids.forEach(function (noteid) {
                                    $("#" + noteid)
                                        .attr("fill", "#000")
                                        .attr("stroke", "#000");
                                });
                                player.hide();
                            };

                            if (player.length) {
                                player.midiPlayer({
                                    locateFile: function (file) {
                                        return (
                                            interface + "/lib/verovio/" + file
                                        );
                                    },
                                    color: "#c00",
                                    onUpdate: midiUpdate,
                                    onStop: midiStop,
                                });
                            }

                            $(".musical_inscripts .play_btn").click(
                                function () {
                                    var $t = $(this);
                                    player.show();
                                    currentToolkit = $t.data("toolkit");
                                    player.midiPlayer.play($t.data("song"));
                                }
                            );
                        });
                    }
                }
            );
        }
    }
});
