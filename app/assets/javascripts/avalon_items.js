let adder_event_target = null;
function hookAiContextMenu() {
    $('.adder').contextmenu(function(event) {
        showMenu(event);
        adder_event_target = event.target;
        return false;
    });
    $('#addPersonButton').click(addPerson);
    $('#addWorkButton').click(addWork);
    $('#adder_close').click(function() {
        toggleOverlay($('#adder_overlay'));
    });
}
function showMenu(e) {
    let el = $('.aiJsonMenu');
    if (el.is(':visible')) {
        el.toggle();
    }
    el.css({
        left:  e.pageX,
        top:   e.pageY
    }).toggle();
}
function hideMenu() {
    let el = $('.aiJsonMenu');
    if (el.is(':visible')) {
        el.toggle();
    }
}

function addPerson(e) {
    hideMenu();
    let text = getTextSelection(e);
    if (text === null || text.length === 0) {
        text = adder_event_target.textContent;
    }
    $.ajax({
        url: "./"+avalon_item_id+"/ajax_people_adder",
        data: {text: text},
        success: function(result) {
            let el = $( "#adder_overlay" );
            $('#adder_content').html(result);
            $('.peopleButtonAdderCancel').click(function(){
                toggleOverlay($('#adder_overlay'));
            });
            $('.peopleButtonAdderCreate').click(function() {

            });
            toggleOverlay(el);
        },
        error: function(xhr, status, error) {
            swal.fire({
                icon: '',
                title: "Ajax Error trying to get the 'adder' Form",
                text: xhr.responseText
            })
        }
    })
}

function addWork(e) {
    hideMenu();
    let text = getTextSelection(e);
    if (text === null || text.length === 0) {
        text = adder_event_target.textContent;
    }
    $.ajax({
        url: "./"+avalon_item_id+"/ajax_work_adder",
        data: {text: text},
        success: function(result) {
            let el = $( "#adder_overlay" );
            $('#adder_content').html(result);
            $('.peopleButtonAdderCancel').click(function(){
                toggleOverlay($('#adder_overlay'));
            });
            $('.peopleButtonAdderCreate').click(function() {

            });
            toggleOverlay(el);
        },
        error: function(xhr, status, error) {
            swal.fire({
                icon: '',
                title: "Ajax Error trying to get the 'adder' Form",
                text: xhr.responseText
            })
        }
    })
}

function toggleOverlay(el) {
    if (el.attr("data-animation-offscreen") === "true") {
        el.animate({left: "50%"}, 400);
        el.attr("data-animation-offscreen", "false");
        $('#main_content').animate({'max-width': '50%'}, 400);
    } else {
        el.animate({left: "100%"}, 400);
        el.attr("data-animation-offscreen", "true");
        $('#main_content').animate({'max-width': '100%'}, 400);
    }
}

function getTextSelection() {
    let textSelection = null;
    if (window.getSelection) {
        textSelection = window.getSelection().toString();
    } else if (document.selection && document.selection.type !== "Control") {
        textSelection = document.selection.createRange().text;
    }
    return textSelection;
}

function hookButtons() {
    hookEditRecordings();
    hookCreateEditPerformances();
    hookDeletePerformanceButtons();
    hookCreateTrackButtons();
    hookEditTrackButtons();
    hookDeleteTrackButtons();
}
function rehookButtons() {
    $(".editRecordingButton").unbind('click', editRecording).click(editRecording);
    $('.createPerformanceButton').unbind('click', loadNewPerformance).click(loadNewPerformance);
    $('.editPerformanceButton').unbind('click', loadEditPerformanceForm).click(loadEditPerformanceForm);
    $('.deletePerformanceButton').unbind('click', deletePerformance).click(deletePerformance);

    $('.createTrackButton').unbind('click', createNewTrack).click(createNewTrack);
    $('.editTrackButton').unbind('click', loadEditTrackForm).click(loadEditTrackForm);
    $('.deleteTrackButton').unbind('click', deleteTrack).click(deleteTrack);
}
/** AJAX functionality for editing Recording metadata **/
function hookEditRecordings() {
    $(".editRecordingButton").click(editRecording);
}
function hookCreateEditPerformances() {
    $('.createPerformanceButton').click(loadNewPerformance);
    $('.editPerformanceButton').click(loadEditPerformanceForm);
}
function hookDeletePerformanceButtons() {
    $('.deletePerformanceButton').click(deletePerformance)
}
function deletePerformance(event) {
    let track_count = $(event.target).closest('.perf_div').find('.track_div').length;
    if (track_count === 0) {
        Swal.fire({
            title: 'Confirm Performance Delete',
            text: "Are you sure you want to permanently delete this Performance?",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#006298',
            confirmButtonText: 'Delete'
        }).then((result) => {
            if (result.value) {
                let performanceId = $(event.target).attr('data-performance-id');
                $.ajax({
                    url: '../performances/' + performanceId,
                    method: 'DELETE',
                    success: function (result) {
                        $('.perf_div[data-performance-id=' + performanceId + ']').remove();
                    },
                    error: function (xhr, status, error) {
                        swal.fire({
                            icon: '',
                            title: "Ajax Error trying to delete Performance",
                            text: xhr.responseText
                        })
                    }
                })
            }
        })
    } else {
        swal.fire({
            title: "Cannot Delete Performance",
            text: "Performances with Tracks and cannot be deleted. Delete all tracks first.",
            icon: 'warning',
        })
    }
}
function editRecording(event) {
    loadEditRecordingForm($(event.target).attr('data-recording-id'));
}
function loadEditRecordingForm(recordingId) {
    $.ajax({
        url: '../recordings/ajax/edit/'+recordingId,
        success: function(result) {
            $(".recording_div[data-recording-id="+recordingId+"]").replaceWith(result);
            $('.recordingEditCancelButton[data-recording-id='+recordingId+']').click(function() {
                cancelRecordingEdit(recordingId);
            });
            $('form#edit_recording_'+recordingId).on("ajax:success", function(e, data, status, xhr) {
                submitRecordingEditResponse(recordingId, e, data, status, xhr);
            });
            rehookButtons();
        },
        error: function(xhr,status,error) {
            swal.fire({
                icon: 'error',
                title: "loadEditRecordingForm: Ajax Error calling: /recordings/ajax/edit/"+recordingId,
                text: error
            })
        }
    })
}
function cancelRecordingEdit(recordingId) {
    $.ajax({
        url: '../recordings/ajax/show/'+recordingId,
        success: function(result) {
            $(".recording_div[data-recording-id="+recordingId+"]").replaceWith(result);
            rehookButtons();
            rehookAccordion();
        },
        error: function(xhr,status,error) {
            swal.fire({
                icon: 'error',
                title: "Ajax Error calling: /recordings/ajax/edit/"+recordingId,
                text: error
            })
        }
    });
}
function submitRecordingEditResponse(recordingId, e, data, status, xhr) {
    $(".recording_div[data-recording-id="+recordingId+"]").replaceWith(xhr.responseText);
    rehookButtons();
    rehookAccordion();
}
/** END AJAX functionality for editing Recordings **/

/** AJAX functionality for Editing/Creating Performances */
function loadNewPerformance(event) {
    loadNewPerformanceForm($(event.target).attr('data-recording-id'));
}
function loadNewPerformanceForm(recordingId) {
    $.ajax({
        url: '../performances/ajax/new/'+recordingId,
        success: function(result) {
            let h2 = $('.performances[data-recording-id='+recordingId+']').children().first().after(result);
            let newForm = h2.next();
            $('form.new_performance').on("ajax:success", function(e, data, status, xhr) {
                submitNewPerformanceResponse(recordingId, e, data, status, xhr);
            });
            newForm.find('.performanceCreateCancelButton').click(function() {
                newForm.remove();
            })
        },
        error: function(xhr,status,error) {
            swal.fire({
                icon: 'error',
                title: "Ajax Error calling: /performances/ajax/edit/"+recordingId,
                text: error
            })
        }
    })
}
function submitNewPerformanceResponse(recordingId, e, data, status, xhr) {
    $(e.target).parent().replaceWith(xhr.responseText);
    rehookButtons();
    rehookAccordion();
}
function loadEditPerformanceForm(event) {
    let performanceId = event.target.getAttribute('data-performance-id');
    $.ajax({
        url: '../performances/ajax/edit/'+performanceId,
        success: function(result) {
            $(".perf_div[data-performance-id="+performanceId+"]").replaceWith(result);
            $(".performanceEditCancelButton[data-performance-id="+performanceId+"]").click(function(){
                cancelPerformanceEdit(performanceId);
            });
            $('form#edit_performance_'+performanceId).on("ajax:success", function(e, data, status, xhr) {
                submitPerformanceEditResponse(performanceId, e, data, status, xhr);
            })
        },
        error: function(xhr,status,error) {
            swal.fire({
                icon: 'error',
                title: "Ajax Error calling: /performances/ajax/edit/"+performanceId,
                text: error
            })
        }
    })
}
function cancelPerformanceEdit(performanceId) {
    $.ajax({
        url: '../performances/ajax/show/'+performanceId,
        success: function(result) {
            $(".performance_div[data-performance-id="+performanceId+"]").replaceWith(result);
            $(".editPerformanceButton[data-performance-id="+performanceId+"]").click(loadEditPerformanceForm);
            rehookAccordion();
        },
        error: function(xhr,status,error) {
            swal.fire({
                icon: 'error',
                title: "Ajax Error calling: /performances/ajax/edit/"+performanceId,
                text: error
            })
        }
    });
}
function submitPerformanceEditResponse(performanceId, e, data, status, xhr) {
    $(".edit_performance_div[data-performance-id="+performanceId+"]").replaceWith(xhr.responseText);
    rehookButtons();
    rehookAccordion();
}
/** END AJAX functionality for editing Performances */

/** AJAX functionality for CL/CM review comments history */
function hookRequestReviewButton() {
    $('#mark_needs_reviewed').click('');
}

function hookReviewCommentSlide() {
    $('#mark_needs_reviewed').hoverIntent(function() {
        let toggle = $('.toggle');
        if ( !toggle.is(":animated") ) {
            if (toggle.is(":visible")) {
                toggle.slideUp(200);
            } else {
                toggle.slideDown(200)
            }
        }
    });
}
/** END AJAX functionality for CL/CM review comments history */
/** AJAX functionality for Tracks */
function hookCreateTrackButtons() {
    $('.createTrackButton').click(createNewTrack);
}
function createNewTrack(event) {
    let performanceId = $(event.target).attr('data-performance-id');
    $.ajax({
        url: '../tracks/ajax/new/'+performanceId,
        success: function(result) {
            let h2 = $('.tracks[data-performance-id='+performanceId+']').children().first().after(result);
            let newForm = h2.next();
            hookHMSValidator(newForm);
            $('form.new_track').on("ajax:success", function(e, data, status, xhr) {
                submitNewTrackResponse(performanceId, e, data, status, xhr);
            });
            newForm.find('.trackCreateCancelButton').click(function() {
                newForm.remove();
            })
        },
        error: function(xhr,status,error) {
            swal.fire({
                icon: 'error',
                title: "Ajax Error calling: /performances/ajax/edit/"+performanceId,
                text: error
            })
        }
    })
}
function submitNewTrackResponse(performanceId, event, data, status, xhr) {
    if (status === "success") {
        let target = $(event.target);
        let parent = target.parent();
        parent.append(xhr.responseText);
        target.remove();
        rehookButtons();
    } else {

    }
}
function hookEditTrackButtons() {
    $('.editTrackButton').click(loadEditTrackForm);
}
function loadEditTrackForm(event) {
    let trackId = $(event.target).attr('data-track-id');
    $.ajax({
        url: '../tracks/ajax/edit/'+trackId,
        success: function(result) {
            $(".track_div[data-track-id="+trackId+"]").replaceWith(result);
            $(".trackEditCancelButton[data-track-id="+trackId+"]").click(function(){
                cancelTrackEdit(trackId);
            });
            $('form#edit_track_'+trackId).on("ajax:success", function(e, data, status, xhr) {
                submitTrackEditResponse(trackId, e, data, status, xhr);
            })
        },
        error: function(xhr,status,error) {
            swal.fire({
                icon: 'error',
                title: "Ajax Error calling: /tracks/ajax/edit/"+trackId,
                text: error
            })
        }
    })
}
function submitTrackEditResponse(trackId, event, data, status, xhr) {
    if (status === "success") {
        $(event.target).replaceWith(xhr.responseText);
        rehookButtons();
        rehookAccordion();
    } else {

    }
}

function cancelTrackEdit(trackId) {
    $.ajax({
        url: '../tracks/'+trackId,
        success: function(result) {
            $("#edit_track_"+trackId).replaceWith(result);
            $(".editTrackButton[data-track-id="+trackId+"]").click(loadEditTrackForm);
            rehookAccordion();
            rehookButtons();
        },
        error: function(xhr,status,error) {
            swal.fire({
                icon: 'error',
                title: "Ajax Error calling: /tracks/ajax/show/"+trackId,
                text: error
            })
        }
    })
}

function hookDeleteTrackButtons() {
    $('.deleteTrackButton').click(deleteTrack)
}
function deleteTrack(event) {
    Swal.fire({
        title: 'Confirm Track Delete',
        text: "Are you sure you want to permanently delete this Track?",
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#006298',
        confirmButtonText: 'Delete'
    }).then((result) => {
        if (result.value) {
            let trackId = $(event.target).attr('data-track-id');
            $.ajax({
                url: '../tracks/' + trackId,
                method: 'DELETE',
                success: function (result) {
                    $('.track_div[data-track-id=' + trackId + ']').remove();
                },
                error: function (xhr, status, error) {
                    swal.fire({
                        icon: 'warning',
                        title: "Ajax Error trying to delete Track",
                        text: xhr.responseText
                    })
                }
            })
        }
    })
}