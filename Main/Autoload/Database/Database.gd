extends Node

class_name Database

const DB_FUNCTION_PATH:String = 'res://Res/Database/structure/function';

var _db:SQLite:
	set = _db_set, get = _db_get;
func _db_set(db:SQLite)->void:
	_db = db;
func _db_get()->SQLite:
	return _db;

var _functions:Dictionary = {};
func _functions_set(tables:Dictionary)->void:
	_functions = tables;
func functions_get()->Dictionary:
	return _functions;
func function_query_get(function_name:String)->Query:
	var query:Query = _functions.get(function_name, null);
	if query == null:
		push_error('query "%s" is not found'%[function_name]);
	return query;
func _functions_load()->void:
	var functions:Dictionary = GameResourceLoader._resource_recursive_load_with_path(DB_FUNCTION_PATH, true);
	for key in functions.keys():
		if functions[key].contains(Query.PARAMS_TABLE):
			functions[key] = QueryWithParams.new(functions[key]);
		else:
			functions[key] = Query.new(functions[key]);
	self._functions_set(functions);

var _error:String = '':
	set = _error_set, get = error_get;
func _error_set(value:String)->void:
	if value == 'not an error':
		value = ''
	_error = value;
func error_get()->String:
	return _error;


func start(start_db_name:String, start_version:float, proto_db_name:String = "main")->bool:
	if self._db_get():
		push_error('database is start');
		return false;
	var start_db_path:String = 'user://%s-%.2f.db'%[start_db_name,start_version];
	var proto_db_path:String = 'res://Res/Database/%s.db'%[proto_db_name]
	if !FileAccess.file_exists(start_db_path):
		if !GameResourceLoader.copy(start_db_path,proto_db_path):
			push_error('database "%s" is not loaded'%[proto_db_path.get_file()]);
			return false;
	self._functions_load();
	self._db_set(SQLite.new());
	self._db_get().verbosity_level = SQLite.VerbosityLevel.QUIET;
	self._db_get().path = start_db_path;
	return true;

func end()->bool:
	self._db_set(null);
	self._functions_set({});
	self._error_set('');
	return true;

func exec(query:Query, params:Array[Dictionary] = [])->Array[Dictionary]:
	var result:Array[Dictionary] = [];
	self._db_get().open_db();
	self._db_get().query('BEGIN;');
	self._db_get().query(query.query_text_get(params));
	result = self._db_get().get_query_result();
	self._error_set(self._db_get().get_error_message());
	self._db_get().query('COMMIT;');
	self._db_get().close_db();
	return result;
