$(function(){
	// Remove map entries
	$('form#new_variable').on('click', ".remove", function(){
		$(this).closest(".input-group").remove();
	});
});
