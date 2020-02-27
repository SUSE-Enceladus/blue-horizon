$(document).ready(function () {
  $('#submit-plan')
    .bind('ajax:beforeSend', function(evt, xhr, settings) {
      $('code.output').text('')
      $(this).addClass('no-hover')
      $('.btn-secondary').addClass('no-hover')
      $('.loader').show();
    })
    .bind('ajax:success', function(evt, data, status, xhr) {
      $('code.output').text(JSON.stringify(evt.detail[0], null, 2))
    })
    .bind('ajax:complete', function(evt, status, xhr) {
      $(this).removeClass('no-hover')
      $('.btn-secondary').removeClass('no-hover')
      $('.btn-warning').removeClass('disabled')
      $('.loader').hide();
    })
})
