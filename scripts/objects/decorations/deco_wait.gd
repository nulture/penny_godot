
class_name DecoWait extends Deco


func _get_requires_end_tag() -> bool:
	return false


func _get_penny_tag_id() -> StringName:
	return StringName('wait')


func _get_bbcode_tag_id() -> StringName:
	return StringName('')


# func _get_bbcode_start_tag(inst: DecoInst) -> String:
# 	return super._get_bbcode_start_tag(inst)


# func _on_register_start(message: DecoratedText, tag: DecoInst) -> void:
# 	pass


# func _on_register_end(message: DecoratedText, tag: DecoInst) -> void:
# 	pass


func _on_encounter_start(typewriter: Typewriter, tag: DecoInst):
	await typewriter.wait()


# func _on_encounter_end(typewriter: Typewriter, tag: DecoInst) -> void:
# 	pass

