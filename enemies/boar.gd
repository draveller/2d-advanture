extends Enemy


enum State {
    IDLE,
    WALK,
    RUN,
    HURT,
    DYING,
}

const KNOCKBACK_AMOUNT: float = 500.0

var pending_damage: Damage


@onready var wall_checker: RayCast2D = $Graphics/WallChecker
@onready var player_checker: RayCast2D = $Graphics/PlayerChecker
@onready var floor_checker: RayCast2D = $Graphics/FloorChecker
@onready var calm_down_timer: Timer = $CalmDownTimer

func can_see_player() -> bool:
    if not player_checker.is_colliding():
        return false
    return player_checker.get_collider() is Player


func tick_physics(state: State, delta: float) -> void:
    match state:
        State.IDLE, State.HURT, State.DYING:
            move(0.0, delta)
        State.WALK:
            move(max_speed / 3, delta)
        State.RUN:
            if wall_checker.is_colliding() or not floor_checker.is_colliding():
                @warning_ignore("int_as_enum_without_cast")
                direction *= -1
            move(max_speed, delta)
            if can_see_player():
                calm_down_timer.start()


func get_next_state(state: int) -> int:
    if stats.health <= 0:
        return StateMachine.KEEP_CURRENT if state == State.DYING else State.DYING

    if pending_damage:
        return State.HURT

    match state as State:
        State.IDLE:
            if can_see_player():
                return State.RUN
            if state_machine.state_time > 2.0:
                return State.WALK
        State.WALK:
            if wall_checker.is_colliding() or not floor_checker.is_colliding():
                return State.IDLE
        State.RUN:
            if not can_see_player() and calm_down_timer.is_stopped():
                return State.WALK
        State.HURT:
            if not animation_player.is_playing():
                return State.RUN

    return StateMachine.KEEP_CURRENT


func transition_state(_from: State, to: State) -> void:
    match to:
        State.IDLE:
            animation_player.play("idle")
            if wall_checker.is_colliding():
                @warning_ignore("int_as_enum_without_cast")
                direction *= -1
        State.WALK:
            animation_player.play("walk")
            if not floor_checker.is_colliding():
                @warning_ignore("int_as_enum_without_cast")
                direction *= -1
                floor_checker.force_raycast_update()
        State.RUN:
            animation_player.play("run")
        State.HURT:
            animation_player.play("hit")
            stats.health -= pending_damage.amount
            var dir := pending_damage.source.global_position.direction_to(global_position)
            velocity = dir * KNOCKBACK_AMOUNT

            if dir.x > 0.0:
                direction = Direction.LEFT
            else:
                direction = Direction.RIGHT
            pending_damage = null

        State.DYING:
            animation_player.play("die")


func _on_hurt_box_hurt(hitbox: HitBox) -> void:
    print("[boar] Hurt by %s" % hitbox.owner.name)
    pending_damage = Damage.new()
    pending_damage.amount = 1
    pending_damage.source = hitbox.owner

    stats.health -= 1
    if stats.health <= 0:
        queue_free()
