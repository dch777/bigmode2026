# https://jreo.itch.io/jreo-sva

extends Node

var current_settings: SVA
var cache: Array
var sound_nodes: Array
var max_index: int
var node_type

@export var Setting2D_max_distance: int = 2000:
	set(val):
		Setting2D_max_distance = val
		refresh_sound_properties()

@export var Setting2D_attenuation: float = 1:
	set(val):
		Setting2D_attenuation = val
		refresh_sound_properties()

@export_enum("Inverse", "InverseSquare", "Logarithmic", "Disabled") var Setting3D_attenuation_model: int:
	set(val):
		Setting3D_attenuation_model = val
		refresh_sound_properties()

@export var Setting3D_unit_size: float = 1:
	set(val):
		Setting3D_unit_size = val
		refresh_sound_properties()

@export var Setting3D_max_distance: float = 0:
	set(val):
		Setting3D_max_distance = val
		refresh_sound_properties()

@export var Setting3D_attenuation_filter_cutoff_hz: int = 5000:
	set(val):
		Setting3D_attenuation_filter_cutoff_hz = val
		refresh_sound_properties()

@export_range(-80, 0) var Setting3D_attenuation_filter_db: float = -24:
	set(val):
		Setting3D_attenuation_filter_db = val
		refresh_sound_properties()

@export var SettingXD_panning_strength: float = 1:
	set(val):
		SettingXD_panning_strength = val
		refresh_sound_properties()

@export var SettingXD_bus: String = "Master":
	set(val):
		SettingXD_bus = val
		refresh_sound_properties()






func refresh_sound_properties():
	for a in sound_nodes:
		if a is AudioStreamPlayer:
			a = a as AudioStreamPlayer # cast placeholder
		elif a is AudioStreamPlayer2D:
			a = a as AudioStreamPlayer2D # cast placeholder
			a.attenuation = Setting2D_attenuation
			a.panning_strength = SettingXD_panning_strength
			a.max_distance = Setting2D_max_distance
		elif a is AudioStreamPlayer3D:
			a = a as AudioStreamPlayer3D # cast placeholder
			a.attenuation_model = Setting3D_attenuation_model
			a.unit_size = Setting3D_unit_size
			a.attenuation_filter_cutoff_hz = Setting3D_attenuation_filter_cutoff_hz
			a.attenuation_filter_db = Setting3D_attenuation_filter_db
			a.panning_strength = SettingXD_panning_strength
			a.max_distance = Setting3D_max_distance




func cleanup() -> void:
	for i in sound_nodes:
		i.free()
	cache = []
	sound_nodes = []
	

func load_lib(directory: String, nodetype) -> void:
	cleanup()
	current_settings = load("%s/settings_godot3.tres" % directory)
	max_index = -99999
	node_type = nodetype
	for i in current_settings.Streams:
		var a = nodetype.new()
		add_child(a)
		sound_nodes.append(a)
		var stre: AudioStream
		stre = load("%s/%s"% [directory,i[0]])
		stre.loop = true
		a.stream = stre
		if nodetype is AudioStreamPlayer:
			a = a as AudioStreamPlayer # cast placeholder
			a.volume_db = -80
		elif nodetype is AudioStreamPlayer2D:
			a = a as AudioStreamPlayer2D # cast placeholder
			a.volume_db = -80
		elif nodetype is AudioStreamPlayer3D:
			a = a as AudioStreamPlayer3D # cast placeholder
			a.unit_db = -80
			a.max_db = -80
		
		a.bus = SettingXD_bus
		max_index = max(max_index,i[1])
		cache.append([
			a, # audio instance 0
			i[1], # index 1
			float(i[2])/100000.0, # pitch multiplier 2
			i[3], # on throttle volume multiplier 3
			i[4], # off throttle volume multiplier 4
			])

	refresh_sound_properties()

func state(playing: bool) -> void:
	for i in get_children():
		i.playing = playing

func update(rpm: float, throttle: float, vvt: bool) -> void:
	var progress: float = clamp((rpm -current_settings.lowest_index_rpm)/(current_settings.highest_index_rpm -current_settings.lowest_index_rpm),0,1)
	var c_index: float = float(max_index)*progress
	
	if vvt:
		c_index += current_settings.after_vvt_add_index
	else:
		c_index = min(c_index,current_settings.before_vvt_index)
	
	var _pc: float = current_settings.pitch_calibrate
	var volon: float = current_settings.overall_volume
	var voloff: float = current_settings.overall_volume*current_settings.off_volume_multiplier
	var revb: float = current_settings.reverberance
	
	c_index += lerp(current_settings.off_throttle_offset,current_settings.on_throttle_offset,throttle)
	c_index = clamp(c_index,0,max_index)
	
	for i in cache:
		var proximity: float = clamp(1.0 -abs(i[1]-c_index),0,1)
		var otpt: float = pow(proximity,0.5)
		
		otpt *= lerp(i[3]*voloff,i[4]*volon,throttle)
		
		var clamped_db: float = clamp(linear_to_db(max(otpt,0.0)) ,-80,80.0)

		i[0].volume_db = clamped_db
		if node_type == AudioStreamPlayer3D:
			i[0].max_db = clamped_db

		
		if proximity>0.5:
			i[0].pitch_scale = lerp(i[0].pitch_scale, max(i[2]*rpm/_pc,0.01),1.0 -revb)
		else:
			i[0].pitch_scale = max(i[2]*rpm/_pc,0.01)
		
