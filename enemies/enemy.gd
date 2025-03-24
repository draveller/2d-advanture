class_name Enemy
extends CharacterBody2D

enum Direction {
	LEFT = -1,
	RIGHT = 1,
}

@export var direction := Direction.LEFT:
	set(value):
		direction = value
		if not is_node_ready():
			await ready
		graphics.scale.x = - direction

@export var max_speed := 180.0
@export var acceleration := 2000.0


var default_gravity := ProjectSettings.get("physics/2d/default_gravity") as float

@onready var graphics: Node2D = $Graphics
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: Node = $StateMachine


func move(speed: float, delta: float) -> void:
	velocity.x = move_toward(velocity.x, speed * direction, acceleration * delta)
	velocity.y += default_gravity * delta
	move_and_slide()
