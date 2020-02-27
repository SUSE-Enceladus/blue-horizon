$(function(){
	// Remove map entries
	$('form#new_variable').on('click', ".remove", function(){
		$(this).closest(".input-group").remove();
	});
	// Prevent submitting with Enter key
	$(document).on("keydown", ":input:not(textarea)", function(event) {
    if (event.key == "Enter") {
        event.preventDefault();
    }
	});
});
