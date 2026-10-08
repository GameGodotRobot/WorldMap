extends Node2D

class_name MapNodeElement2


func select(color:Color)->void:
	$Polygon.color = color;
	$Line.default_color = color;

var _centroid:Vector2 = Vector2.ZERO:
	set = _centroid_set, get = centroid_get;
func _centroid_set(value:Vector2)->void:
	_centroid = value;
func centroid_get()->Vector2:
	return _centroid;

var _rect:Rect2:
	set = _rect_set, get = rect_get;
func _rect_set(value:Rect2)->void:
	_rect = value;
func rect_get()->Rect2:
	return _rect;

func is_polygon_in_polygon(poly:PackedVector2Array)->bool:
	for point in self.polygon:
		if Geometry2D.is_point_in_polygon(point, poly):
			return true;
	return false;

func _ready()->void:
	$Line.points = self.polygon;
	$Polygon.polygon = self.polygon;
	self._centroid_set(PolygonLib.calculatePolygonCentroid(self.polygon));
	self._rect_set(PolygonLib.getBoundingRect(self.polygon));
	if GloabalSignal.connect("camera__zoom_change", Callable(self,"_on_zoom_change")) != OK:
		push_error('element not connected zoom_change');
	if self.position != Vector2.ZERO:
		push_error('Position not zero:',self.name,'-',self.position);

func _on_zoom_change(zoom:Vector2)->void:
	$Line.width = max(2, 12 - int(3*zoom.x));
