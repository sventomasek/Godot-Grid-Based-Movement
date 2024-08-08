extends Node2D

@export_group("Movement")
@export_enum("Platformer", "Top-Down") var movementType = "Platformer"
@export_enum("Left", "Right", "None", "Left or Right", "Left or Right or None") var startDirectionX := "Left or Right"
@export_enum("Up", "Down", "None", "Up or Down", "Up or Down or None") var startDirectionY := "Up or Down"
var moveDirectionX: int
var moveDirectionY: int
@export_enum("None", "Linear", "Move Toward") var interpolation = "None"
@export var interpolationSpeed := 5.0

@export var moveDelayUp := 0.5
@export var moveDelayDown := 0.5
var moveDelayY_: float

@export var moveDelayLeft := 0.5
@export var moveDelayRight := 0.5
var moveDelayX_: float

var oldPosition: Vector2
var newPosition: Vector2

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
	var currentTile: Vector2i = tileMap.local_to_map(global_position)
	newPosition = tileMap.map_to_local(currentTile)
	oldPosition = newPosition
	global_position = newPosition
	
	match startDirectionX:
		"Left": moveDirectionX = -1
		"Right": moveDirectionX = 1
		"Left or Right": moveDirectionX = [-1, 1].pick_random()
		"Left or Right or None": moveDirectionX = [-1, 0, 1].pick_random()
		
	match startDirectionY:
		"Up": moveDirectionY = -1
		"Down": moveDirectionY = 1
		"Up or Down": moveDirectionY = [-1, 1].pick_random()
		"Up or Down or None": moveDirectionY = [-1, 0, 1].pick_random()
		
func _physics_process(delta):
	# Jumping
	if canJump && (moveDirectionX != 0 || !jumpOnlyIfMoving): jumpDelay_ -= delta
	if jumpDelay_ <= 0: start_jump()
	
	# Movement
	update_position()
	
	# Horizontal Movement
	moveDelayX_ -= delta
	var leftTileData: TileData = tileMap.get_cell_tile_data(0, tileMap.local_to_map(global_position) + Vector2i(-1, 0))
	var rightTileData: TileData = tileMap.get_cell_tile_data(0, tileMap.local_to_map(global_position) + Vector2i(1, 0))
	if moveDirectionX < 0 && leftTileData && !leftTileData.get_custom_data("walkable"): moveDirectionX = -moveDirectionX
	if moveDirectionX > 0 && rightTileData && !rightTileData.get_custom_data("walkable"): moveDirectionX = -moveDirectionX
	move_x(moveDirectionX)
	
	# Vertical Movement
	moveDelayY_ -= delta
	if movementType == "Platformer":
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
	elif movementType == "Top-Down":
		var aboveTileData: TileData = tileMap.get_cell_tile_data(0, tileMap.local_to_map(global_position) + Vector2i(0, -1))
		var belowTileData: TileData = tileMap.get_cell_tile_data(0, tileMap.local_to_map(global_position) + Vector2i(0, 1))
		if moveDirectionY < 0 && aboveTileData && !aboveTileData.get_custom_data("walkable"): moveDirectionY = -moveDirectionY
		if moveDirectionY > 0 && belowTileData && !belowTileData.get_custom_data("walkable"): moveDirectionY = -moveDirectionY
		move_y(moveDirectionY)
		
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
	
	oldPosition.x = tileMap.map_to_local(currentTile).x
	newPosition.x = tileMap.map_to_local(targetTile).x
	if direction > 0:  moveDelayX_ = moveDelayRight
	elif direction < 0: moveDelayX_ = moveDelayLeft
	
	# Flip Sprite
	if sprite:
		if moveDirectionX > 0: sprite.flip_h = false
		elif moveDirectionX < 0: sprite.flip_h = true
		
func move_y(direction: int):
	if moveDelayY_ > 0: return
	
	var currentTile: Vector2i = tileMap.local_to_map(global_position)
	var targetTile := Vector2i(currentTile.x, currentTile.y + direction)
	
	oldPosition.y = tileMap.map_to_local(currentTile).y
	newPosition.y = tileMap.map_to_local(targetTile).y
	if direction > 0:  moveDelayY_ = moveDelayDown
	elif direction < 0: moveDelayY_ = moveDelayUp
	
func update_position():
	# Check if next position is inside wall
	var tileData: TileData = tileMap.get_cell_tile_data(0, tileMap.local_to_map(newPosition))
	if tileData && !tileData.get_custom_data("walkable"):
		newPosition = oldPosition
		if randi_range(1, 2) == 1: moveDirectionX *= -1
		else: moveDirectionY *= -1
		return
		
	# Update Position
	var delta = get_physics_process_delta_time()
	oldPosition = newPosition
	match interpolation:
		"Linear": global_position = lerp(global_position, newPosition, delta * interpolationSpeed)
		"Move Toward":
			global_position.x = move_toward(global_position.x, newPosition.x, interpolationSpeed * 0.1)
			global_position.y = move_toward(global_position.y, newPosition.y, interpolationSpeed * 0.1)
		"None": global_position = newPosition
		
func _on_kill_area_body_entered(body):
	if body.name == "Player" || body.is_in_group("Player"):
		await get_tree().create_timer(0.1).timeout
		body.alive = false
