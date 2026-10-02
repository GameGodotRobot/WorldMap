@tool
extends Control
class_name SplashScreen

signal signal_start
signal signal_end

func start()->void:
	$Anim.play("Start");
	await signal_start;

func end()->void:
	$Anim.play("End");
	await signal_end;
