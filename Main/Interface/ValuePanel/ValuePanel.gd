extends Control

class_name ValuePanel

func init(header:String, value:String)->void:
	$Head/HeadLine.text = header;
	$ValueLine.text = value;
