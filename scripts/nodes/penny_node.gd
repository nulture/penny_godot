
## Should be the root script of any Node that Penny opens/instantiates and needs to have any control over.
class_name PennyNode extends Node

signal closed

## If enabled, Penny will suspend itself when this node is placed in the scene. Imperative for things like menus.
@export var suspend_host_on_populate : bool = false

## If enabled, Penny will resume itself when this node is freed from the scene.
@export var resume_host_on_free : bool = false

## If enabled, this node will immediately call queue_free when it is closed.
@export var free_on_close : bool = true

var host : PennyHost
var object : PennyObject

## Additional data that may be submitted when this node is [member populate]d.
var attach : Variant

## Called immediately after instantiation.
func populate(_host: PennyHost, _object: PennyObject = null) -> void:
	host = _host
	object = _object
	_populate(_host, _object)
func _populate(_host: PennyHost, _object: PennyObject) -> void:
	if suspend_host_on_populate:
		host.is_halting = true

func _ready() -> void:
	pass

func _exit_tree() -> void:
	if object:
		object.clear_instance_upstream()
	if resume_host_on_free:
		host.resume()

func close() -> void:
	closed.emit()
	if free_on_close:
		queue_free()
