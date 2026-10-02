@tool
extends RefCounted
class_name GameServer

static var _database:Database = Database.new():
	set = _database_set, get = _database_get;
static func _database_set(value:Database)->void:
	_database = value;
static func _database_get()->Database:
	return _database;

static func connect_db(database_name:String)->void:
	if !_database_get().start(database_name, Config.DATABASE_VERSION):
		push_error('db not started');
		return;
static func disconnect_db()->void:
	_database_get().end();





static func test()->Array[Dictionary]:
	var q:Query = _database_get().function_query_get('test');
	return _database_get().exec(q, []);

static func global_insert(global:GlobalDTO)->Array[Dictionary]:
	var qdata:Array[Dictionary] = [global.dto_get()];
	var q:Query = _database_get().function_query_get('global_insert');
	return _database_get().exec(q, qdata);
static func next_game_date()->Array[Dictionary]:
	var q:Query = _database_get().function_query_get('next_game_date');
	return _database_get().exec(q, []);




static func country_insert(countries:Array[CountryDTO])->Array[Dictionary]:
	var qdata:Array[Dictionary] = [];
	for country in countries:
		qdata.append(country.dto_get());
	var q:Query = _database_get().function_query_get('country_insert');
	return _database_get().exec(q, qdata);
static func country_get_by_ids(ids:PackedInt32Array)->Array[Dictionary]:
	var qdata:Array[Dictionary] = [];
	for id in ids:
		qdata.append({'country_id':id});
	var q:Query = _database_get().function_query_get('country_get_by_id');
	return _database_get().exec(q, qdata);
static func country_finance_calc()->Array[Dictionary]:
	var q:Query = _database_get().function_query_get('country_finance_calc');
	return _database_get().exec(q, []);
static func country_parameters_get_by_country_ids(ids:PackedInt32Array)->Array[Dictionary]:
	var qdata:Array[Dictionary] = [];
	for id in ids:
		qdata.append({'country_id':id});
	var q:Query = _database_get().function_query_get('country_parameters_get_by_country_id');
	return _database_get().exec(q, qdata);




static func region_insert(regions:Array[RegionDTO])->Array[Dictionary]:
	var qdata:Array[Dictionary] = [];
	for region in regions:
		qdata.append(region.dto_get());
	var q:Query = _database_get().function_query_get('region_insert');
	return _database_get().exec(q, qdata);
static func region_get_by_ids(ids:PackedInt32Array)->Array[Dictionary]:
	var qdata:Array[Dictionary] = [];
	for id in ids:
		qdata.append({'region_id':id});
	var q:Query = _database_get().function_query_get('region_get_by_id');
	return _database_get().exec(q, qdata);
static func region_neighbour_connect_insert(rncs:Array[RegionNeighbourConnectDTO])->Array[Dictionary]:
	var qdata:Array[Dictionary] = [];
	for rnc in rncs:
		qdata.append(rnc.dto_get());
	var q:Query = _database_get().function_query_get('region_neighbour_connect_insert');
	return _database_get().exec(q, qdata);
static func region_neighbour_connect_get_by_region_ids(ids:PackedInt32Array)->Array[Dictionary]:
	var qdata:Array[Dictionary] = [];
	for id in ids:
		qdata.append({'region_id':id});
	var q:Query = _database_get().function_query_get('region_neighbour_connect_get_by_id');
	return _database_get().exec(q, qdata);
static func region_finance_calc()->Array[Dictionary]:
	var q:Query = _database_get().function_query_get('region_finance_calc');
	return _database_get().exec(q, []);
static func region_parameters_get_by_region_ids(ids:PackedInt32Array)->Array[Dictionary]:
	var qdata:Array[Dictionary] = [];
	for id in ids:
		qdata.append({'region_id':id});
	var q:Query = _database_get().function_query_get('region_parameters_get_by_id');
	return _database_get().exec(q, qdata);






static func production_calc()->Array[Dictionary]:
	var q:Query = _database_get().function_query_get('production_calc3');
	return _database_get().exec(q, []);
static func production_get_by_region_ids(ids:PackedInt32Array)->Array[Dictionary]:
	var qdata:Array[Dictionary] = [];
	for id in ids:
		qdata.append({'region_id':id});
	var q:Query = _database_get().function_query_get('production_get_by_region_id');
	return _database_get().exec(q, qdata);
static func production_get_by_country_ids(ids:PackedInt32Array)->Array[Dictionary]:
	var qdata:Array[Dictionary] = [];
	for id in ids:
		qdata.append({'country_id':id});
	var q:Query = _database_get().function_query_get('production_get_by_country_id');
	return _database_get().exec(q, qdata);
static func product_type_get()->Array[Dictionary]:
	var q:Query = _database_get().function_query_get('product_type_get');
	return _database_get().exec(q, []);
static func manufacture_type_get()->Array[Dictionary]:
	var q:Query = _database_get().function_query_get('manufacture_type_get');
	return _database_get().exec(q, []);
static func building_queue_insert(bq:BuildingQueueDTO)->Array[Dictionary]:
	var qdata:Array[Dictionary] = [bq.dto_get()];
	var q:Query = _database_get().function_query_get('building_queue_insert');
	return _database_get().exec(q, qdata);
static func building_queue_get_by_region_ids(ids:PackedInt32Array)->Array[Dictionary]:
	var qdata:Array[Dictionary] = [];
	for id in ids:
		qdata.append({'region_id':id});
	var q:Query = _database_get().function_query_get('building_queue_get_by_region_id');
	return _database_get().exec(q, qdata);
static func building_queue_calc()->Array[Dictionary]:
	var q:Query = _database_get().function_query_get('building_queue_calc');
	return _database_get().exec(q, []);
static func manufacture_price_get_by_manufacture_type_ids(ids:PackedInt32Array)->Array[Dictionary]:
	var qdata:Array[Dictionary] = [];
	for id in ids:
		qdata.append({'manufacure_type_id':id});
	var q:Query = _database_get().function_query_get('manufacture_price_get_by_manufacture_type_id');
	return _database_get().exec(q, qdata);
static func manufacture_finance_calc()->Array[Dictionary]:
	var q:Query = _database_get().function_query_get('manufacture_finance_calc');
	return _database_get().exec(q, []);



static func trading_calc()->Array[Dictionary]:
	var q:Query = _database_get().function_query_get('trading_calc2');
	return _database_get().exec(q, []);
static func trading_get_by_region_ids(ids:PackedInt32Array)->Array[Dictionary]:
	var qdata:Array[Dictionary] = [];
	for id in ids:
		qdata.append({'region_id':id});
	var q:Query = _database_get().function_query_get('trading_get_by_region_id');
	return _database_get().exec(q, qdata);





static func population_calc()->Array[Dictionary]:
	var q:Query = _database_get().function_query_get('population_calc');
	return _database_get().exec(q, []);
static func population_get_by_region_ids(ids:PackedInt32Array)->Array[Dictionary]:
	var qdata:Array[Dictionary] = [];
	for id in ids:
		qdata.append({'region_id':id});
	var q:Query = _database_get().function_query_get('population_get_by_region_id');
	return _database_get().exec(q, qdata)
