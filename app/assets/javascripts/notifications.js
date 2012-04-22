$(function() {
	$("#check_all").on("click", function() {
		if($(this).is(":checked")) {
			$(".notification_delete").prop("checked", true);
		}
		else {
			$(".notification_delete").prop("checked", false);
		}
	});

	
});