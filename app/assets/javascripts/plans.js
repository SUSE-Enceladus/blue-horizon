$(function() {
  $("#submit-plan")
    .bind("ajax:beforeSend", function() {
      $("code.output").text("");
      $(this).addClass("no-hover");
      $(".eos-icon-loading").show();
    })
    .bind("ajax:success", function(evt) {
      $("code.output").text(evt.detail[0]);
    })
    .bind("ajax:complete", function() {
      $(this).removeClass("no-hover");
      $("a[href='/deploy']").removeClass("disabled");
      $(".eos-icon-loading").addClass("hide");
      $(".btn-info").removeClass("disabled");
    });
});
