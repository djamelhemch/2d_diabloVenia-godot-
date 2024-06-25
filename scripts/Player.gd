extends CharacterBody2D

@onready var animation_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer

const speed = 185.0
const gravity = 38
const jump_power  = -600.0
var direction
var can_input = true
#main state machine variable
var main_sm: LimboHSM

func _ready():
	initiate_state_machine()
	
func _physics_process(delta):
	#print(main_sm.get_active_state())
	if not can_input and is_on_floor():
		return 0.0
	direction = Input.get_action_strength("right") - Input.get_action_strength("left")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	velocity.y += gravity
	
	flip_sprite(direction)
	move_and_slide()
func flip_sprite(direction):
	if direction == 1:
		animation_sprite.flip_h = false
	elif direction == -1:
		animation_sprite.flip_h = true
		
func _unhandled_input(event):
	if event.is_action_pressed("jump"):
		main_sm.dispatch(&"to_jump")
	elif event.is_action_pressed("attack1"):
		main_sm.dispatch(&"to_attack1")
	elif event.is_action_pressed("attack2"):
		main_sm.dispatch(&"to_attack2")
	elif event.is_action_pressed("attack3"):
		main_sm.dispatch(&"to_attack3")
		
func initiate_state_machine():
	main_sm = LimboHSM.new()
	add_child(main_sm)

	var idle_state = LimboState.new().named("idle").call_on_enter(idle_start).call_on_update(idle_update)
	var run_state = LimboState.new().named("run").call_on_enter(run_start).call_on_update(run_update)
	var jump_state = LimboState.new().named("jump").call_on_enter(jump_start).call_on_update(jump_update)
	var falling_state = LimboState.new().named("falling").call_on_enter(falling_start).call_on_update(falling_update)
	var attack1_state = LimboState.new().named("attack1").call_on_enter(attack1_start).call_on_update(attack1_update)
	var attack2_state = LimboState.new().named("attack2").call_on_enter(attack2_start).call_on_update(attack2_update)
	var attack3_state = LimboState.new().named("attack3").call_on_enter(attack3_start).call_on_update(attack3_update)

	main_sm.add_child(idle_state)
	main_sm.add_child(run_state)
	main_sm.add_child(jump_state)
	main_sm.add_child(falling_state)
	main_sm.add_child(attack1_state)
	main_sm.add_child(attack2_state)
	main_sm.add_child(attack3_state)
	
	main_sm.initial_state = idle_state
	
	main_sm.add_transition(idle_state, run_state, &"to_run")
	main_sm.add_transition(main_sm.ANYSTATE, idle_state, &"state_ended")
	main_sm.add_transition(jump_state, falling_state, &"to_fall")
	main_sm.add_transition(idle_state, jump_state, &"to_jump")
	main_sm.add_transition(run_state, jump_state, &"to_jump")
	
	main_sm.add_transition(idle_state, attack1_state, &"to_attack1")
	main_sm.add_transition(run_state, attack1_state, &"to_attack1")
	
	main_sm.add_transition(main_sm.ANYSTATE,attack2_state, &"to_attack2")
	
	main_sm.add_transition(idle_state, attack3_state, &"to_attack3")
	main_sm.add_transition(run_state, attack3_state, &"to_attack3")
	
	main_sm.initialize(self)
	main_sm.set_active(true)
	
func idle_start():
	animation_sprite.play("idle")
func idle_update(delta: float):
	if velocity.x != 0:
		main_sm.dispatch(&"to_run")
		
func run_start():
	animation_sprite.play("run")
func run_update(delta: float):
	if velocity.x == 0:
		main_sm.dispatch(&"state_ended")
		
func jump_start():
	animation_sprite.play("jump")
	velocity.y = jump_power
	print(velocity.y)
func jump_update(delta : float):
	if velocity.y > jump_power and not is_on_floor():
		main_sm.dispatch(&"to_fall")
		
func falling_start():
	animation_sprite.play("fall")
	print(velocity.y)
func falling_update(delta : float):
	if is_on_floor():
		main_sm.dispatch(&"state_ended")
		
func attack1_start():
	can_input = false
	animation_player.play("attack1")
func attack1_update(delta : float):
	print(animation_player.current_animation)
	if animation_player.current_animation != "attack1":
		main_sm.dispatch(&"state_ended")

func attack2_start():
	can_input = false
	animation_player.play("attack2")
func attack2_update(delta : float):
	print(animation_player.current_animation)
	if animation_player.current_animation != "attack2":
		main_sm.dispatch(&"state_ended")
		
func attack3_start():
	can_input = false
	animation_player.play("attack3")
func attack3_update(delta : float):
	print(animation_player.current_animation)
	if animation_player.current_animation != "attack3":
		main_sm.dispatch(&"state_ended")
		
func ready_for_input():
	can_input = true
