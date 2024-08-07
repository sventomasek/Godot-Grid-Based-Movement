extends Node2D

@export_group("Movement")
@export_enum("Left", "Right", "None", "Left or Right", "Left or Right or None") var startDirection := "Left or Right"
var moveDirection: int

@export var moveDelayUp := 0.5
@export var moveDelayDown := 0.5
var moveDelayY_: float

@export var moveDelayLeft := 0.5
@export var moveDelayRight := 0.5
var moveDelayX_: float

@export_group("Jumping")
@export var canJump := true
@export var jumpOnlyIfMoving := true
@export var inverseGravity := false
@export var jumpTime := 2.0
var jumpTime_: float

@export var jumpDelayMin := 1.5
@export var jumpDelayMax := 3.0
@onready var jumpDelay_ = randf_range(jumpDelayMin, jumpDelayMax)

var jump := false ## Set to true to trigger a jump
var jumping := false
var isOnFloor: bool

@onready var sprite = $Sprite2D
@onready var tileMap = %TileMap ## Right click on your TileMap and select "Access as Unique name" (make sure the name is TileMap)

func _ready():
	global_position = tileMap.map_to_local(global_position)
	match startDirection:
		"Left": moveDirection = -1
		"Right": moveDirection = 1
		"Left or Right": moveDirection = [-1, 1].pick_random()
		"Left or Right or None": moveDirection = [-1, 0, 1].pick_random()
		
func _physics_process(delta):
	# Jumping
	if canJump && (moveDirection != 0 || !jumpOnlyIfMoving): jumpDelay_ -= delta
	if jumpDelay_ <= 0: start_jump()
	
	# Horizontal Movement
	moveDelayX_ -= delta
	var leftTileData: TileData = tileMap.get_cell_tile_data(0, tileMap.local_to_map(global_position) + Vector2i(-1, 0))
	var rightTileData: TileData = tileMap.get_cell_tile_data(0, tileMap.local_to_map(global_position) + Vector2i(1, 0))
	if moveDirection < 0 && leftTileData && !leftTileData.get_custom_data("walkable"): moveDirection = -moveDirection
	if moveDirection > 0 && rightTileData && !rightTileData.get_custom_data("walkable"): moveDirection = -moveDirection
	move_x(moveDirection)
	
	# Flip Sprite
	if sprite:
		if moveDirection > 0: sprite.flip_h = false
		elif moveDirection < 0: sprite.flip_h = true
		
	# Vertical Movement
	moveDelayY_ -= delta
	
	# Check if on floor
	if inverseGravity:
		var aboveTileData: TileData = tileMap.get_cell_tile_data(0, tileMap.local_to_map(global_position) + Vector2i(0, -1))
		isOnFloor = aboveTileData && !aboveTileData.get_custom_data("walkable")
	else:
		var belowTileData: TileData = tileMap.get_cell_tile_data(0, tileMap.local_to_map(global_position) + Vector2i(0, 1))
		isOnFloor = belowTileData && !belowTileData.get_custom_data("walkable")
		
	# Jumping and falling
	if isOnFloor && jump: start_jump()
	if jumpTime_ > jumpTime: stop_jump()
	if isOnFloor && !jumping: jumpTime_ = 0
	
	if jumping: do_jumping()
	elif !isOnFloor: falling()
	
func start_jump():
	jumpDelay_ = randf_range(jumpDelayMin, jumpDelayMax)
	jumping = true
	jump = false
	
func stop_jump():
	jumping = false
	
func do_jumping():
	if inverseGravity: move_y(1)
	else: move_y(-1)
	jumpTime_ += get_physics_process_delta_time()
	
func falling():
	if inverseGravity: move_y(-1)
	else: move_y(1)
	
func move_x(direction: int):
	if moveDelayX_ > 0: return
	
	var currentTile: Vector2i = tileMap.local_to_map(global_position)
	var targetTile := Vector2i(currentTile.x + direction, currentTile.y)
	var tileData: TileData = tileMap.get_cell_tile_data(0, targetTile)
	if tileData && !tileData.get_custom_data("walkable"): return
	
	global_position.x = tileMap.map_to_local(targetTile).x
	if direction > 0:  moveDelayX_ = moveDelayRight
	elif direction < 0: moveDelayX_ = moveDelayLeft
	
func move_y(direction: int):
	if moveDelayY_ > 0: return
	
	var currentTile: Vector2i = tileMap.local_to_map(global_position)
	var targetTile := Vector2i(currentTile.x, currentTile.y + direction)
	var tileData: TileData = tileMap.get_cell_tile_data(0, targetTile)
	if tileData && !tileData.get_custom_data("walkable"): return
	
	global_position.y = tileMap.map_to_local(targetTile).y
	if direction > 0:  moveDelayY_ = moveDelayDown
	elif direction < 0: moveDelayY_ = moveDelayUp
	
func _on_kill_area_body_entered(body):
	if body.name == "Player":
		await get_tree().create_timer(0.1).timeout
		body.alive = false
