extends CharacterBody2D

@export var alive := true

@export_group("Movement")
@export_enum("Platformer", "Top-Down") var movementType = "Platformer"
@export var moveDelayUp := 0.5
@export var moveDelayDown := 0.5
var moveDelayY_: float

@export var moveDelayLeft := 0.5
@export var moveDelayRight := 0.5
var moveDelayX_: float

@export_group("Jumping")
@export var inverseGravity := false
@export var jumpTime := 2.0
var jumpTime_: float
var jumping: bool
var isOnFloor: bool

@onready var collision = $CollisionShape2D
@onready var sprite = $Sprite2D
@onready var tileMap = %TileMap ## Right click on your TileMap and select "Access as Unique name" (make sure the name is TileMap)

func _ready():
	global_position = tileMap.map_to_local(global_position)
	
func _physics_process(delta):
	# Death
	if alive: deathScreen.visible = false
	else:
		if collision: collision.disabled = true
		visible = false
		return
		
	# Horizontal Movement
	moveDelayX_ -= delta
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction > 0: move_x(1)
	elif direction < 0: move_x(-1)
	
	# Flip Sprite
	if sprite:
		if direction > 0: sprite.flip_h = false
		elif direction < 0: sprite.flip_h = true
		
	# Vertical Movement
	moveDelayY_ -= delta
	
	# Check if on floor
	if movementType == "Platformer":
		if inverseGravity:
			var aboveTileData: TileData = tileMap.get_cell_tile_data(0, tileMap.local_to_map(global_position) + Vector2i(0, -1))
			isOnFloor = aboveTileData && !aboveTileData.get_custom_data("walkable")
		else:
			var belowTileData: TileData = tileMap.get_cell_tile_data(0, tileMap.local_to_map(global_position) + Vector2i(0, 1))
			isOnFloor = belowTileData && !belowTileData.get_custom_data("walkable")
			
		# Jumping and falling
		if isOnFloor: 
			if inverseGravity && Input.is_action_just_pressed("jump_inversed"): start_jump()
			elif !inverseGravity && Input.is_action_just_pressed("jump"): start_jump()
			
		if (inverseGravity && Input.is_action_just_released("jump_inversed")) || jumpTime_ > jumpTime: stop_jump()
		elif (!inverseGravity && Input.is_action_just_released("jump")) || jumpTime_ > jumpTime: stop_jump()
		
		if isOnFloor && !jumping: jumpTime_ = 0
		
		if jumping: do_jumping()
		elif !isOnFloor: falling()
	elif movementType == "Top-Down":
		var directionY = Input.get_axis("move_down", "move_up")
		if directionY > 0: move_y(-1)
		elif directionY < 0: move_y(1)
		
func start_jump():
	jumping = true
	
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
