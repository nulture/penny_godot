
## Node that actualizes Penny statements. This stores local data_root and records based on what the player chooses to do. Most applications will simply use an autoloaded, global host. For more advanced uses, you can instantiate multiple of these simultaneously for concurrent or even network-replicated instances. The records/state can be saved.
class_name PennyHost extends Node

signal on_data_modified

## If populated, this host will start at this label on ready. Leave empty to not execute anything.
@export var autostart_label : StringName = ''

## Reference to a message handler. (Temporary. Eventually will be instantiated in code)
@export var message_handler : MessageHandler

## Reference to the history handler.
@export var history_handler : HistoryHandler

## Settings.
@export var settings : PennySettings

static var insts : Array[PennyHost] = []

var data_root := PennyObject.new(self, { PennyObject.BASE_OBJECT_NAME: PennyObject.BASE_OBJECT })
var records : Array[Record]

var call_stack : Array[Address]
var expecting_conditional : bool
var cursor : Stmt_

var is_halting : bool :
	get: return cursor.is_halting

@onready var watcher := Watcher.new([message_handler])

func _ready() -> void:
	insts.push_back(self)

	if Penny.valid and not autostart_label.is_empty():
		jump_to.call_deferred(autostart_label)

func _exit_tree() -> void:
	insts.erase(self)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('penny_advance'):
		if not watcher.working:
			advance()
		else: watcher.wrap_up_work()

func jump_to(label: StringName) -> void:
	cursor = Penny.get_stmt_from_label(label)
	invoke_at_cursor()

func invoke_at_cursor() -> void:
	var record := cursor.execute(self)

	records.push_back(record)
	history_handler.receive(record)

	if is_halting:
		pass
	else:
		advance()

func advance() -> void:
	if cursor == null: return
	cursor = records.back().next()

	if cursor == null:
		if call_stack:
			cursor = call_stack.pop_back().stmt
		else:
			close()
			return

	invoke_at_cursor()

func close() -> void:
	message_handler.queue_free()
	queue_free()

func rewind_to(record: Record) -> void:
	expecting_conditional = false
	cursor = record.stmt
	while records.size() > record.stamp:
		records.pop_back().undo()
	history_handler.rewind_to(record)

	invoke_at_cursor()

func evaluate_expression_as_boolean(tokens: Array[Token], range_in := 0, range_out := -1) -> bool:
	var result = evaluate_expression(tokens, range_in, range_out)
	if result:
		return result as bool
	return false

## Evaluates the expression. If the result is an ObjectPath that doesn't exist, just return the ObjectPath itself as if it is an identifier.
func evaluate_expression_or_identifier(tokens: Array[Token], range_in := 0, range_out := -1) -> Variant:
	var expr = self.evaluate_expression(tokens)
	if expr is ObjectPath:
		var value : Variant = expr.get_data(self)
		if value:
			return value
		return StringName(expr.to_string())
	return expr

func evaluate_expression(tokens: Array[Token], range_in := 0, range_out := -1) -> Variant:
	if range_out == -1:
		range_out = tokens.size()
	range_out -= range_in
	if range_out <= 0:
		return null

	var stack := []
	var ops := []

	for i in range_out:
		var token := tokens[i + range_in]
		match token.type:
			Token.IDENTIFIER:
				stack.push_back(ObjectPath.new([token.value]))
			Token.VALUE_BOOLEAN, Token.VALUE_NUMBER, Token.VALUE_COLOR, Token.VALUE_STRING:
				stack.push_back(token.value)
			Token.LOOKUP:
				stack.push_back(token.value)
			Token.KEYWORD:
				match token.value:
					'object':
						stack.push_back(ObjectPath.new(["object"]))
						# stack.push_back(PennyObject.DEFAULT_OBJECT)
					_:
						push_error("Unexpected keyword in expression '%s'." % token)
						return null
			Token.OPERATOR:
				while ops and (token.get_operator_type() <= ops.back().get_operator_type()):
					apply_operator(stack, ops.pop_back())
				ops.push_back(token)

	while ops:
		apply_operator(stack, ops.pop_back())

	if stack.size() != 1:
		Penny.log_error("Stack size is not 1. Tokens: %s | Stack: %s " % [str(tokens), str(stack)])
		return null

	return stack[0]

static func apply_operator(stack: Array[Variant], op: Token) -> void:
	var token_count = op.get_operator_token_count()
	match token_count:
		1:
			match op.get_operator_type():
				Token.Operator.NOT:
					stack.push_back(not stack.pop_back())
		2:
			var b : Variant = stack.pop_back()
			var a : Variant = stack.pop_back()
			match op.get_operator_type():
				Token.Operator.AND:
					stack.push_back(a and b)
				Token.Operator.OR:
					stack.push_back(a or b)
				Token.Operator.IS_EQUAL:
					stack.push_back(a == b)
				Token.Operator.NOT_EQUAL:
					stack.push_back(a != b)
				Token.Operator.DOT:
					a.identifiers.append_array(b.identifiers)
					stack.push_back(a)

