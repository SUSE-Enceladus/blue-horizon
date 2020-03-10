$(function() {
  var intervalId = undefined;
  var finished = false;

  $("#submit-deploy")
    .bind("ajax:beforeSend", function() {
      $("#output").text("");
      $(this).addClass("no-hover");
      $(".steps-container .btn").addClass("disabled");
      $(".list-group-flush a").addClass("disabled");
      $(".eos-icon-loading").removeClass("hide");
      $("a[data-toggle]").tooltip("hide");
      intervalId = setTimeout(function() {
        fetch_output(finished, intervalId);
      }, 5000);
    })
    .bind("ajax:success", function() {
      $("#notice").html("<%= flash[:error] %>");
      if ($("#output").text().length > 0) {
        clearTimeout(intervalId);
      }
      finished = true;
    })
    .bind("ajax:complete", function() {
      $(this).removeClass("no-hover");
      if ($("#output").text().length > 0) {
        clearTimeout(intervalId);
        finished = true;
      }
    })
    .bind("ajax:error", function() {
      $(".eos-icons-loading").addClass("hide");
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
        $(".eos-icon-loading").addClass("hide");
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
	  $(".steps-container .btn").removeClass("disabled");
	  $(".list-group-flush a").removeClass("disabled");
	  $(".eos-icon-loading").addClass("hide");
        }
      }
    },
    error: function() {
      console.log("Error calling deploy/send_current_status");
    }
  });
}
