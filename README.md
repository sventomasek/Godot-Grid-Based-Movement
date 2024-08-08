# Godot Grid Based Movement
Grid based Movement in Godot for both Platformer and Top-Down Games!
I used these scripts to make my 8x8 platformer game, but it also has an option for Top-Down movement.

Here's an example of what you can make with it:
<p float="left">
   <img src="https://raw.githubusercontent.com/sventomasek/Godot-Grid-Based-Movement/main/Images/Example2.gif" width="500" />
   <img src="https://raw.githubusercontent.com/sventomasek/Godot-Grid-Based-Movement/main/Images/Example.gif" width="400" />
</p>

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
2. Right click on your Player node and select "Access as Unique Name"
3. Configure the settings to your liking
4. Play

# How to add Gravity Inversers
1. Add your Player Node to a group called "Player" and enemies to a group called "Enemy"
2. Add an Area2D with a CollisionShape2D
3. Add the GravityInverser.gd script to it
4. Connect the on_body_entered signal of Area2D to itself
5. Configure the settings to your liking
6. Now when the player or an enemy touch it they will fall in the opposite direction!

# Need Help?
You can contact me in my Discord server https://discord.gg/MsF7kN54T7

Just post your issue in the "tech-support" channel and I will try to help as soon as I can.
