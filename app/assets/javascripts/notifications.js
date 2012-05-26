$(function() {
	$("#check_all").on("click", function() {
		if($(this).is(":checked")) {
			$(".notification_delete").prop("checked", true);
		}
		else {
			$(".notification_delete").prop("checked", false);
		}
	});

	setInterval( function() { checkNotifications(); }, 30000 );
});

function checkNotifications() {
	$("#toolbar_notifications").load( $("#toolbar_notifications").data("ajax-url"), function () {
		var num_notifications = $("#new_notifications").html();

		if(num_notifications != null) {
			document.title = "["+num_notifications+"] Fish Tank Commander";
		}
		else {
			document.title = "Fish Tank Commander";
		}
	} );
}