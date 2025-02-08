
## No description
class_name StmtClose extends StmtNode


func _get_verbosity() -> Verbosity:
	return Verbosity.NODE_ACTIVITY


func _execute(host: PennyHost) :
	await self.close_subject(host)
	return super._execute(host)


func _undo(record: Record) -> void:
	self.open_subject(record.host, false)


func _redo(record: Record) -> void:
	self.subject_node.queue_free()

func _get_record_message(record: Record) -> String:
	return "[code][color=dim_gray]close : [/color]%s[/code]" % Penny.get_value_as_bbcode_string(subject)
