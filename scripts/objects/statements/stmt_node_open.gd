
## No description
class_name StmtOpen extends StmtNode_

# func _init() -> void:
# 	pass


func _get_keyword() -> StringName:
	return "open"


# func _get_verbosity() -> Verbosity:
# 	return super._get_verbosity()


func _validate_self() -> PennyException:
	return null


# func _validate_self_post_setup() -> void:
# 	super._validate_self_post_setup()


# func _validate_cross() -> PennyException:
# 	return super._validate_cross()


func _execute(host: PennyHost) -> Record:
	var incoming_object : PennyObject = self.subject_path.evaluate(host.data_root)
	if incoming_object.local_instance:
		push_exception("Attempted to open instance for '%s', but there is already an existing instance.")
		return super._execute(host)

	var incoming_node : Node
	incoming_node = self.instantiate_node(host, subject_path)
	if incoming_node is PennyNode:
		incoming_node.populate(host, incoming_object)
		return create_record(host, incoming_node.halt_on_instantiate)
	else:
		return create_record(host)


# func _undo(record: Record) -> void:
# 	super._undo(record)


# func _next(record: Record) -> Stmt_:
# 	return super._next(record)


func _message(record: Record) -> Message:
	return super._message(record)