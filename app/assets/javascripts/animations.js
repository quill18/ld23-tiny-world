$(function() {

	setInterval( function() { doAnimation() }, 250 );


});

function doAnimation() {
	doBubbleAnimation();
	//doFishAnimation();
}

function doBubbleAnimation() {
	$("td.tile[data-tile_type_tag=bubbles]").each(function() {
		var variant = parseInt($(this).attr("data-tile-variant"));
		variant += 1;
		if(variant > 2) {
			variant = 0;
		}
		$(this).attr("data-tile-variant", variant);
	});
}

/*function doFishAnimation() {
	$("td.tile div.unit").each(function() {
		$(this).style("top", "5px;");
	});
}*/