
## Links to a [PennyHost] and visualizes the [Record]s it produces.
class_name HistoryHandler extends Control

@export var scroll_container : ScrollContainer
@export var vbox : VBoxContainer

var scrollbar : VScrollBar :
	get: return scroll_container.get_v_scroll_bar()

var _host : PennyHost
@export var host : PennyHost :
	get: return _host
	set(value):
		if _host == value: return

		if _host:
			_host.on_record_created.disconnect(self.receive_record)

		_host = value

		if _host:
			_host.on_record_created.connect(self.receive_record)
			refresh()

var _verbosity : int
@export_flags(Stmt.VERBOSITY_NAMES[0], Stmt.VERBOSITY_NAMES[1], Stmt.VERBOSITY_NAMES[2], Stmt.VERBOSITY_NAMES[3], Stmt.VERBOSITY_NAMES[4], Stmt.VERBOSITY_NAMES[5]) var verbosity : int :
	get: return _verbosity
	set (value):
		_verbosity = value
		refresh_visibility()

# var controls : Array[PennyMessageLabel]


func refresh() -> void:
	for listing in vbox.get_children():
		listing.queue_free()
	for record in host.records:
		receive_record(record)
	refresh_visibility()
	scroll_to_end.call_deferred()


func refresh_visibility() -> void:
	if not vbox: return
	for listing in vbox.get_children():
		listing.refresh_visibility(self)


func scroll_to_end() -> void:
	scrollbar.value = scrollbar.max_value


func receive_record(rec: Record) -> void:
	var listing := rec.create_history_listing()
	listing.refresh_visibility(self)
	vbox.add_child(listing)


func rewind_to(rec: Record) -> void:
	# while controls.size() > rec.stamp:
	# 	var control = controls.pop_back()
		# vbox.remove_child(control)
		# control.queue_free()
	pass


func _on_record_created(record:Record) -> void:
	receive_record(record)


func _on_verbosity_selector_item_selected_id(id:int) -> void:
	self.verbosity = id



func _on_penny_debug_on_host_changed(__host: PennyHost) -> void:
	host = __host


