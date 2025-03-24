class_name StateMachine
extends Node

const State := preload("res://player.gd").State

var state_time: float = 0.0


var current_state: State = State.IDLE:
	set(v):
		owner.transition_state(current_state, v)
		current_state = v
		state_time = 0.0


func _ready() -> void:
	await owner.ready
	print("StateMachine ready")
	current_state = State.IDLE

func _physics_process(delta: float) -> void:
	while true:
		var next := owner.get_next_state(current_state) as State
		if current_state == next:
			break
		current_state = next

	owner.tick_physics(current_state, delta)
	state_time += delta
