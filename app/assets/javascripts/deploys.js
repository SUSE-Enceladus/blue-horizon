$(document).ready(function () {
  var intervalId = undefined;
  var finished = false;
  $('.eos-icon-loading').addClass('hide')

  $('#submit-deploy')
    .bind('ajax:beforeSend', function(evt, xhr, settings) {
      $('#output').text('')
      $(this).addClass('no-hover')
      $('.btn-secondary').addClass('no-hover')
      $('.btn-warning').addClass('no-hover')
      $('.eos-icon-loading').removeClass('hide');
      intervalId = setTimeout(function() {
	fetch_output(finished, intervalId)
      }, 5000)
    })
    .bind('ajax:success', function(evt, data, status, xhr) {
      $('#notice').html("<%= flash[:error] %>")
      if ($('#output').text().length > 0) {
	$('.eos-icon-loading').addClass('hide');
	clearTimeout(intervalId);
      }
      finished = true;
    })
    .bind('ajax:complete', function(evt, status, xhr) {
      $('.btn-secondary').removeClass('no-hover')
      $('.btn-warning').removeClass('disabled')
      $(this).removeClass('no-hover')

      if ($('#output').text().length > 0) {
	$('.eos-icon-loading').addClass('hide');
        clearTimeout(intervalId);
	finished = true;
      }
    })
    .bind('ajax:error', function(evt) {
      $('.eos-icons-loading').addClass('hide');
      clearTimeout(intervalId);
    });
});

function fetch_output(finished, intervalId) {
  $.ajax({
    type: 'GET',
    url: 'deploy/send_current_status',
    dataType: 'json',
    success: function(data) {

      if(data.success == false) {
	$('.eos-icon-loading').addClass('hide');
	// show rails flash message
	$('#error_message').text('Deploy operation has failed.')
	$('#flash').show()
	// show terraform error message in output section
	$('#output').text($('#output').text() + data.error)
	clearTimeout(intervalId);
      } else {
	$('.pre-scrollable').html(data.new_html)

	if (!finished) {
	  intervalId = setTimeout(function() {
	    fetch_output()
	  }, 5000);
	} else {
	  $('.eos-icon-loading').addClass('hide');
	}
      }
    },
    error: function() {
      console.log('Error calling deploy/send_current_status');
    }
  });
}
