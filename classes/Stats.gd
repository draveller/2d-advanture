class_name Stats
extends Node


signal health_changed

@export var max_health := 3

@onready var health := max_health:
    set(value):
        value = clampi(value, 0, max_health)
        if health == value:
            return
        health = value
        health_changed.emit()
