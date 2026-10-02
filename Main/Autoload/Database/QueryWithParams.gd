extends Query

class_name QueryWithParams

func query_text_get(params:Array[Dictionary] = [])->String:
	if !params.size():
		push_error('params not found');
		return '';
	return self._text_get().replace(Query.PARAMS_TABLE,self._params_to_query_text(params));

func _params_to_query_text(params:Array[Dictionary] = [])->String:
	if !params.size():
		return '';
	var data:String = '';
	data += '(VALUES'
	for dict in params:
		data += '('
		for value in dict.values():
			if value is String:
				value = "'%s'"%value;
			data += '%s,'%[value];
		data = data.trim_suffix(',');
		data += '),'
	data = data.trim_suffix(',');
	data += ')'
	return data;
