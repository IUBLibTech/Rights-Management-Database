function hookEditRecordings() {
    $(".editRecordingButton").click(function() {
        loadEditRecordingForm($(this).attr('data-recording-id'));
    });
}

function loadEditRecordingForm(recordingId) {
    $.ajax({
        url: '../recordings/ajax/edit/'+recordingId,
        success: function(result) {
            $(".recording_div[data-recording-id="+recordingId+"]").replaceWith(result);
            $(".recordingEditCancelButton[data-recording-id="+recordingId+"]").click(function(){
                cancelRecordingEdit(recordingId);
            });
            $('form#edit_recording_'+recordingId).on("ajax:success", function(e, data, status, xhr) {
                submitRecordingEditResponse(recordingId, e, data, status, xhr);
            })
        },
        error: function(xhr,status,error) {
            swal.fire({
                icon: 'error',
                title: "Ajax Error calling: /recordings/ajax/edit/"+recordingId,
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
            $(".editRecordingButton[data-recording-id="+recordingId+"]").click(function(){
                loadEditRecordingForm(recordingId);
            });
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
    $(".editRecordingButton").unbind('click').click(function() {
        loadEditRecordingForm($(this).attr('data-recording-id'));
    });
    rehookAccordion();
}