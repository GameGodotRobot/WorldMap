extends Node

class_name Main

func _ready()->void:
	print('start game:',  Time.get_time_dict_from_system());
	GameServer.connect_db("test2");
	
	$Game/Map.country_download_server();
	$Game/Map.region_download_server();
	$Game/Map.region_neighbour_connect_download_server();
	
	#print(GameServer.test());
	
	if GloabalSignal.connect("interface__next_day", Callable(self, "day_cycle")) != OK:
		push_error("day_cycle not connected button");
	
	print('end start game:',  Time.get_time_dict_from_system());
	#GameServer.disconnect_db();

func day_cycle()->void: 
	## сложить все запросы в один для ускорения х3. Норма 4.5 секунды
	print(Time.get_time_dict_from_system());
	var sec:int = Time.get_ticks_msec()
	
	GameServer.building_queue_calc();
	
	GameServer.population_calc();
	
	GameServer.production_calc();
	
	GameServer.trading_calc();
	
	GameServer.production_calc();
	
	GameServer.manufacture_finance_calc();
	GameServer.region_finance_calc();
	GameServer.country_finance_calc();
	
	GameServer.next_game_date();
	
	print(Time.get_ticks_msec() - sec);
