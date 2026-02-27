extends CharacterBody2D

@export var gravity = 1000.0
@export var walk_speed = 200
@export var jump_speed = -500

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_stand = $CollisionStand   
@onready var collision_crouch = $CollisionCrouch 
@onready var ceiling_check_left = $CeilingCheckLeft
@onready var ceiling_check_right = $CeilingCheckRight

@export var fall_limit = 675.0 
var spawn_position = Vector2.ZERO

@export var max_jumps = 2
var jump_count = 0

@export var dash_speed = 450
@export var dash_duration = 0.2
@export var double_tap_time = 0.25

var dash_timer = 0.0
var is_dashing = false
var time_since_last_tap = 0.0
var last_tap_dir = ""

@export var crouch_speed = 100 
var is_crouching = false

func _ready():
	spawn_position = global_position

func _physics_process(delta):
	if global_position.y > fall_limit:
		_respawn()
		return

	velocity.y += delta * gravity
	var is_under_ceiling = ceiling_check_left.is_colliding() or ceiling_check_right.is_colliding()

	if is_on_floor() and Input.is_action_pressed("ui_down"):
		is_crouching = true
	elif is_crouching and is_under_ceiling:
		is_crouching = true
	else:
		is_crouching = false

	if is_crouching:
		collision_stand.disabled = true   
		collision_crouch.disabled = false 
	else:
		collision_stand.disabled = false  
		collision_crouch.disabled = true  

	if is_on_floor():
		jump_count = 0 

	if Input.is_action_just_pressed('ui_up') and not is_crouching:
		if is_on_floor() or jump_count < max_jumps:
			velocity.y = jump_speed
			jump_count += 1

	time_since_last_tap += delta 
	
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false

	if is_on_floor() and not is_crouching:
		if Input.is_action_just_pressed("ui_left"):
			_check_dash("left")
		elif Input.is_action_just_pressed("ui_right"):
			_check_dash("right")

	var current_speed = walk_speed
	
	if is_dashing:
		current_speed = dash_speed
	elif is_crouching:
		current_speed = crouch_speed

	if Input.is_action_pressed("ui_left"):
		velocity.x = -current_speed
	elif Input.is_action_pressed("ui_right"):
		velocity.x = current_speed
	else:
		velocity.x = 0

	move_and_slide()
	_update_animation()

func _respawn():
	global_position = spawn_position 
	velocity = Vector2.ZERO          

func _check_dash(dir: String):
	if last_tap_dir == dir and time_since_last_tap <= double_tap_time:
		is_dashing = true
		dash_timer = dash_duration
	
	last_tap_dir = dir
	time_since_last_tap = 0.0

func _update_animation():
	if velocity.x > 0:
		animated_sprite.flip_h = false
	elif velocity.x < 0:
		animated_sprite.flip_h = true 
		
	if not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("jump") 
		else:
			animated_sprite.play("fall") 
	elif is_crouching:
		animated_sprite.play("crouch")   
	elif is_dashing:
		animated_sprite.play("dash")     
	elif velocity.x != 0:
		animated_sprite.play("walk")     
	else:
		animated_sprite.play("idle")
