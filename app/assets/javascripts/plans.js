$(function() {
  $('#submit-plan')
    .bind('ajax:beforeSend', function() {
      $('code.output').text('');
      $(this).addClass('no-hover');
      $('.btn-secondary').addClass('disabled');
      $('.eos-icon-loading').show();
    })
    .bind('ajax:success', function(evt) {
      $('code.output').text(evt.detail[0]);
    })
    .bind('ajax:complete', function() {
      $(this).removeClass('no-hover');
      $('.btn-secondary').removeClass('disabled');
      $("a[href='/deploy']").removeClass('disabled');
      $('.eos-icon-loading').addClass('hide');
    });
});
