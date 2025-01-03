
class_name PennyPromptControl extends PennyPrompt

@export var button_prefab : PackedScene = load("res://addons/penny_godot/assets/scenes/prompt_button_default.tscn")
@export var button_container : Container

# func _populate(_host: PennyHost, _attach: Variant = null) -> void:
# 	super._populate(_host, _attach)


func _receive_options(_options: Array) -> void:
	for path in _options:
		var button : PromptButton = button_prefab.instantiate()
		button.pressed.connect(receive_response.bind(path))

		button.receive(path.evaluate())

		button_container.add_child(button)
