
@tool
extends Node3D

var _sprite_switcher : SpriteSwitcher
@export var sprite_switcher : SpriteSwitcher :
	get: return _sprite_switcher
	set(value):
		if _sprite_switcher == value: return
		_sprite_switcher = value
		pixel_size = _pixel_size


var _material : Material
@export var material : Material :
	get: return _material
	set(value):
		if _material == value: return
		_material = value

		if not mesh_instance: return

		self.quad.surface_set_material(0, _material)


var _pixel_size : float = 0.001
@export_range(0.0001, 128, 0.0001, "m") var pixel_size : float = 0.001 :
	get: return _pixel_size
	set(value):
		_pixel_size = value

		if not mesh_instance: return
		if sprite_switcher:
			quad.size = sprite_switcher.size * _pixel_size
		else:
			quad.size = Vector2.ONE


@export var offset : Vector3 :
	get: return self.mesh_instance.position
	set(value):
		self.mesh_instance.position = value


var _cast_shadow := GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
@export var cast_shadow := GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED :
	get: return _cast_shadow
	set(value):
		_cast_shadow = value
		self.opacity = self.opacity


@export var opacity : float :
	get: return 1.0 - self.mesh_instance.transparency
	set(value):
		self.mesh_instance.transparency = 1.0 - value
		if self.material is ShaderMaterial:
			self.material.set_shader_parameter('opacity_scalar', value)
		if value < 1.0:
			self.mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		else:
			self.mesh_instance.cast_shadow = self.cast_shadow


var quad : QuadMesh :
	get: return self.mesh_instance.mesh


var mesh_instance : MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _init() -> void:
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = QuadMesh.new()
	mesh_instance.mesh.surface_set_material(0, material)
	self.add_child.call_deferred(mesh_instance)
	ready_deferred.call_deferred()


# func _ready() -> void:


func ready_deferred() -> void:
	pixel_size = pixel_size
	opacity = opacity
