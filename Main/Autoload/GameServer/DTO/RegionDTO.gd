extends RefCounted

class_name RegionDTO

var _region_id:int:
	set = _region_id_set, get = region_id_get;
func _region_id_set(values:int)->void:
	_region_id = values;
func region_id_get()->int:
	return _region_id;

var _country_id:int:
	set = _country_id_set, get = country_id_get;
func _country_id_set(values:int)->void:
	_country_id = values;
func country_id_get()->int:
	return _country_id;

var _region_name:String:
	set = _region_name_set, get = region_name_get;
func _region_name_set(values:String)->void:
	_region_name = values.replace("'","''");
func region_name_get()->String:
	return _region_name;
	
var _is_sea:int:
	set = _is_sea_set, get = is_sea_get;
func _is_sea_set(values:int)->void:
	_is_sea = values;
func is_sea_get()->int:
	return _is_sea;

func _init(
			region_id:int,
			country_id:int,
			region_name:String,
			is_sea:bool
		)->void:
	self._region_id_set(region_id);
	self._country_id_set(country_id);
	self._region_name_set(region_name);
	self._is_sea_set(is_sea);

func dto_get()->Dictionary:
	return {
			'region_id':self.region_id_get(),
			'country_id':self.country_id_get(), 
			'region_name':self.region_name_get(),
			'is_sea':self.is_sea_get()
	}
