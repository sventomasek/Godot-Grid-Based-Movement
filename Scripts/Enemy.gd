extends Node2D

@export_group("Movement")
@export var moveWithPlayer := false
@export var allowMoveIntoPlayer := false
@export var allowMoveIntoEnemy := false
@export_enum("Top-Down", "Platformer") var movementType = "Top-Down"

@export_group("Direction")
@export_enum("Left", "Right", "None", "Left or Right", "Left or Right or None") var startDirectionX := "Left or Right"
@export_enum("Up", "Down", "None", "Up or Down", "Up or Down or None") var startDirectionY := "Up or Down"
@export_enum("Touches Wall", "Inverse After X Moves", "Randomize After X Moves") var changeXDirWhen := "Touches Wall"
@export_enum("Touches Wall", "Inverse After Y Moves", "Randomize After Y Moves") var changeYDirWhen := "Touches Wall"
@export var movesBeforeDirChange := Vector2.ONE
var movesDone := Vector2.ZERO
var moveDirectionX: int
var moveDirectionY: int

@export_group("Move Speed")
@export var moveDelayUp := 1.5
@export var moveDelayDown := 1.5
@export var moveDelayYRandom := 0.5
var moveDelayY_: float

@export var moveDelayLeft := 1.5
@export var moveDelayRight := 1.5
@export var moveDelayXRandom := 0.5
var moveDelayX_: float

var oldPosition: Vector2
var newPosition: Vector2

@export_group("Interpolation")
@export_enum("None", "Linear", "Move Toward") var interpolation = "Linear"
@export var interpolationSpeed := 5.0

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

@onready var sprite := $Sprite2D
@onready var tileMap := %TileMap ## Right click on your TileMap and select "Access as Unique name" (make sure the name is TileMap)
@onready var player := %Player ## Do the same for the Player

func _ready():
	# Add self to players enemies array
	player.enemies.append(self)
	
	# Center position to a tiles position
	var currentTile: Vector2i = tileMap.local_to_map(global_position)
	newPosition = tileMap.map_to_local(currentTile)
	oldPosition = newPosition
	global_position = newPosition
	
	randomize_direction()
	
func _physics_process(delta):
	# Movement
	update_position()
	
	## Horizontal Movement
	moveDelayX_ -= delta
	
	var nextDir: String
	if player.moved: nextDir = ["x", "y"].pick_random()
	
	if (player.moved && nextDir == "x") || !moveWithPlayer:
		# Change direction
		if changeXDirWhen == "Touches Wall":
			var leftTileData: TileData = tileMap.get_cell_tile_data(0, tileMap.local_to_map(global_position) + Vector2i(-1, 0))
			var rightTileData: TileData = tileMap.get_cell_tile_data(0, tileMap.local_to_map(global_position) + Vector2i(1, 0))
			if moveDirectionX < 0 && leftTileData && !leftTileData.get_custom_data("walkable"): moveDirectionX = 1
			if moveDirectionX > 0 && rightTileData && !rightTileData.get_custom_data("walkable"): moveDirectionX = -1
		elif changeXDirWhen == "Inverse After X Moves" && movesDone.x >= movesBeforeDirChange.x:
			moveDirectionX = -moveDirectionX
			movesDone.x = 0
		elif changeXDirWhen == "Randomize After X Moves":
			randomize_direction(true, false)
			movesDone.x = 0
			
		# Move
		move_x(moveDirectionX)
		
	## Vertical Movement
	moveDelayY_ -= delta
	if movementType == "Platformer" && ((player.moved && nextDir == "y") || !moveWithPlayer):
		# Check if on floor
		if inverseGravity:
			var aboveTileData: TileData = tileMap.get_cell_tile_data(0, tileMap.local_to_map(global_position) + Vector2i(0, -1))
			isOnFloor = aboveTileData && !aboveTileData.get_custom_data("walkable")
		else:
			var belowTileData: TileData = tileMap.get_cell_tile_data(0, tileMap.local_to_map(global_position) + Vector2i(0, 1))
			isOnFloor = belowTileData && !belowTileData.get_custom_data("walkable")
			
		# Jumping and falling
		if canJump && isOnFloor && (moveDirectionX != 0 || !jumpOnlyIfMoving): jumpDelay_ -= delta
		if isOnFloor && jumpDelay_ <= 0: jump = true
		if jump: start_jump()
		if jumpTime_ > jumpTime: stop_jump()
		if isOnFloor && !jumping: jumpTime_ = 0
		
		if jumping: do_jumping()
		elif !isOnFloor: falling()
	elif movementType == "Top-Down":
		# Change direction
		if changeYDirWhen == "Touches Wall":
			var aboveTileData: TileData = tileMap.get_cell_tile_data(0, tileMap.local_to_map(global_position) + Vector2i(0, -1))
			var belowTileData: TileData = tileMap.get_cell_tile_data(0, tileMap.local_to_map(global_position) + Vector2i(0, 1))
			if moveDirectionY < 0 && aboveTileData && !aboveTileData.get_custom_data("walkable"): moveDirectionY = 1
			if moveDirectionY > 0 && belowTileData && !belowTileData.get_custom_data("walkable"): moveDirectionY = -1
		elif changeYDirWhen == "Inverse After Y Moves" && movesDone.y >= movesBeforeDirChange.y:
			moveDirectionY = -moveDirectionY
			movesDone.y = 0
		elif changeYDirWhen == "Randomize After Y Moves":
			randomize_direction(false, true)
			movesDone.y = 0
			
		# Move
		if (player.moved && nextDir == "y") || !moveWithPlayer: move_y(moveDirectionY)
		
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
	if moveDelayX_ > 0 && !moveWithPlayer: return
	
	var currentTile: Vector2i = tileMap.local_to_map(global_position)
	var targetTile := Vector2i(currentTile.x + direction, currentTile.y)
	
	oldPosition.x = tileMap.map_to_local(currentTile).x
	newPosition.x = tileMap.map_to_local(targetTile).x
	if direction > 0:  moveDelayX_ = randf_range(moveDelayRight - moveDelayXRandom, moveDelayRight + moveDelayXRandom)
	elif direction < 0: moveDelayX_ = randf_range(moveDelayLeft - moveDelayXRandom, moveDelayLeft + moveDelayXRandom)
	
	movesDone.x += 1
	
	# Flip Sprite
	if sprite:
		if moveDirectionX > 0: sprite.flip_h = false
		elif moveDirectionX < 0: sprite.flip_h = true
		
func move_y(direction: int):
	if moveDelayY_ > 0 && !moveWithPlayer: return
	
	var currentTile: Vector2i = tileMap.local_to_map(global_position)
	var targetTile := Vector2i(currentTile.x, currentTile.y + direction)
	
	oldPosition.y = tileMap.map_to_local(currentTile).y
	newPosition.y = tileMap.map_to_local(targetTile).y
	if direction > 0:  moveDelayY_ = randf_range(moveDelayDown - moveDelayYRandom, moveDelayDown + moveDelayYRandom)
	elif direction < 0: moveDelayY_ = randf_range(moveDelayUp - moveDelayYRandom, moveDelayUp + moveDelayYRandom)
	
	movesDone.y += 1
	
func cancel_move():
	newPosition = oldPosition
	if randi_range(1, 2) == 1: moveDirectionX *= -1
	else: moveDirectionY *= -1
	
func update_position():
	# Check if next position is inside player or enemy
	if !allowMoveIntoEnemy:
		for enemy in player.enemies:
			if enemy != self &&  newPosition == enemy.oldPosition:
				cancel_move()
				return
				
	if !allowMoveIntoPlayer:
		if newPosition == player.oldPosition:
			cancel_move()
			return
			
	# Check if next position is inside wall
	for layer in tileMap.get_layers_count():
		var tileData: TileData = tileMap.get_cell_tile_data(layer, tileMap.local_to_map(newPosition))
		if tileData && !tileData.get_custom_data("walkable"):
			cancel_move()
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
		
func randomize_direction(x := true, y := true):
	# Choose a random direction
	if x:
		match startDirectionX:
			"Left": moveDirectionX = -1
			"Right": moveDirectionX = 1
			"Left or Right": moveDirectionX = [-1, 1].pick_random()
			"Left or Right or None": moveDirectionX = [-1, 0, 1].pick_random()
			
	if y && movementType != "Platformer":
		match startDirectionY:
			"Up": moveDirectionY = -1
			"Down": moveDirectionY = 1
			"Up or Down": moveDirectionY = [-1, 1].pick_random()
			"Up or Down or None": moveDirectionY = [-1, 0, 1].pick_random()
			
func _on_kill_area_body_entered(body):
	if body.name == "Player" || body.is_in_group("Player"):
		await get_tree().create_timer(0.1).timeout
		body.alive = false
