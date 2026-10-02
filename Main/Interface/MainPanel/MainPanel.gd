extends Control

class_name MainPanel

const VALUE_PANEL_PCKG:PackedScene = preload("res://Main/Interface/ValuePanel/ValuePanel.tscn");

func init_by_region_id(region_id:int)->void:
	var elems:Array[Dictionary] = GameServer.region_parameters_get_by_region_ids([region_id]);
	self._create_list(elems);

func init_by_country_id(country_id:int)->void:
	var elems:Array[Dictionary] = GameServer.country_parameters_get_by_country_ids([country_id]);
	self._create_list(elems);

func clear()->void:
	for child in $Scroll/List.get_children():
		child.queue_free();


func _create_list(elems:Array[Dictionary])->void:
	self.clear();
	for elem in elems:
		var node:ValuePanel = VALUE_PANEL_PCKG.instantiate();
		$Scroll/List.add_child(node);
		node.init(
			elem.get("header"),
			'%s'%[elem.get("value")]
		);
