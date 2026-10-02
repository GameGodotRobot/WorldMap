extends RefCounted

class_name NeighbourConnect

var _sea_distance:float:
	set = _sea_distance_set, get = sea_distance_get;
func _sea_distance_set(values:float)->void:
	_sea_distance = values;
func sea_distance_get()->float:
	return _sea_distance;

var _land_distance:float:
	set = _land_distance_set, get = land_distance_get;
func _land_distance_set(values:float)->void:
	_land_distance = values;
func land_distance_get()->float:
	return _land_distance;

func _init(sea_distance:float, land_distance:float)->void:
	self._sea_distance_set(sea_distance);
	self._land_distance_set(land_distance);
