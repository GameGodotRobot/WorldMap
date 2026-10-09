extends RefCounted

class_name CountryDTO

var _country_id:int:
	set = _country_id_set, get = country_id_get;
func _country_id_set(values:int)->void:
	_country_id = values;
func country_id_get()->int:
	return _country_id;

var _country_name:String:
	set = _country_name_set, get = country_name_get;
func _country_name_set(values:String)->void:
	_country_name = values.replace("'","''");
func country_name_get()->String:
	return _country_name;

func _init(
			country_id:int,
			country_name:String
		)->void:
	self._country_id_set(country_id);
	self._country_name_set(country_name);

func dto_get()->Dictionary:
	return {
			'country_id':self.country_id_get(), 
			'country_name':self.country_name_get()
	}
