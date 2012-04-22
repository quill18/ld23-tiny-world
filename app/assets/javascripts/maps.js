$(function() {
	/*  MAP EDITING FUNCTIONS   */
	$("table.map-edit").each(function() {
		$(this).find("td.tile").on("click", function() {
			var new_tag = $(".tile-button.active").attr("data-tile_type_tag");

			$(this).attr("data-tile_type_tag", new_tag);
			$(this).children("input").val(new_tag);
		});
	});

	$(".tile-button").on("click", function() {
		$(".tile-button").removeClass("active");
		$(this).addClass("active");
	});

	$(".tile-button").first().addClass("active");

	$("#clear-map").on("click", function() {
		var default_tag = "open-water";
		if(confirm("Clear map?")) {
			$("table.map-edit td.tile").each(function() {
				$(this).attr("data-tile_type_tag", default_tag);
			});
		}
	});

	/* Map Voting */
	setupMapVoting();
});

function setupMapVoting() {
	$(".vote-button").on("click", function() {
		var vote = $(this).data("vote");
		var parent = $(this).closest("div.map-voting");
		var url = parent.data("ajax-url");
		parent.load(url, { vote: vote }, function() {
			setupMapVoting();
		});
	});

}