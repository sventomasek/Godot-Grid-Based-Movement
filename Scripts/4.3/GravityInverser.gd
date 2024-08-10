extends Area2D

@export var inversePlayer := true
@export var inverseEnemy := false
@export var inverseDelay := 0.15
@onready var tileMap = %TileMap
@onready var tileMapLayer1: TileMapLayer

func _ready():
	# Get the first TileMap layer
	for child in tileMap.get_children():
		if child is TileMapLayer:
			tileMapLayer1 = child
			break
			
	# Center position to a tiles position
	var currentTile: Vector2i = tileMapLayer1.local_to_map(global_position)
	global_position = tileMapLayer1.map_to_local(currentTile)
	
func _on_body_entered(body):
	if body.is_in_group("Player") && inversePlayer:
		if inverseDelay > 0: await get_tree().create_timer(inverseDelay).timeout
		body.inverseGravity = !body.inverseGravity
	elif body.is_in_group("Enemy") && inverseEnemy:
		if inverseDelay > 0: await get_tree().create_timer(inverseDelay).timeout
		body.inverseGravity = !body.inverseGravity
