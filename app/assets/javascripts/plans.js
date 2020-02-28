$(function() {
  $("#submit-plan")
    .bind("ajax:beforeSend", function() {
      $("code.output").text("");
      $(this).addClass("no-hover");
      $(".eos-icon-loading").show();
    })
    .bind('ajax:success', function(evt) {
      var output = evt.detail[0];
      if (output.error) {
	$('#flash').show();
	$('#error_message').text(output.error)
     }
      else {
	$('code.output').text(output);
      }
    })
    .bind("ajax:complete", function() {
      $(this).removeClass("no-hover");
      $("a[href='/deploy']").removeClass("disabled");
      $(".eos-icon-loading").addClass("hide");
      $(".btn-info").removeClass("disabled");
    });
});
