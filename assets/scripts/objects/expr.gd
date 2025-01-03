
class_name Expr extends Evaluable

class ArrayBuilder extends RefCounted:

	var arr : Array = []
	var depth : int

	func _init(_depth : int) -> void:
		depth = _depth

	func _to_string() -> String:
		return "(%s) %s" % [depth, arr]


class Op extends RefCounted:
	enum {
		INVALID,
		EVALUATE,			# @
		ARRAY_CLOSE,		# ]
		ARRAY_OPEN,			# [
		ITERATOR,			# ,
		LOOKUP,				# $
		NOT,				# !  , not
		AND,				# && , and
		OR,					# || , or
		NEW,					# new
		IS_EQUAL,			# ==
		NOT_EQUAL,			# !=
		MORE_THAN,			# >
		MORE_EQUAL,			# >=
		LESS_THAN,			# <
		LESS_EQUAL,			# <=
		DOT,				# .
		QUESTION,			# ?
	}

	var type : int

	var symbols_required : int :
		get:
			match type:
				ARRAY_OPEN, ARRAY_CLOSE, ITERATOR, NEW:
					return 0
				EVALUATE, LOOKUP, NOT:
					return 1
				_:
					return 2

	func _init(key: StringName) -> void:
		match key:
			'!', 'not': 	type = NOT
			'$': 			type = LOOKUP
			'&&', 'and': 	type = AND
			'||', 'or': 	type = OR
			'new':		 	type = NEW
			'==': 			type = IS_EQUAL
			'!=': 			type = NOT_EQUAL
			'>': 			type = MORE_THAN
			'>=': 			type = MORE_EQUAL
			'<': 			type = LESS_THAN
			'<=': 			type = LESS_EQUAL
			'.': 			type = DOT
			'@': 			type = EVALUATE
			'?': 			type = QUESTION
			'[':			type = ARRAY_OPEN
			']':			type = ARRAY_CLOSE
			',':			type = ITERATOR
			_ :				type = INVALID

	func _to_string() -> String:
		match type:
			NOT: return 'not'
			LOOKUP: return '$'
			AND: return 'and'
			OR: return 'or'
			NEW: return 'new'
			IS_EQUAL: return '=='
			NOT_EQUAL: return '!='
			MORE_THAN: return '>'
			MORE_EQUAL: return '>='
			LESS_THAN: return '<'
			LESS_EQUAL: return '<='
			DOT: return '.'
			EVALUATE: return '@'
			QUESTION: return '?'
			ARRAY_OPEN: return '['
			ARRAY_CLOSE: return ']'
			ITERATOR: return ','
		return 'INVALID_OP'

	func apply(stack: Array[Variant], root: PennyObject) -> void:
		match type:
			NEW:
				var data := {}
				if stack:
					data[PennyObject.BASE_KEY] = stack.pop_back()
				else:
					data[PennyObject.BASE_KEY] = PennyObject.DEFAULT_BASE
				stack.push_back(PennyObject.new('new_object', root, data))
				return

		var abc : Array[Variant] = []
		for i in symbols_required:
			abc.push_front(stack.pop_back())

		for i in abc.size():
			var e = abc[i]
			if e is Evaluable:
				abc[i] = e.evaluate(root)

		match type:
			NOT:			stack.push_back(not abc[0])
			AND:			stack.push_back(abc[0] and abc[1])
			OR:				stack.push_back(abc[0] or abc[1])
			IS_EQUAL:		stack.push_back(abc[0] == abc[1])
			NOT_EQUAL:		stack.push_back(abc[0] != abc[1])
			MORE_THAN:		stack.push_back(abc[0] >  abc[1])
			MORE_EQUAL:		stack.push_back(abc[0] >= abc[1])
			LESS_THAN:		stack.push_back(abc[0] <  abc[1])
			LESS_EQUAL:		stack.push_back(abc[0] <= abc[1])

	func apply_static(stack: Array[Variant]) -> void:
		match type:
			ARRAY_OPEN:
				stack.push_back([])
				return
			ARRAY_CLOSE:
				var arr : Array = stack.pop_back()
				while stack:
					var pop = stack.pop_back()
					if pop is StringName:
						pop = Path.new_from_single(pop)
					arr.push_front(pop)
				stack.push_back(arr)
				return
			LOOKUP:
				stack.push_back(Lookup.new(stack.pop_back()))
			DOT:
				match stack.size():
					0:
						stack.push_back(Path.new([], true))
					1:
						stack.push_back(Path.new([stack.pop_back()], true))
					_:
						var b = stack.pop_back()
						var a = stack.pop_back()
						if a is Path:
							a.ids.push_back(b)
							stack.push_back(a)
						elif a is StringName:
							stack.push_back(Path.new([a, b], false))
						else:
							stack.push_back(a)
							stack.push_back(Path.new([b], true))

var stmt : Stmt
var symbols : Array[Variant]


func _init(_stmt: Stmt, _symbols: Array) -> void:
	stmt = _stmt
	symbols = _symbols

static func from_string(string: String, _stmt: Stmt = null) -> Expr:
	return Expr.from_tokens(PennyScript.parse_tokens_from_raw(string), _stmt)

## Converts raw tokens into workable symbols (Variants).
static func from_tokens(tokens: Array[Token], _stmt: Stmt = null) -> Expr:
	var stack : Array[Variant] = []
	var ops : Array[Op] = []

	for token in tokens:
		match token.type:
			Token.VALUE_BOOLEAN, Token.VALUE_NUMBER, Token.VALUE_COLOR, Token.VALUE_STRING:
				stack.push_back(token.value)
			Token.IDENTIFIER:
				stack.push_back(token.value)
			Token.OPERATOR:
				if token.value == ',': continue
				var op := Op.new(token.value)
				while ops and op.type <= ops.back().type:
					ops.pop_back().apply_static(stack)
				match op.type:
					Op.LOOKUP, Op.DOT, Op.ARRAY_OPEN, Op.ARRAY_CLOSE:
						ops.push_back(op)
					Op.ITERATOR:
						pass
					_:
						stack.push_back(op)
			_:
				if _stmt:
					_stmt.push_exception("Expression not evaluated: unexpected token '%s'" % token)
				else:
					PennyException.new("Expression not evaluated: unexpected token '%s'" % token).push_error()
				return null

	while ops:
		ops.pop_back().apply_static(stack)

	for i in stack.size():
		var element = stack[i]
		if element is StringName:
			stack[i] = Path.new([element], false)

	return Expr.new(_stmt, stack)


func _to_string() -> String:
	var result := "=> "
	for symbol in symbols:
		result += "%s " % symbol
	return result.substr(0, result.length() - 1)


func _evaluate_shallow(context: PennyObject) -> Variant:
	var stack : Array[Variant] = []
	var ops : Array[Op] = []

	for symbol in symbols:
		if symbol is Op:
			if symbol.type == Op.ITERATOR: continue
			while ops and symbol.type <= ops.back().type:
				ops.pop_back().apply(stack, context)
			ops.push_back(symbol)
		else:
			stack.push_back(symbol)
	while ops:
		ops.pop_back().apply(stack, context)

	if stack.size() != 1:
		PennyException.new("Expression not evaluated: stack size is not 1. Symbols: %s | Stack: %s" % [str(symbols), str(stack)]).push_error()
		return null
	var result = stack.pop_back()
	# if result == null:
	# 	PennyException.new("Expression '%s' evaluated to null." % self).push_warn()
	# 	return null

	return result


static func type_safe_equals(a: Variant, b: Variant) -> bool:
	if typeof(a) != typeof(b):
		return false
	return a == b
