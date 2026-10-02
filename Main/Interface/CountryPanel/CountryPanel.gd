extends Panel

class_name CountryPanel

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
	self.panel_visible_get().init_by_country_id(self.country_id_get());

var _country_id:int:
	set = _country_id_set, get = country_id_get;
func _country_id_set(value:int)->void:
	_country_id = value;
func country_id_get()->int:
	return _country_id;

func panel_show(country_id:int)->void:
	self._country_id_set(country_id);
	self._change_panel();
	self.show();

func panel_hide()->void:
	self.hide();

func _ready()->void:
	self.panel_hide();
	if GloabalSignal.connect("country_node__select_country", Callable(self,"_on_select_country")) != OK:
		push_error("not connected select region");
	if GloabalSignal.connect("country_node__deselect_country", Callable(self,"_on_deselect_country")) != OK:
		push_error("not connected select region");

func _gui_input(event):
	if event.is_echo():
		return;
	self.accept_event();

func _on_select_country(country_id:int)->void:
	self.panel_show(country_id);

@warning_ignore("shadowed_variable")
func _on_deselect_country(_country_id:int)->void:
	self.panel_hide();

func _on_main_panel_pressed()->void:
	self._change_panel($Panels/MainPanel);
func _on_production_panel_pressed()->void:
	self._change_panel($Panels/ProductionPanel);
