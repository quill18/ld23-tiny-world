var is_my_turn = false;

$(function() {
	is_my_turn = $("#player_id").val() ==  $("#current_player_id").val();

	$(".tool-button").on("click", function() {
		if(ajax_waiting())
			return;

		// This is just a generic cancel button right now
		cancelModes();
		$(this).addClass("active");	
	});
	$(".tool-button").first().addClass("active");
	
	$(".unit-button").on("click", function() {
		if(ajax_waiting())
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
			if(ajax_waiting())
				return;
			var cell = $(this);

			// Are we in unit building mode?
			if(isUnitBuildingMode() && is_my_turn)
				addUnit(cell);

			if(isUnitMovementMode() && is_my_turn)
				moveUnitTo(cell);
		});

	});

	$("table.map-game td.tile").off("mouseenter");
	$("table.map-game td.tile").on("mouseenter", function(e) {
		$("div.tile_type_info").hide();
		var tag = $(this).attr("data-tile_type_tag");
		$("div.tile_type_info[data-tile_type_tag="+tag+"]").show();
	});
	
	$("table.map-game td.tile").off("mouseleave");
	$("table.map-game td.tile").on("mouseleave", function(e) {
		$("div.tile_type_info").hide();
	});


	setupUnitClicking();
	setupUnitHealthBars();
});

function cancelModes() {
	$("table.map-game div.unit").removeClass("active");
	$("div.unit-button").removeClass("active");
}

function setupUnitHealthBars() {
	$("table.map-game div.unit div.healthbar").each(function () {
		$(this).width($(this).data("percentage")+"%");
		$(this).removeClass("low");
		$(this).removeClass("critical");

		if($(this).data("percentage") <= 60) {
			$(this).addClass("low");
		}
		if($(this).data("percentage") <= 30) {
			$(this).addClass("critical");
		}
	});
}

function setupUnitClicking() {
	///////// Unit Clicked
	$("table.map-game div.unit").off("click");
	$("table.map-game div.unit").on("click", function(e) {
		if(ajax_waiting() || is_my_turn==false)
			return;


		if(isUnitBuildingMode()) {
			//cancelModes();
			return;
		}

		if($(this).data("team_id") != parseInt($("#current_team_id").val()))
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

	$("table.map-game div.unit").off("mouseenter");
	$("table.map-game div.unit").on("mouseenter", function(e) {
		$("div.unit_info").hide();
		var tag = $(this).attr("data-unit_tag");
		$("div.unit_info[data-unit_tag="+tag+"]").show();
	});

	$("table.map-game div.unit").off("mouseleave");
	$("table.map-game div.unit").on("mouseleave", function(e) {
		$("div.unit_info").hide();
	});

	$("div.game_tools div.unit-button").off("mouseenter");
	$("div.game_tools div.unit-button").on("mouseenter", function(e) {
		$("div.unit_info").hide();
		var tag = $(this).attr("data-unit_tag");
		$("div.unit_info[data-unit_tag="+tag+"]").show();
	});

	$("div.game_tools div.unit-button").off("mouseleave");
	$("div.game_tools div.unit-button").on("mouseleave", function(e) {
		$("div.unit_info").hide();
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

	ajax_start();
	var jqxhr = $.get(url, { fromX: fromX, fromY: fromY, toX: x, toY: y }, function(results) {
		ajax_stop();
		processJSON(results);
	}).error(function() {
		ajax_stop();
		alert("Server fail!");
	});

}

function processJSON(results) {
	// Success
	console.log("AJAX RESULTS:");
	console.log(results);

	var game_units = results.game_units;

	if( game_units != null ) {
		for(i=0; i < game_units.length; i++) {

			var game_unit = game_units[i];

			// Find the unit if it already exists

			var unit = $("[data-unit_id="+game_unit.id+"]");
			unit.detach();

			if(unit.length == 0) {
				// We need to create the unit
				unit = $('<div class="unit" data-unit_id="'+game_unit.id+'" data-unit_tag="'+game_unit.unit.tag+'" data-team_id="'+game_unit.team_id+'"></div>');
				var healthbar = $('<div class="healthbar" data-percentage="0">');
				healthbar.appendTo(unit);

				var shield = $('<div class="shield"><span class="movement">0</span></div>');
				shield.appendTo(unit);
			}

			var percentage = 100*game_unit.current_hitpoints/game_unit.unit.hitpoints;
			unit.find(".healthbar").attr("data-percentage", percentage);

			unit.find(".movement").html(game_unit.movement_left);

			if (game_unit.current_hitpoints > 0) {
				var real_cell = $("td.tile[data-x="+game_unit.x+"][data-y="+game_unit.y+"]")
				unit.appendTo(real_cell);
			}
			else {
				// Something has died
			}
		}
	}

	if (results.kills != null ) {
		console.log("KILLS:");
		console.log(results.kills);
		for(var key in results.kills) {
			$("#"+key).html(results.kills[key]);
		}
	}

	if (results.units != null ) {
		console.log("UNITS:");
		console.log(results.units);
		for(var key in results.units) {
			$("#"+key).html(results.units[key]);
		}
	}

	if (results.money != null ) {
		for(var key in results.money) {
			$("#"+key).html(results.money[key]);
		}
	}

	if (results.message != null ) {
		alert(results.message);
	}

	setupUnitClicking();
	setupUnitHealthBars();
}

function addUnit(cell) {
	var new_tag = $(".unit-button.active").attr("data-unit_tag");

	if(new_tag == null) 
		return;

	var x = cell.attr("data-x");
	var y = cell.attr("data-y");

	var url = cell.closest("table.map-game").attr("data-add-unit-path") + ".json";

	ajax_start();
	var jqxhr = $.get(url, { x: x, y: y, unit_tag: new_tag }, function(results) {
		ajax_stop();
		// Success

		processJSON(results);

	}).error(function() {
		ajax_stop();
		alert("Server fail!");
	});
}

