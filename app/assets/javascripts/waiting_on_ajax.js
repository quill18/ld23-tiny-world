var waiting_on_ajax = false;
var overlay_timer = null;

function ajax_start() {
	waiting_on_ajax = true;

	if(overlay_timer != null)
		clearTimeout(overlay_timer);

	overlay_timer = setTimeout(function() { $("#ajax_waiting").show(); }, 250);
}

function ajax_stop() {
	waiting_on_ajax = false;
	clearTimeout(overlay_timer);
	overlay_timer = null;
	$("#ajax_waiting").hide();
}

function ajax_waiting() {
	return waiting_on_ajax;
}

