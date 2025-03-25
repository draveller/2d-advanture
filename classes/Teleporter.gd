class_name Teleporter
extends Interactable


@export_file("*.tscn") var path: String

@export var entry_point: String


func interact(player: Player) -> void:
    super.interact(player)
    Game.change_scene(path, entry_point)
