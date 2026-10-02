extends RefCounted

class_name GlobalDTO;

var _game_date:String:
	set = _game_date_set, get = game_date_get;
func _game_date_set(values:String)->void:
	_game_date = values;
func game_date_get()->String:
	return _game_date;

var _player_country_id:int:
	set = _player_country_id_set, get = player_country_id_get;
func _player_country_id_set(values:int)->void:
	_player_country_id = values;
func player_country_id_get()->int:
	return _player_country_id;
	
func _init(game_date:String, player_country_id:int)->void:
	self._game_date_set(game_date);
	self._player_country_id_set(player_country_id);

func dto_get()->Dictionary:
	return {
		'game_date':self.game_date_get(),
		"player_country_id":self.player_country_id_get()
	}
