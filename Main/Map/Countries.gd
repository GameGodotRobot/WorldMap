extends Node2D

class_name Countries

func _find_region_neighbours2(pick_region:MapNodeRegion)->Array[RegionNeighbourConnectDTO]:
	var arr:Array[RegionNeighbourConnectDTO] = [];
	var region_data:Array[Dictionary] = GameServer.region_neighbour_connect_get_by_region_ids([pick_region.region_id_get()]);
	var region_dict:Dictionary = {};
	for rd in region_data:
		region_dict[rd.get("neighbour_region_id")] = rd;
	for country in self.get_children():
		for region in country.regions_get():
			if region == pick_region:
				continue;
			if region_dict.get(region.region_id_get(), null):
				continue;
			var sea_distance:float = self.sea_distance_get(pick_region, region);
			var land_distance:float = self.land_distance_get(pick_region, region);
			if sea_distance or land_distance:
				arr.append(RegionNeighbourConnectDTO.new(
														pick_region.region_id_get(),
														region.region_id_get(),
														sea_distance, 
														land_distance
													)
				);
	return arr;

## дистанция по морю не должна быть напрямую
func sea_distance_get(first_region:MapNodeRegion, second_region:MapNodeRegion)->float:
	if !first_region.is_sea_get() or !second_region.is_sea_get():
		return 0;
	return first_region.centroid_get().distance_to(second_region.centroid_get());

func land_distance_get(first_region:MapNodeRegion, second_region:MapNodeRegion)->float:
	if !first_region.rect_get().intersects(second_region.rect_get(), true):
		return 0;
	for elem in first_region.elements_get():
		if second_region.is_polygon_in_polygon(elem.polygon):
			return first_region.centroid_get().distance_to(second_region.centroid_get());;
	return 0;
