# Godot Grid Based Movement
Grid based Movement in Godot for both Platformer and Top-Down Games!

I used these scripts to make my 8x8 platformer game! But it also has an option for Top-Down movement.
<img src="https://raw.githubusercontent.com/sventomasek/Godot-Grid-Based-Movement/main/Example.gif" width="400" />

# How to use
1. Place the scripts in your Godot project
2. Make sure your TileMap node is called "TileMap"
3. Right click on your TileMap node and select "Access as Unique Name"
4. On your TileSet in the Inspector add a Custom Data Layer "walkable" type bool
5. Now every tile you place should act as a wall by default, if you want some to not you will need to go to your TileSet and set Custom Data "walkable" to true on each one
6. Add the Player.gd script to your Player Node
7. Configure the settings to your liking (especially the Keybinds section!)
8. Play

# How to add Enemies
1. Add the Enemy.gd script to your Enemy Node
2. Configure the settings to your liking
3. Play

# How to add Gravity Inversers
1. Add your Player Node to a group called "Player" and enemies to a group called "Enemy"
2. Add an Area2D with a CollisionShape2D
3. Add the GravityInverser.gd script to it
4. Connect the on_body_entered signal of Area2D to itself
5. Configure the settings to your liking
6. Now when the player or an enemy touch it they will fall in the opposite direction!
