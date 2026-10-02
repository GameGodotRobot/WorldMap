extends Control

class_name ProductionPanel

const PRODUCT_PRICE_PCKG:PackedScene = preload("res://Main/Interface/ProductionPanel/ProductionPrice/ProductionPrice.tscn");

func _ready()->void:
	pass

func init_by_region_id(region_id:int)->void:
	var elems:Array[Dictionary] = GameServer.production_get_by_region_ids([region_id]);
	self._create_price_list(elems);

func init_by_country_id(country_id:int)->void:
	var elems:Array[Dictionary] = GameServer.production_get_by_country_ids([country_id]);
	self._create_price_list(elems);

func clear()->void:
	for child in $Scroll/List.get_children():
		child.queue_free();

func _create_price_list(elems:Array[Dictionary])->void:
	self.clear();
	for elem in elems:
		var node:ProductionPrice = PRODUCT_PRICE_PCKG.instantiate();
		$Scroll/List.add_child(node);
		node.init(
			elem.get("product_type_id"),
			elem.get("product_type_name"),
			elem.get("price"),
			elem.get("income_count"),
			elem.get("outcome_count"),
			elem.get("unit_price")
		);
