
@tool
class_name StmtDialog extends StmtNode

const DEPTH_REMOVAL_PATTERN := "(?<=\\n)\\t{0,%s}"
static var REGEX_WORD_COUNT := RegEx.create_from_string("\\b\\S+\\b")
static var REGEX_CHAR_COUNT := RegEx.create_from_string("\\S")

var subject_dialog_path : Path
var raw_text : String

var text_stripped : String :
	get:
		var result : String = raw_text
		# result = Text.REGEX_INTERPOLATION.sub(result, "$1", true)
		result = Text.INTERJECTION_PATTERN.sub(result, "", true)
		result = Text.DECO_TAG_PATTERN.sub(result, "", true)
		return result

var word_count : int :
	get: return REGEX_WORD_COUNT.search_all(text_stripped).size()


var char_count : int :
	get: return text_stripped.length()


var char_count_non_whitespace : int :
	get: return REGEX_CHAR_COUNT.search_all(text_stripped).size()


func _get_keyword() -> StringName:
	return 'dialog'


func _get_verbosity() -> Verbosity:
	return Verbosity.MAX


func _get_is_rollable() -> bool:
	return true


func _validate_self() -> PennyException:
	if tokens.back().type != Token.VALUE_STRING:
		return create_exception("The last token must be a String.")
	return null


func _validate_self_post_setup() -> void:
	var rx_whitespace = RegEx.create_from_string(DEPTH_REMOVAL_PATTERN % nest_depth)
	raw_text = rx_whitespace.sub(tokens.pop_back().value, "", true)


	super._validate_self_post_setup()
	subject_dialog_path = subject_path.duplicate()
	subject_dialog_path.ids.push_back(PennyObject.BILTIN_DIALOG_NAME)


func _get_history_listing_scene() -> PackedScene :
	return load("res://addons/penny_godot/assets/scenes/history_listings/history_listing_dialog.tscn")


# func _validate_cross() -> PennyException:
# 	return null


func _execute(host: PennyHost) :
	var incoming_dialog : PennyObject = self.subject_dialog_path.evaluate()
	if not incoming_dialog:
		push_exception("Attempted to create dialog box for '%s', but no such object exists" % self.subject_dialog_path)
		return create_record(host)
	var incoming_dialog_node : DialogNode
	var previous_dialog : PennyObject = host.last_dialog_object

	var previous_dialog_node : DialogNode
	var incoming_needs_creation : bool

	if previous_dialog != null:
		previous_dialog_node = previous_dialog.local_instance
		incoming_needs_creation = previous_dialog_node == null or previous_dialog != incoming_dialog
	else:
		previous_dialog_node = null
		incoming_needs_creation = true

	# print("Previous: ", previous_dialog, ", Incoming: ", incoming_dialog)
	# print("Previous node: ", previous_dialog_node)
	# print("Incoming needs creation: ", incoming_needs_creation)

	if incoming_needs_creation:
		if previous_dialog_node != null:
			await previous_dialog_node.close(true)
		incoming_dialog_node = self.instantiate_node_from_object(host, incoming_dialog)
		await incoming_dialog_node.open(true)
	else:
		incoming_dialog_node = previous_dialog_node

	var what := DecoratedText.from_raw(raw_text)
	var result := create_record(host, { "who": subject, "what": what })
	incoming_dialog_node.receive(result)

	await incoming_dialog_node.advanced

	return result


func _abort(host: PennyHost) -> Record:
	var what := DecoratedText.from_raw(raw_text)
	var result := create_record(host, { "who": subject, "what": what })
	return result
