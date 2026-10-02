extends Node

@export var _label_setting:LabelSettings;

var _label_settings:Dictionary = {};
func label_setting_get(font_size:int)->LabelSettings:
	var ls:LabelSettings = _label_settings.get(font_size, null);
	if ls:
		return ls;
	ls = _label_setting.duplicate();
	ls.font_size = font_size;
	_label_settings[font_size] = ls;
	return ls;
