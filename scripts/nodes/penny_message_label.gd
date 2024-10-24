
class_name PennyMessageLabel extends RichTextLabel

var rec : Record
var handler : HistoryHandler

func _init() -> void:
	bbcode_enabled = true
	fit_content = true
	scroll_active = false
	focus_mode = FOCUS_ALL
	visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	mouse_default_cursor_shape = Control.CursorShape.CURSOR_POINTING_HAND

func _ready() -> void:
	pass

func populate(__rec: Record) -> void:
	rec = __rec
	text = rec.message.text
	if not rec.stmt.verbosity & Stmt_.Verbosity.USER_FACING:
		var c = get_theme_color('default_color')
		c.a = 0.25
		add_theme_color_override('default_color', c)
	refresh_visibility()
	if visible:
		grab_focus.call_deferred()

func refresh_visibility() -> void:
	visible = rec.stmt.is_record_shown_in_history(rec) && rec.host.history_handler.verbosity & rec.stmt.verbosity

func _gui_input(event: InputEvent) -> void:
	if event.is_pressed():
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if rec.host == null: return
				rec.host.rewind_to(rec)

	# if event.is_action_pressed('ui_accept'):
	# 	print("Accepted %s" % rec)
	# 	if rec.host == null: return
	# 	rec.host.rewind_to(rec)
	# if event.is_action_pressed('ui_cancel'):
	# 	release_focus()
