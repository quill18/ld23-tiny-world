
$(function() {
	var is_my_turn = $("#player_id").val() ==  $("#current_player_id").val();

	$(".tool-button").on("click", function() {
		if(waiting_on_ajax)
			return;

		// This is just a generic cancel button right now
		$("table.map-game div.unit").removeClass("active");
		$("div.unit-button").removeClass("active");
		$(this).addClass("active");
	});
	$(".tool-button").first().addClass("active");
	
	$(".unit-button").on("click", function() {
		if(waiting_on_ajax)
			return;
		// Entering unit-building mode
		$("table.map-game div.unit").removeClass("active");

		$(".unit-button").removeClass("active");
		$(".tool-button").removeClass("active");
		$(this).addClass("active");
	});
	
	$("table.map-game").each(function() {
		///////// Tile Clicked
		$(this).find("td.tile").on("click", function() {
			if(waiting_on_ajax)
				return;
			var cell = $(this);

			// Are we in unit building mode?
			if(isUnitBuildingMode() && is_my_turn)
				addUnit(cell);

			if(isUnitMovementMode() && is_my_turn)
				moveUnitTo(cell);
		});

	});

	setupUnitClicking();
});

function setupUnitClicking() {
	///////// Unit Clicked
	$("table.map-game div.unit").off("click");
	$("table.map-game div.unit").on("click", function(e) {
		if(waiting_on_ajax)
			return;

		if(isUnitBuildingMode())
			return;

		// FIXME: Can only select our own units!

		e.preventDefault();

		var unit = $(this);
		console.log("Moving unit:");
		console.log(unit);

		$("table.map-game div.unit").removeClass("active");
		unit.addClass("active");

		return false;
	});

}

function isUnitBuildingMode() {
	if($(".unit-button.active").length > 0)
		return true;

	return false;
}

function isUnitMovementMode() {
	if($(".unit.active").length > 0)
		return true;

	return false;
}

function moveUnitTo(cell) {
	var unit = $(".unit.active").first();
	console.log("Unit for movement:")
	console.log(unit);
	console.log("Target cell:")
	console.log(cell);

	var url = cell.closest("table.map-game").attr("data-move-unit-path") + ".json";

	var x = cell.data("x");
	var y = cell.data("y");

	var fromCell = unit.closest("td");

	var fromX = fromCell.data("x");
	var fromY = fromCell.data("y");

	if( x < fromX ) {
		x = fromX - 1;
	}
	if( y < fromY ) {
		y = fromY - 1;
	}
	if( x > fromX ) {
		x = fromX + 1;
	}
	if( y > fromY ) {
		y = fromY + 1;
	}

	waiting_on_ajax = true;
	var jqxhr = $.get(url, { fromX: fromX, fromY: fromY, toX: x, toY: y }, function(results) {
		waiting_on_ajax = false;
		// Success
		console.log(results);

		if( results.x != null && results.y != null) {
			unit.detach();
			var real_cell = $("td.tile[data-x="+results.x+"][data-y="+results.y+"]")
			unit.appendTo(real_cell);
		}
		else if(results.message == false) {
			// do nothing
		}
		else {
			alert(results.message);
		}
	}).error(function() {
		waiting_on_ajax = false;
		alert("Server fail!");
	});

}

function addUnit(cell) {
	var new_tag = $(".unit-button.active").attr("data-unit_tag");

	if(new_tag == null) 
		return;

	var x = cell.attr("data-x");
	var y = cell.attr("data-y");

	var url = cell.closest("table.map-game").attr("data-add-unit-path") + ".json";

	waiting_on_ajax = true;
	var jqxhr = $.get(url, { x: x, y: y, unit_tag: new_tag }, function(results) {
		waiting_on_ajax = false;
		// Success
		console.log(results);

		if( results.unit_tag != null) {
			console.log($(this));
			$('<div class="unit" data-unit_tag="'+results.unit_tag+'"></div>').appendTo(cell);
			$("#money").html(results.money);
			$("#my_money").val(results.money);
			setupUnitClicking();
		}
		else {
			alert(results.message);
		}
	}).error(function() {
		waiting_on_ajax = false;
		alert("Server fail!");
	});
}

