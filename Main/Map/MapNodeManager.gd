extends Area2D

class_name MapNodeManager

## расположение текста внутри нод 

var _current_region_id:int = 0:
	set = _current_region_id_set, get = current_region_id_get;
func _current_region_id_set(value:int)->void:
	if _current_region_id == value:
		return;
	_current_region_id = value;
	for child in self.get_children():
		child.is_selected_set(child.region_id_get() == _current_region_id);
func current_region_id_get()->int:
	return _current_region_id;

func _ready()->void:
	pass

func _input_event(_viewport, event:InputEvent, shape_idx:int)->void:
	if !(event is InputEventScreenTouch):
		return;
	if event.is_echo():
		return;
	if !event.is_released():
		return;
	var owner_id:int = self.shape_find_owner(shape_idx);
	self._current_region_id_set(self.shape_owner_get_owner(owner_id).region_id_get());
