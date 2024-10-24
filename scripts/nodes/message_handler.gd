
class_name MessageHandler extends PennyNode

signal appeared
signal received
signal advanced
# signal closed
signal disappeared

@export var name_label : RichTextLabel
@export var text_label : RichTextLabel
@export var typewriter : Typewriter
@export var skip_prevent_timer : Timer

var rand := RandomNumberGenerator.new()

func _ready() -> void:
	advanced.connect(host.resume)

	# var c = self
	# c.modulate = Color(rand.randf(), rand.randf(), rand.randf())
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('penny_advance'):
		try_advance()

func _gui_input(event: InputEvent) -> void:
	pass
		# try_advance()

func receive(record: Record, subject: PennyObject) -> void:
	name_label.text = subject.rich_name
	text_label.text = record.message.text
	received.emit()

func prevent_skip() -> void:
	if skip_prevent_timer.is_stopped():
		skip_prevent_timer.start()

func try_advance() -> void:
	if typewriter.working:
		typewriter.prod_work()
		return
	if not skip_prevent_timer.is_stopped():
		return
	advanced.emit()

func _on_appear_finished() -> void:
	appeared.emit()

func _on_disappear_finished() -> void:
	disappeared.emit()
	queue_free()
