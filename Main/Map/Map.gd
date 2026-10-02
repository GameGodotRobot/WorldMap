extends Node2D

class_name Map

func _ready()->void:
	$TextureRect.texture = null;

func country_download_server()->void:
	var arr:Array[CountryDTO];
	for country in $Countries.get_children():
		arr.append(country.country_dto_get());
	GameServer.country_insert(arr);

func region_download_server()->void:
	var arr:Array[RegionDTO];
	for country in $Countries.get_children():
		for region in country.regions_get():
			arr.append(region.region_dto_get());
	GameServer.region_insert(arr);

func region_neighbour_connect_download_server()->void:
	var arr:Array[RegionNeighbourConnectDTO];
	for country in $Countries.get_children():
		for region in country.regions_get():
			arr.append_array($Countries._find_region_neighbours2(region));
	if !arr:
		return;
	GameServer.region_neighbour_connect_insert(arr);

func _unhandled_input(event)->void:
	if event.is_echo():
		return;
	if !(event is InputEventScreenTouch):
		return;
	if !event.is_released():
		return;
	GloabalSignal.emit_signal("map__click");
