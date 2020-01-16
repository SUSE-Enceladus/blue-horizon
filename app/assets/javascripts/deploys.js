$(function() {
	$.ajax({
	    type: 'GET',
	    url: 'deploy/pre_deploy',
	    dataType: 'json',
	    success: function(data) {
		if (data.error) {
		    $('#error_message').html(data.error);
		    $('#flash').show();
		}
	    },
	    error: function() {
		var message = 'Error calling deploy/pre_deploy';
		$('#error_message').html(message);
		$('#flash').show();
	    	console.log(message);
	    }
	});

	// show the output of terraform apply periodically
	setInterval(function () {
	    $.ajax({
		type: 'GET',
		url: 'deploy/send_current_status',
		dataType: 'json',
		success: function(data) {
		    var editor;
		    var editor_id = '#editor';

    		    if (editor_id.charAt(0) === '#') {
    			editor = ace.edit(editor_id.substr(1));
    		    } else {
    			editor = ace.edit(editor_id);
    		    }

    		    if (data.info.length) {
			editor.setTheme("ace/theme/terminal");
    			editor.setOption('fontSize', '13pt');
    			editor.setOption('vScrollBarAlwaysVisible', true);
    			editor.getSession().setUseWrapMode(true);
    			$(editor_id).show();

			var form_field = $(editor_id);
			data.info = data.info.replace(/\u001b\[1m/g, '');
			data.info = data.info.replace(/\u001b\[0m/g, '');
			if (data && data.info != '') {
			    editor.setValue(data.info);
			}
		    }
		},
		error: function() {
		    console.log('Error calling deploy/send_current_status');
		}
	    });
	} , 5000);
});
