@tool
extends CanvasLayer
class_name SplashScreens

func start()->void:
	GloabalSignal.emit_signal("spash_screens__start");
	var splash:SplashScreen = self._splash_screen_load(SPLASH_SCREENS.DARK);
	await splash.start();

func end()->void:
	await self.get_child(0).end();
	GloabalSignal.emit_signal("spash_screens__end");

enum SPLASH_SCREENS {
	NONE = 0,
	DARK = 1,
}
@export var _SPLASH_SCREENS_PCKG:Array[PackedScene];
func _splash_screen_load(splash_screen_id:SPLASH_SCREENS)->SplashScreen:
	self._splash_screen_clear();
	if !splash_screen_id:
		return null;
	var splash_screen:SplashScreen = _SPLASH_SCREENS_PCKG[splash_screen_id].instantiate();
	self.add_child(splash_screen);
	return splash_screen;
func _splash_screen_clear()->void:
	for child in self.get_children():
		child.queue_free();
