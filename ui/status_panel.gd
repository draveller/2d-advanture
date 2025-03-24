extends HBoxContainer


@export var stats: Stats
@export var avatar_texture: Texture2D

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var eased_health_bar: TextureProgressBar = $HealthBar/EasedHealthBar
@onready var avatar: TextureRect = $AvatarBox/Avatar

func _ready() -> void:
    stats.health_changed.connect(update_health)
    update_health()
    if avatar_texture:
        avatar.texture = avatar_texture

func update_health() -> void:
    var percentage := 1.0 * stats.health / stats.max_health
    health_bar.value = percentage
    create_tween().tween_property(eased_health_bar, "value", percentage, 0.3)
