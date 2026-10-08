extends Node2D

class_name MapNodeCountry

@export var _color:Color = '#fa479d':
	get = color_get;
func color_get()->Color:
	return _color;

@export var _zoom:float = 0.0:
	get = zoom_get;
func zoom_get()->float:
	return _zoom;

var _country_name:String:
	set = _country_name_set, get = country_name_get;
func _country_name_set(value:String)->void:
	_country_name = value;
func country_name_get()->String:
	return _country_name;

func country_id_get()->int:
	return ((self.get_name() as String) as int);
func regions_get()->Array:
	return $Regions.get_children();

func country_dto_get()->CountryDTO:
	return CountryDTO.new(
		self.country_id_get(),
		self.country_name_get()
	);

enum STATE {
	NONE = 0,
	REGION = 1,
	COUNTRY = 2
}
var _state:STATE = STATE.NONE:
	set = _state_set, get = state_get;
func _state_set(value:STATE)->void:
	if _state == value:
		return;
	_state = value;
	match _state:
		STATE.REGION:
			$CountryName.visible = false;
			for region in self.regions_get():
				region.region_name_visible_set(true);
		STATE.COUNTRY:
			$CountryName.visible = true;
			for region in self.regions_get():
				region.region_name_visible_set(false);
func state_get()->STATE:
	return _state;

func _ready()->void:
	self.show();
	self._country_name_set($CountryName.text.replace("\n"," "));
	$CountryName.label_settings = GlobalFont.label_setting_get($CountryName.get("theme_override_font_sizes/font_size"));
	$CountryName.remove_theme_font_size_override("font_size");
	$CountryName.self_modulate = self.color_get().lightened(0.6);
	if GloabalSignal.connect("camera__zoom_change", Callable(self, "_on_zoom_change")) != OK:
		push_error('not connected zoom_change');
	if GloabalSignal.connect('region_node__region_click', Callable(self, '_on_region_clicked')) != OK:
		push_error('not connected input region events');
	if GloabalSignal.connect('map__click', Callable(self, '_on_map_clicked')) != OK:
		push_error('not connected input map events');

func _on_zoom_change(zoom:Vector2)->void:
	@warning_ignore("integer_division")
	if Camera._MAX_ZOOM/zoom.x >= self.zoom_get():
		self._state_set(STATE.COUNTRY);
	else:
		self._state_set(STATE.REGION);

func _on_map_clicked()->void:
	var select:MapNodeRegion.SELECTOR = MapNodeRegion.SELECTOR.NONE;
	var select_region:MapNodeRegion;
	for region in self.regions_get():
		select = region.select(MapNodeRegion.SELECTOR.NONE)
		if select == MapNodeRegion.SELECTOR.REGION:
			select_region = region;
	if select_region:
		GloabalSignal.emit_signal("country_node__deselect_region", select_region.region_id_get());
	elif select == MapNodeRegion.SELECTOR.COUNTRY:
		GloabalSignal.emit_signal("country_node__deselect_country", self.country_id_get());

func _on_region_clicked(region_id:int, country_id:int)->void:
	if self.country_id_get() != country_id:
		return;
	match self.state_get():
		STATE.REGION:
			if $Regions.get_node(str(region_id)).select(MapNodeRegion.SELECTOR.REGION) == MapNodeRegion.SELECTOR.REGION:
				return;
			GloabalSignal.emit_signal("country_node__select_region", region_id);
			for region in self.regions_get():
				if region.region_id_get() == region_id:
					continue;
				region.select(MapNodeRegion.SELECTOR.NONE);
		STATE.COUNTRY:
			for region in self.regions_get():
				if region.select(MapNodeRegion.SELECTOR.COUNTRY) == MapNodeRegion.SELECTOR.COUNTRY:
					return;
			GloabalSignal.emit_signal("country_node__select_country", country_id);
