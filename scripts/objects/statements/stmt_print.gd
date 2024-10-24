
class_name StmtPrint extends Stmt_

func _get_keyword() -> StringName:
	return "print"

func _get_verbosity() -> Verbosity:
	return Verbosity.DEBUG_MESSAGES

func _execute(host: PennyHost) -> Record:
	var expr := Expr.from_tokens(self, tokens)
	var value = expr.evaluate(host, true)
	var s := str(value)
	print(s)
	return Record.new(host, self, s)

# func _undo(record: Record) -> void:
# 	pass

func _message(record: Record) -> Message:
	return Message.new(record.attachment)

func _validate() -> PennyException:
	return validate_as_expression()
