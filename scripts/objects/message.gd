
## Displayable text capable of producing decorations.
class_name Message extends RefCounted

var pure : String
var text : String

func _init(_pure: String) -> void:
	pure = _pure
	text = "[p align=fill jst=w,k,sl]" + pure


func _to_string() -> String:
	return text


func append(_pure: String) -> void:
	text += _pure
