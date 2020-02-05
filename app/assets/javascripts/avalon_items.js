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
            $(".recordingEditCancelButton['data-recording-id='"+recordingId+"]").click(function(){
                cancelRecordingEdit(recordingId);
            });
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
            $(".editRecordingButton['data-recording-id='"+recordingId+"]").click(function(){
                cancelRecordingEdit(recordingId);
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