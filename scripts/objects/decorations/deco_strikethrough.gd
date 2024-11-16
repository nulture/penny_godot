
class_name DecoStrikethrough extends Deco

## REQUIRED: Call [register_instance] and pass in an instance of THIS script.
## REQUIRED: Ensure that this script is registered in a PennyDecoRegistry resource SOMEWHERE in the project.
static func _static_init() -> void:
	register_instance(DecoStrikethrough.new())


func _get_penny_tag_id() -> StringName:
	return StringName('s')