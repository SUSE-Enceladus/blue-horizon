$(function() {
  var intervalId = undefined;
  var finished = false;

  $("#submit-deploy")
    .bind("ajax:beforeSend", function() {
      $("#output").text("");
      $(this).addClass("no-hover");
      $(".float-right .steps-container .btn").addClass("disabled");
      $(".list-group-flush a").addClass("disabled");
      $("#loading").show();
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
      $("#loading").hide();
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
        $("#loading").hide();
        // show rails flash message
        $("#error_message").text("Deploy operation has failed.");
        $("#flash").show();
        // show terraform error message in output section
        $("#output").text($("#output").text() + data.error);
        clearTimeout(intervalId);
        $(".steps-container .btn.disabled").removeClass("disabled");
        $("#loading").hide();
      } else {
        $(".pre-scrollable").html(data.new_html);
        var autoscroll = $("#deploy_log_autoscroll").prop("checked");
        if (autoscroll) {
          $(".pre-scrollable").scrollTop($("#output").height());
        }
        if (!finished && !data.success) {
          intervalId = setTimeout(function() {
            fetch_output();
          }, 5000);
        } else {
          $(".steps-container .btn.disabled").removeClass("disabled");
          $("#loading").hide();
        }
      }
    },
    error: function(data) {
      var endIndex = data.responseText.indexOf("#");
      if (endIndex == -1) endIndex = data.responseText.indexOf("\n");
      $("#error_message").text(data.responseText.substring(0, endIndex));
      $("#flash").show();
      $(".steps-container .btn.disabled").removeClass("disabled");
      $("#loading").hide();
    }
  });

  $("#flash .close").click(function() {
    $("#flash").hide();
  });
}
