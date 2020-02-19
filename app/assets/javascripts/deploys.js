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
			if (data && data.info != '') {
				data.info = data.info.replace(/\u001b\[(\d+)m/g, '');
				$('#output').text(data.info)
			}
		},
		error: function() {
		    console.log('Error calling deploy/send_current_status');
		}
	    });
	} , 5000);
});
