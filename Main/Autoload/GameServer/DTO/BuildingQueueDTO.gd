extends RefCounted

class_name BuildingQueueDTO

var _region_id:int:
	set = _region_id_set, get = region_id_get;
func _region_id_set(values:int)->void:
	_region_id = values;
func region_id_get()->int:
	return _region_id;

var _manufacture_type_id:int:
	set = _manufacture_type_id_set, get = manufacture_type_id_get;
func _manufacture_type_id_set(values:int)->void:
	_manufacture_type_id = values;
func manufacture_type_id_get()->int:
	return _manufacture_type_id;

func _init(region_id:int, manufacture_type_id:int)->void:
	self._region_id_set(region_id);
	self._manufacture_type_id_set(manufacture_type_id);
	
func dto_get()->Dictionary:
	return {
		"region_id":self.region_id_get(),
		"manufacture_type_id":self.manufacture_type_id_get()
	}
