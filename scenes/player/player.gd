extends CharacterBody2D
 
# speed in pixels/sec
var speed = 200
var playerSprite
# ray from Player to PlantTrays (on layer 2) and TraySlots (on layer 3)
var ray
# change direction of ray when player changes direction
var ray_down = Vector2(0, 35)
var ray_up = Vector2(0, -35)
var ray_left = Vector2(0, 0)
var ray_right = Vector2(0, 0)

var last_dir = Vector2.ZERO
var last_hit_object
var last_pos = Vector2.ZERO
var collided = 0
var carryTray # null if Player is not carrying. Otherwise plantTray object being caried
var clearCarry = false # true once tray has cleared the table and player is carrying
var dropTrayOffset = Vector2(0, 11)
var carryTrayDown = Vector2(0, 30) # relative offsets to player sprite
var carryTrayUp = Vector2(0, -5)
var canCarryShader = Vector4(0.976, 0.514, 0.208, 1.00) #orange
var canDropShader = Vector4(0.141, 0.788, 0.137, 1.0) #green
var carryingShader = Vector4(0.976, 0.184, 0.208, 1.0) #red

var debug = false
var smartString = ["", "", "", "", ""] # debugging

func _ready():
	playerSprite = $Sprite
	 
	ray = $TrayRay
	UIManager.show_message("Start Game", "Go")
	
func smartPrint(index, string):
	if !debug:
		return
	if (smartString.get(index) != string):
		print(str(index) + " " + string)
		smartString.set(index, string)

func _physics_process(_delta):
	var collider
	var hit_plant_sprite = null
	var hit_tray_slot = null
	var select_action = Input.is_action_just_pressed("ui_select")
	
	# Table/TraySlot1/CollisionShape2D
	# PlantTray/CollisionPlantTray
	if ray.is_colliding() == false:
		smartPrint(1, "no collision")
		if last_hit_object && last_hit_object.has_node("PlantSprite"):
			if !carryTray:
				last_hit_object.get_node("PlantSprite").use_parent_material = false # turns off shader effect
			smartPrint(3, "last hit was plant sprite") 
		if carryTray:
			smartPrint(0, "carry tray: "+carryTray.get_name()+" "+str(carryTray.material.get('shader_parameter/line_color')))
			clearCarry = true
			carryTray.material.set('shader_parameter/line_color', carryingShader)
	else:
		collider = ray.get_collider()
		last_hit_object = collider
		smartPrint(1, "ray is colliding with: "+collider.get_path().get_concatenated_names())

		# parents() /main/PlantTrayN or /Table/TraySlotN
		if (collider.get_parent() is Table):
			var table: Table = collider.get_parent()
			var slot_occupied = table.is_slot_occupied(collider)
			if !slot_occupied:
				hit_tray_slot = collider
				if carryTray && clearCarry:
					carryTray.material.set('shader_parameter/line_color', canDropShader)
			smartPrint(2, collider.get_name() + (" (occupied)" if slot_occupied else ""))

		# children() Tray /PlantTray/PlantSprite or Table /Table/TableSprite
		elif collider.has_node("PlantSprite"):
			hit_plant_sprite = collider.get_node("PlantSprite")
			if !carryTray:
				hit_plant_sprite.use_parent_material = true
				smartPrint(2, "not carrying tray")
				if select_action:
					carryTray = collider
					smartPrint(2, "pick up tray")
					select_action = false
					carryTray.set_collision_layer_value(2, false) # prevent future hits on carried tray
					# Notify table that tray was removed
					if carryTray.has_method("get_current_table"):
						var tray_table = carryTray.get_current_table()
						if tray_table:
							tray_table.remove_tray(carryTray)
			else:
				smartPrint(2, "carrying tray")
	
	# PlayerSprite motion and animations
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_down"):
		direction = Vector2.DOWN
		ray.set_target_position(ray_down)
		if collided:
			playerSprite.play("stop-down")
		else:
			playerSprite.play("walk-down")
	elif Input.is_action_pressed("ui_up"):
		direction = Vector2.UP
		ray.set_target_position(ray_up)
		if collided:
			playerSprite.play("stop-up")
		else:
			playerSprite.play("walk-up")
	elif Input.is_action_pressed("ui_left"):
		direction = Vector2.LEFT
		ray.set_target_position(ray_left)
		playerSprite.play("walk-left")
	elif Input.is_action_pressed("ui_right"):
		direction = Vector2.RIGHT
		ray.set_target_position(ray_right)
		playerSprite.play("walk-right")
	else:
		if last_dir == Vector2.UP:
			playerSprite.play("stop-up")
		elif last_dir == Vector2.DOWN:
			playerSprite.play("stop-down")
		else:
			playerSprite.stop()
		
	if (direction && last_dir != direction):
		last_dir = direction
			
	if carryTray:
		if last_dir == Vector2.LEFT || last_dir == Vector2.RIGHT:
			carryTray.position.x = self.position.x
		elif last_dir == Vector2.UP:
			carryTray.position = self.position + carryTrayUp
		elif last_dir == Vector2.DOWN:
			carryTray.position = self.position + carryTrayDown

		if select_action:
			if (hit_tray_slot):
				smartPrint(2, "drop tray")
				carryTray.use_parent_material = false
				carryTray.global_position = hit_tray_slot.global_position + dropTrayOffset
				carryTray.set_collision_layer_value(2, true)
				carryTray.material.set('shader_parameter/line_color', canCarryShader)
				# Notify table that tray was placed
				var drop_table: Table = hit_tray_slot.get_parent()
				drop_table.place_tray_in_slot(hit_tray_slot, carryTray)
				carryTray = null
			else:
				print("can only drop tray on table")
			
	if last_pos != self.position:
		last_pos = self.position
	# setup the actual movement
	velocity = (direction * speed)
	
	move_and_slide()
	collided = get_slide_collision_count()
