extends Panel

class_name RegionPanel

@onready var _panel_visible:Control = $Panels/MainPanel:
	set = _panel_visible_set, get = panel_visible_get;
func _panel_visible_set(value:Control)->void:
	if _panel_visible == value:
		return;
	_panel_visible.hide();
	_panel_visible = value;
	_panel_visible.show();
func panel_visible_get()->Control:
	return _panel_visible;
func _change_panel(panel:Control = self.panel_visible_get())->void:
	self._panel_visible_set(panel);
	self.panel_visible_get().init_by_region_id(self.region_id_get());

var _region_id:int:
	set = _region_id_set, get = region_id_get;
func _region_id_set(value:int)->void:
	_region_id = value;
func region_id_get()->int:
	return _region_id;

func panel_show(region_id:int)->void:
	self._region_id_set(region_id);
	self._change_panel();
	self.show();

func panel_hide()->void:
	self.hide();

func _ready()->void:
	self.panel_hide();
	if GloabalSignal.connect("country_node__select_region", Callable(self,"_on_select_region")) != OK:
		push_error("not connected select region");
	if GloabalSignal.connect("country_node__deselect_region", Callable(self,"_on_deselect_region")) != OK:
		push_error("not connected select region");

func _gui_input(event):
	if event.is_echo():
		return;
	self.accept_event();

func _on_select_region(region_id:int)->void:
	self.panel_show(region_id);

@warning_ignore("shadowed_variable")
func _on_deselect_region(_region_id:int)->void:
	self.panel_hide();

func _on_main_panel_pressed()->void:
	self._change_panel($Panels/MainPanel);
func _on_production_panel_pressed()->void:
	self._change_panel($Panels/ProductionPanel);
