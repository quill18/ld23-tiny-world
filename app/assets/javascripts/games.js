$(function() {
	$(".tool-button").on("click", function() {
		$(".unit-button").removeClass("active");
		$(this).addClass("active");
	});
	$(".tool-button").first().addClass("active");
	
	$(".unit-button").on("click", function() {
		$(".unit-button").removeClass("active");
		$(".tool-button").removeClass("active");
		$(this).addClass("active");
	});
	
	$("table.map-game").each(function() {
		$(this).find("td.tile").on("click", function() {
			var cell = $(this);

			var new_tag = $(".unit-button.active").attr("data-unit_tag");
			var x = $(this).attr("data-x");
			var y = $(this).attr("data-y");

			var url = $(this).closest("table.map-game").attr("data-add-unit-path") + ".json";


			var jqxhr = $.get(url, { x: x, y: y, unit_tag: new_tag }, function(results) {
				// Success
				console.log(results);

				if( results.unit_tag !== null) {
					console.log($(this));
					$('<div class="unit" data-unit_tag="'+results.unit_tag+'"></div>').appendTo(cell);
					$("#money").html(results.money);
				}
				else {
					alert(results.message);
				}
			}).error(function() {
				alert("Server fail!");
			});
		});
	});
});
