extends Node

const ACTION = "ui_accept"

var frame_tick_counter := 0
var physic_tick_counter := 0

var frame_indicator = []
var physic_indicator = []

export(NodePath) var fps_label_path:NodePath
export(NodePath) var frame_label_path:NodePath
export(NodePath) var physic_label_path:NodePath
export(NodePath) var difference_label_path:NodePath

export(NodePath) var frame_action_path:NodePath
export(NodePath) var physic_action_path:NodePath
export(NodePath) var input_action_path:NodePath

export(Color) var color_bg = Color.white
export(Color) var color_frame = Color.black
export(Color) var color_pressed = Color.rebeccapurple
export(Color) var color_just_pressed = Color.red
export(Color) var color_just_released = Color.fuchsia
export(Color) var color_input_press = Color.gold
export(Color) var color_input_release = Color.darkgreen

onready var frame_tick_container:Container = $Control/VBoxContainer/FrameTick
onready var physic_tick_container:Container = $Control/VBoxContainer/PhysicTick
onready var fps_label:Label = get_node(fps_label_path)
onready var frame_label:Label = get_node(frame_label_path)
onready var physic_label:Label = get_node(physic_label_path)
onready var difference_label:Label = get_node(difference_label_path)
onready var frame_action_label:Label = get_node(frame_action_path)
onready var physic_action_label:Label = get_node(physic_action_path)
onready var input_action_label:Label = get_node(input_action_path)

func _ready() -> void:
	$Control.connect("gui_input", self, "forwarded_gui_input")
	
	for i in range(60):
		var node := ColorRect.new()
		var p_node
		node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		p_node = node.duplicate(0)
		
		frame_indicator.append(node)
		frame_tick_container.add_child(node)
		
		physic_indicator.append(p_node)
		physic_tick_container.add_child(p_node)
	
	get_tree().connect("idle_frame", self, "_on_idle")
	
	$Control/HBoxContainer/HBoxContainer/MarginContainer/ColorRect.color = color_bg
	$Control/HBoxContainer/HBoxContainer2/MarginContainer/ColorRect.color = color_frame
	$Control/HBoxContainer/HBoxContainer3/MarginContainer/ColorRect.color = color_just_pressed
	$Control/HBoxContainer/HBoxContainer4/MarginContainer/ColorRect.color = color_pressed
	$Control/HBoxContainer/HBoxContainer5/MarginContainer/ColorRect.color = color_just_released
	$Control/HBoxContainer/HBoxContainer6/MarginContainer/ColorRect.color = color_input_press
	$Control/HBoxContainer/HBoxContainer7/MarginContainer/ColorRect.color = color_input_release


func _input(event: InputEvent) -> void:
	
	var p_indicator:Control = physic_indicator[physic_tick_counter]
	var f_indicator:Control = frame_indicator[frame_tick_counter]
	if event.is_action_pressed(ACTION):
		VisualServer.canvas_item_add_rect(p_indicator.get_canvas_item(), p_indicator.get_rect(), Color.gold)
		VisualServer.canvas_item_add_rect(f_indicator.get_canvas_item(), f_indicator.get_rect(), Color.gold)
		input_action_label.text = "Pressed"
	if event.is_action_released(ACTION):
		VisualServer.canvas_item_add_rect(p_indicator.get_canvas_item(), p_indicator.get_rect(), Color.darkgreen)
		VisualServer.canvas_item_add_rect(f_indicator.get_canvas_item(), f_indicator.get_rect(), Color.darkgreen)
		input_action_label.text = "Not Pressed"


func _process(delta: float) -> void:
	frame_tick_counter += 1
	if frame_tick_counter >= 60:
		frame_tick_counter = 0
	
	fps_label.text = str(Engine.get_frames_per_second())
	frame_label.text = str(frame_tick_counter)
	
	var used_color:Color = color_bg
	
	var text := "Not pressed"
	if Input.is_action_pressed(ACTION):
		used_color = color_pressed
		text = "Pressed"
	if Input.is_action_just_pressed(ACTION):
		used_color = color_just_pressed
		text = "Just pressed"
	if Input.is_action_just_released(ACTION):
		used_color = color_just_released
		text = "Just released"
	frame_action_label.text = text
	
	frame_indicator[frame_tick_counter].color = used_color
	if frame_tick_counter < 59:
		frame_indicator[frame_tick_counter + 1].color = color_frame


func _physics_process(delta: float) -> void:
	physic_tick_counter += 1
	
	if physic_tick_counter >= 60:
		physic_tick_counter = 0
	
	physic_label.text = str(physic_tick_counter)
	
	var used_color:Color = color_bg
	
	var text := "Not pressed"
	if Input.is_action_pressed(ACTION):
		used_color = color_pressed
		text = "Pressed"
	if Input.is_action_just_pressed(ACTION):
		used_color = color_just_pressed
		text = "Just pressed"
	if Input.is_action_just_released(ACTION):
		used_color = color_just_released
		text = "Just released"
	physic_action_label.text = text
	
	(physic_indicator[physic_tick_counter] as ColorRect).color = used_color
	if physic_tick_counter < 59:
		physic_indicator[physic_tick_counter + 1].color = color_frame

func _on_idle():
	difference_label.text = str(physic_tick_counter - frame_tick_counter)
