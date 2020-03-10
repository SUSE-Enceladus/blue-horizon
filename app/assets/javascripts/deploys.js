$(function() {
  var intervalId = undefined;
  var finished = false;
  $(".eos-icon-loading").hide();

  $("#submit-deploy")
    .bind("ajax:beforeSend", function() {
      $("#output").text("");
      $(this).addClass("no-hover");
      $(".btn-secondary").addClass("disabled");
      $("a[href='/download']").addClass("disabled");
      $(".eos-icon-loading").show();
      $("a[data-toggle]").tooltip("hide");
      intervalId = setTimeout(function() {
        fetch_output(finished, intervalId);
      }, 5000);
    })
    .bind("ajax:success", function() {
      $("#notice").html("<%= flash[:error] %>");
      if ($("#output").text().length > 0) {
        $(".eos-icon-loading").addClass("hide");
        clearTimeout(intervalId);
      }
      finished = true;
    })
    .bind("ajax:complete", function() {
      $(".btn-secondary").removeClass("disabled");
      $("a[href='/wrapup']").removeClass("disabled");
      $(this).removeClass("no-hover");
      if ($("#output").text().length > 0) {
        $(".eos-icon-loading").hide();
        clearTimeout(intervalId);
        finished = true;
      }
    })
    .bind("ajax:error", function() {
      $(".eos-icons-loading").hide();
      clearTimeout(intervalId);
    });
});

function fetch_output(finished, intervalId) {
  $.ajax({
    type: "GET",
    url: "deploy/send_current_status",
    dataType: "json",
    success: function(data) {
      if (data.error !== null) {
        $(".eos-icon-loading").hide();
        // show rails flash message
        $("#error_message").text("Deploy operation has failed.");
        $("#flash").show();
        // show terraform error message in output section
        $("#output").text($("#output").text() + data.error);
        clearTimeout(intervalId);
      } else {
	$(".pre-scrollable").html(data.new_html);
	if (!finished && !data.success) {
          intervalId = setTimeout(function() {
	    fetch_output();
          }, 5000);
        } else {
          $(".eos-icon-loading").addClass("hide");
        }
      }
    },
    error: function() {
      console.log("Error calling deploy/send_current_status");
    }
  });
}
