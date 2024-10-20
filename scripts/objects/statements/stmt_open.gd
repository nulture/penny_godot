
## No description
class_name StmtOpen extends StmtExpr_

func _init(_address: Address, _line: int, _depth: int, _tokens: Array[Token]) -> void:
	super._init(_address, _line, _depth, _tokens)

# func _get_is_halting() -> bool:
# 	return false

func _get_keyword() -> StringName:
	return 'open'

func _get_verbosity() -> Verbosity:
	return Verbosity.NODE_ACTIVITY

# func _is_record_shown_in_history(record: Record) -> bool:
# 	return true

# func _load() -> PennyException:
# 	return null

func _execute(host: PennyHost) -> Record:
	var lookup = expr.evaluate(host)
	if lookup is Lookup:
		var scene : PackedScene = lookup.fetch(host)
		var node : Node = scene.instantiate()
		if node is Control:
			host.instantiate_parent_control.add_child.call_deferred(node)
		return Record.new(host, self, node)
	else:
		create_exception("Couldn't use lookup because it isn't a Lookup: %s" % lookup)
	return super._execute(host)

# func _next(record: Record) -> Stmt_:
# 	return next_in_order

func _undo(record: Record) -> void:
	if record.attachment:
		record.attachment.queue_free()

func _message(record: Record) -> Message:
	return super._message(record)

func _validate() -> PennyException:
	return validate_as_lookup()
