extends RefCounted

class_name GameResourceLoader

static func resource_path_directory_load(value:RESOURCE_DIRECTORY, dir:String = "")->Dictionary:
	return _resource_directory_load(resource_directory_path_get(value)+dir, false);

static func resource_load_v2(value:RESOURCE_DIRECTORY, file:String):
	return _file_load_or_path(resource_directory_path_get(value)+file, true);

static func resource_load(path:String):
	return _file_load_or_path(path, true);

static func resource_recursive_load(value:RESOURCE_DIRECTORY, dir:String = "")->Dictionary:
	return _resource_recursive_load_with_path(resource_directory_path_get(value)+dir, true);

static func resource_path_recursive_load(value:RESOURCE_DIRECTORY, dir:String = "")->Dictionary:
	return _resource_recursive_load_with_path(resource_directory_path_get(value)+dir, false);

static func resource_directory_load(value:RESOURCE_DIRECTORY, dir:String = "")->Dictionary:
	return _resource_directory_load(resource_directory_path_get(value)+dir, true);

static func resource_directory_load_with_path(path:String, is_load:bool)->Dictionary:
	return _resource_directory_load(path, is_load);

static func directories_get(path:String)->PackedStringArray:
	var dir:DirAccess = DirAccess.open(path);
	if !dir:
		return [];
	if dir.list_dir_begin() != OK:
		return [];
	var arr:PackedStringArray = dir.get_directories();
	dir.list_dir_end();
	return arr;

static func copy(file_path_new:String, file_path_old:String)->bool:
	if !FileAccess.file_exists(file_path_old):
		push_error('file "%s" is created'%[file_path_old.get_file()]);
		return false;
	var file_old:FileAccess = FileAccess.open(file_path_old, FileAccess.READ);
	var file_new:FileAccess = FileAccess.open(file_path_new, FileAccess.WRITE);
	var buffer:PackedByteArray = file_old.get_buffer(1024)
	while buffer:
		file_new.store_buffer(buffer);
		buffer = file_old.get_buffer(1024);
	file_old.close();
	file_new.close();
	return true;

static func resource_save(path:String, res:Array[Dictionary])->bool:
	var file:FileAccess = FileAccess.open(path, FileAccess.WRITE);
	file.store_var(res);
	file.close()
	return true;

enum RESOURCE_DIRECTORY {
}
const _RESOURCE_DIRECTORY:Dictionary = {
}
static func resource_directory_path_get(value:RESOURCE_DIRECTORY)->String:
	return _RESOURCE_DIRECTORY.get(value, "");

static func _resource_recursive_load_with_path(path:String, is_load:bool)->Dictionary:
	var objects:Dictionary = {};
	_resource_recursive_load(path, objects, is_load);
	return objects;

const _IGNORE_FORMAT:Array[String] = ['import','depren','translation'];
static func _resource_recursive_load(path:String, objects:Dictionary, is_load:bool)->void:
	var dir:DirAccess = DirAccess.open(path);
	if !dir:
		return;
	if dir.list_dir_begin() != OK:
		return;
	var file_name:String = dir.get_next();
	while file_name != "":
		if _IGNORE_FORMAT.has(file_name.get_extension()):
			file_name = dir.get_next();
			continue;
		if dir.current_is_dir():
			_resource_recursive_load("%s/%s"%[path,file_name], objects, is_load);
		else:
			objects[file_name.get_basename()] = _file_load_or_path('%s/%s'%[path,file_name], is_load);
		file_name = dir.get_next();
	dir.list_dir_end();

static  func _resource_directory_load(path:String, is_load:bool)->Dictionary:
	var dir:DirAccess = DirAccess.open(path);
	if !dir:
		return {};
	if dir.list_dir_begin() != OK:
		return {};
	var objects:Dictionary = {};
	for file_name in dir.get_files():
		if _IGNORE_FORMAT.has(file_name.get_extension()):
			continue;
		objects[file_name.get_basename()] = _file_load_or_path('%s/%s'%[path,file_name], is_load);
	dir.list_dir_end();
	return objects;

static func _file_load_or_path(path:String, is_load:bool):
	if is_load:
		match path.get_extension():
			'res': return ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REUSE);
			'csv': return _csv_loader(path);
			'sql': return _text_loader(path);
			'save': return _save_loader(path);
			_: return ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REUSE);
	return path;

static func _save_loader(path:String)->Array[Dictionary]:
	var file:FileAccess = FileAccess.open(path, FileAccess.READ);
	if !file:
		push_error('file not found');
		return [];
	var arr = file.get_var()
	file.close();
	var data:Array[Dictionary];
	for a in arr:
		data.append(a);
	return data;

static func _csv_loader(path:String)->Array[PackedStringArray]:
	var data_table:Array[PackedStringArray] = [];
	var file:FileAccess = FileAccess.open(path, FileAccess.READ);
	if !file:
		push_error('file not found');
		return [];
	while !file.eof_reached():
		var line:PackedStringArray = file.get_csv_line();
		if line[0] == '':
			continue;
		data_table.append(line);
	file.close();
	return data_table;

static func _text_loader(path:String)->String:
	var file:FileAccess = FileAccess.open(path, FileAccess.READ);
	if !file:
		push_error('file not found');
		return '';
	var text:String = file.get_as_text();
	file.close();
	return text;
