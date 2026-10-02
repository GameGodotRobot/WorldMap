extends Resource

class_name Query

const PARAMS_TABLE:String = '_params';

@export_multiline var _text:String = '':
	set = _text_set, get = _text_get;
func _text_set(text:String)->void:
	_text = text;
func _text_get()->String:
	return _text;

func query_text_get(_params:Array[Dictionary] = [])->String:
	return self._text_get();

func _init(text:String)->void:
	self._text_set(text);
