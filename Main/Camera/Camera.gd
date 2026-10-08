extends Camera2D

class_name Camera

const _MAX_ZOOM:float = 4.5;
const _MIN_ZOOM:float = 0.2;

var _start_pos:Vector2:
	set= _start_pos_set, get = start_pos_get;
func _start_pos_set(value:Vector2)->void:
	_start_pos = value;
func start_pos_get()->Vector2:
	return _start_pos;

func _ready()->void:
	self._start_pos_set(self.global_position);
	self._cam_move(Vector2.ZERO);
	self._cam_scroll(true);

var _multitouch:Dictionary = {};
func _event_add(event:InputEventScreenDrag)->void:
	_multitouch[event.index] = event;
func _event_del(event:InputEventScreenTouch)->void:
	if !_multitouch.erase(event.index):
		pass;
func _event_get(indx:int)->InputEventScreenDrag:
	return _multitouch.get(indx);
func event_size()->int:
	return _multitouch.size();

func _unhandled_input(event:InputEvent)->void:
	if event.is_echo():
		return;
	if event.is_action("scroll_down"):
		if !self._cam_scroll(true):
			return;
	if event.is_action("scroll_up"):
		if !self._cam_scroll(false):
			return;
	if event is InputEventScreenDrag:
		self._event_add(event);
		if self.event_size() == 1:
			self._cam_move(event.relative);
		else:
			var first:InputEventScreenDrag = self._event_get(0);
			var second:InputEventScreenDrag = self._event_get(1);
			var first_new_pos:Vector2 = first.position+first.relative;
			var second_new_pos:Vector2 = second.position+second.relative;
			if second_new_pos.distance_to(second.position)<first_new_pos.distance_to(first.position):
				self._cam_scroll(false);
			else:
				self._cam_scroll(true);
	if event is InputEventScreenTouch:
		if !event.is_pressed():
			self._event_del(event);

func _cam_move(relative:Vector2)->void:
	self.global_position = self._validate_position(self.global_position - relative*(1.0/self.zoom.x)*Config.MOUSE_SENSETIVITY);
	GloabalSignal.emit_signal("camera__position_change", self.global_position);

func _validate_position(vec:Vector2)->Vector2:
	vec.x = max(vec.x, self.limit_left+self.get_viewport_rect().size.x/(self.zoom.x*2.0));
	vec.x = min(vec.x, self.limit_right-self.get_viewport_rect().size.x/(self.zoom.x*2.0));
	vec.y = max(vec.y, self.limit_top+self.get_viewport_rect().size.y/(self.zoom.x*2.0));
	vec.y = min(vec.y, self.limit_bottom-self.get_viewport_rect().size.y/(self.zoom.x*2.0));
	return vec;

func _cam_scroll(direction:bool)->bool:
	if !direction:
		if self.zoom.x > _MAX_ZOOM:
			return false;
		self.zoom += Vector2.ONE*sqrt(self.zoom.x)*0.025;
	else:
		if self.zoom.x < _MIN_ZOOM:
			return false;
		self.zoom -= Vector2.ONE*sqrt(self.zoom.x)*0.025;
	GloabalSignal.emit_signal("camera__zoom_change", self.zoom);
	return true;
