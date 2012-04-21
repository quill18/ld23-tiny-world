$(function() {
	$("table.map-edit").each(function() {
		var tile_type_tags = $(this).data("tile-type-tags");
		console.log(tile_type_tags);

		$(this).find("td.tile").on("click", function() {
			var old_tag = $(this).attr("data-tile_type_tag");
			var new_tag = null;

			for(i=0; i < tile_type_tags.length; i++) {
				if(tile_type_tags[i] == old_tag && i < tile_type_tags.length-1) {
					new_tag = tile_type_tags[i+1];
				}
			}

			if (new_tag == null) {
				new_tag = tile_type_tags[0];
			}

			$(this).attr("data-tile_type_tag", new_tag);
			$(this).children("input").val(new_tag);
		});
	});

});