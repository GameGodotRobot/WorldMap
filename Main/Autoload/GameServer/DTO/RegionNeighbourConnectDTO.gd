extends RefCounted

class_name RegionNeighbourConnectDTO

var _region_id:int:
	set = _region_id_set, get = region_id_get;
func _region_id_set(values:int)->void:
	_region_id = values;
func region_id_get()->int:
	return _region_id;

var _neighbour_region_id:int:
	set = _neighbour_region_id_set, get = neighbour_region_id_get;
func _neighbour_region_id_set(values:int)->void:
	_neighbour_region_id = values;
func neighbour_region_id_get()->int:
	return _neighbour_region_id;

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

func _init(
		region_id:int,
		neighbour_region_id:int,
		sea_distance:float,
		land_distance:float
	)->void:
	self._region_id_set(region_id);
	self._neighbour_region_id_set(neighbour_region_id);
	self._sea_distance_set(sea_distance);
	self._land_distance_set(land_distance);

func dto_get()->Dictionary:
	return {
			'region_id':self.region_id_get(),
			'neighbour_region_id':self.neighbour_region_id_get(), 
			'sea_distance':self.sea_distance_get(),
			'land_distance':self.land_distance_get()
	}
