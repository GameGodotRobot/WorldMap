extends Panel

class_name ProductionPrice

var _product_type_id:int:
	set = _product_type_id_set, get = product_type_id_get;
func _product_type_id_set(value:int)->void:
	_product_type_id = value;
func product_type_id_get()->int:
	return _product_type_id;

var _product_name:String:
	set = _product_name_set, get = product_name_get;
func _product_name_set(value:String)->void:
	_product_name = value;
func product_name_get()->String:
	return _product_name;

var _price:float:
	set = _price_set, get = price_get;
func _price_set(value:float)->void:
	_price = value;
func price_get()->float:
	return _price;

var _income:float:
	set = _income_set, get = income_get;
func _income_set(value:float)->void:
	_income = value;
func income_get()->float:
	return _income;

var _outcome:float:
	set = _outcome_set, get = outcome_get;
func _outcome_set(value:float)->void:
	_outcome = value;
func outcome_get()->float:
	return _outcome;

var _unit_price:float:
	set = _unit_price_set, get = unit_price_get;
func _unit_price_set(value:float)->void:
	_unit_price = value;
func unit_price_get()->float:
	return _unit_price;

func init(product_type_id:int,
		product_name:String, 
		price:float, 
		income:float, 
		outcome:float, 
		unit_price:float)->void:
	self._product_type_id_set(product_type_id);
	self._product_name_set(product_name);
	self._price_set(price);
	self._income_set(income);
	self._outcome_set(outcome);
	self._unit_price_set(unit_price);
	
	$Name.text = '%s: %.2f$'%[self.product_name_get(), self.price_get()];
