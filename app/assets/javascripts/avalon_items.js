
function hookButtons() {
    hookEditRecordings();
    hookCreateEditPerformances();
    hookDeletePerformanceButtons()
}
function rehookButtons() {
    $(".editRecordingButton").unbind('click', editRecording).click(editRecording);
    $('.createPerformanceButton').unbind('click', loadNewPerformance).click(loadNewPerformance);
    $('.editPerformanceButton').unbind('click', loadEditPerformanceForm).click(loadEditPerformanceForm);
    $('.deletePerformanceButton').unbind('click', deletePerformance).click(deletePerformance);
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
    Swal.fire({
        title: 'Confirm Performance Delete',
        text: "Are you sure you want to permanently delete this Performance? Performances that have associated Tracks will not be deleted",
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#006298',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Delete'
    }).then((result) => {
        if (result.value) {
            let performanceId = $(event.target).attr('data-performance-id');
            $.ajax({
                url: '../performances/'+performanceId,
                method: 'DELETE',
                success: function(result) {
                    $('.perf_div[data-performance-id='+performanceId+']').remove();
                },
                error: function(xhr,status,error) {
                    swal.fire({
                        icon: '',
                        title: "Ajax Error trying to delete Performance",
                        text: xhr.responseText
                    })
                }
            })
        }
    })
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