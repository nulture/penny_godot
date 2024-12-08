
## Statement that interacts with an object and can have nested statements that interact with said object.
class_name StmtObject extends Stmt

var path : Path


# func _init() -> void:
# 	pass


func _get_keyword() -> StringName:
	return 'object_head'


func _get_verbosity() -> Verbosity:
	return Verbosity.DATA_ACTIVITY


func _validate_self() -> PennyException:
	var exception := validate_path(tokens)
	if exception:
		return exception

	path = Path.from_tokens(tokens)
	return null


# func _validate_cross() -> PennyException:
# 	super._validate_cross()


func _execute(host: PennyHost) :
	var prior : Variant = path.evaluate_shallow()
	if prior: return super._execute(host)
	var after : Variant = self.owning_object.add_object(path.ids.back(), PennyObject.DEFAULT_BASE)
	if after is PennyObject:
		after.self_key = path.ids.back()
	print(after.rich_name)
	return create_assignment_record(host, prior, after)


func _undo(record: Record) -> void:
	if record.attachment:
		path.set_data(record.host, record.attachment.before)


# func _next(record: Record) -> Stmt:
# 	return next_in_order


func _create_history_listing(record: Record) -> HistoryListing:
	var result := super._create_history_listing(record)
	result.message_label.text = "[color=#%s][code]%s[/code][/color]" % [Penny.IDENTIFIER_COLOR.to_html(), path]
	if record.attachment:
		result.message_label.text += " = %s" % record.attachment
	return result


func create_assignment_record(host: PennyHost, before: Variant, after: Variant, __skip : bool = false) -> Record:
	var result := create_record(host, AssignmentRecord.new(before, after), __skip)
	host.on_data_modified.emit()
	return result
