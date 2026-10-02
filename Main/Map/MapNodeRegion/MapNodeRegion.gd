extends Node2D

class_name MapNodeRegion

func country_color_get()->Color:
	return (self.get_parent().get_parent().color_get());

@export var _is_sea:bool = false:
	set = _is_sea_set, get = is_sea_get;
func _is_sea_set(value:bool)->void:
	_is_sea = value;
func is_sea_get()->bool:
	return _is_sea;

var _start_position:Vector2 = Vector2.ZERO:
	set = _start_position_set , get = start_position_get;
func _start_position_set(value:Vector2)->void:
	_start_position = value;
func start_position_get()->Vector2:
	return _start_position;

var _centroid:Vector2 = Vector2.ZERO:
	set = _centroid_set, get = centroid_get;
func _centroid_set(value:Vector2)->void:
	_centroid = value;
func centroid_get()->Vector2:
	return _centroid;

var _rect:Rect2:
	set = _rect_set, get = rect_get;
func _rect_set(value:Rect2)->void:
	_rect = value;
func rect_get()->Rect2:
	return _rect;

var _area:float:
	set = _area_set, get = area_get;
func _area_set(value:float)->void:
	_area = value;
func area_get()->float:
	return _area;

func neighbours_get()->Array[Dictionary]:
	return GameServer.region_neighbour_connect_get_by_region_ids([self.region_id_get()]);

func region_id_get()->int:
	return ((self.get_name() as String) as int);
func country_id_get()->int:
	return (self.get_parent().get_parent().country_id_get());
func elements_get()->Array[Node]:
	return ($Elements.get_children() as Array[Node]);

var _region_name:String:
	set = _region_name_set, get = region_name_get;
func _region_name_set(value:String)->void:
	_region_name = value;
func region_name_get()->String:
	return _region_name;


enum SELECTOR {
	NONE = 0,
	REGION = 1,
	COUNTRY = 2,
	NEIGHBOUR = 3,
}
var _select:SELECTOR = SELECTOR.NONE:
	set = _select_set, get = select_get;
func _select_set(value:SELECTOR)->void:
	if _select == value:
		return;
	_select = value;
	match _select:
		SELECTOR.REGION:
			self._colorfull(Config.REGION_COLOR_SELECTED, -1);
		SELECTOR.COUNTRY:
			self._colorfull(Config.REGION_COLOR_SELECTED, -1);
		SELECTOR.NEIGHBOUR:
			self._colorfull(Config.REGION_NEIGHBOR, -2);
		SELECTOR.NONE:
			self._colorfull(self.country_color_get(), -3);
func select_get()->SELECTOR:
	return _select;
func select(value:SELECTOR)->SELECTOR:
	if self.select_get() == value:
		return self.select_get();
	var selector:SELECTOR = self.select_get();
	self._select_set(value);
	return selector;

func _colorfull(color:Color, zindex:int)->void:
	for child in self.elements_get():
		child.select(color);
		child.z_index = zindex;
	$RegionName.self_modulate = color.lightened(0.6);

func is_polygon_in_polygon(poly:PackedVector2Array)->bool:
	for elem in self.elements_get():
		if elem.is_polygon_in_polygon(poly):
			return true;
	return false;

func region_dto_get()->RegionDTO:
	return RegionDTO.new(
		self.region_id_get(),
		self.country_id_get(),
		self.region_name_get(),
		self.is_sea_get()
	);

func region_name_visible_set(value:bool)->void:
	$RegionName.visible = value;

func _ready()->void:
	self._start_position_set(self.position);
	self._colorfull(self.country_color_get(), -3);
	var centroid:Vector2;
	var count:int = 0;
	var area:float = 0.0;
	var rect:Rect2 = self.elements_get()[0].rect_get();
	for element in self.elements_get():
		rect = rect.merge(element.rect_get());
		@warning_ignore("unassigned_variable_op_assign")
		centroid += element.centroid_get();
		area += element.area_get();
		count +=1;
	self._centroid_set(centroid/count);
	self._rect_set(rect);
	self._area_set(area);
	self._region_name_set($RegionName.text.replace("\n"," "));
	if self.region_name_get() == 'Region Name':
		push_error("Noname region found %s" % [self.region_id_get()]);
	$RegionName.label_settings = GlobalFont.label_setting_get($RegionName.get("theme_override_font_sizes/font_size"));
	$RegionName.remove_theme_font_size_override("font_size");
	if $Elements.connect("input_event", Callable(self, '_on_input_event')) != OK:
		push_error('not connected input region events');

func _on_input_event(_viewport, event:InputEvent, _shape_idx:int)->void:
	if !(event is InputEventScreenTouch):
		return;
	if event.is_echo():
		return;
	if !event.is_released():
		return;
	GloabalSignal.emit_signal('region_node__region_click', self.region_id_get(), self.country_id_get());
#
