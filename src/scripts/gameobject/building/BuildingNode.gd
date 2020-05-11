extends GameObject

class_name Building

var is_city: bool
var is_district: bool
var improvements: Dictionary
var area: Array
var resources_per_turn: Dictionary
var build_curr: String
var build_resources_left: Dictionary
var build_options: Dictionary
var build_options_outdated: bool

const DEFAULT = 0
const ATTACK = 3
const BUILD = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	self.build_options_outdated = true
	self.get_parent().area += self.area
	print(self.get_parent())
	if self.is_city:
		for i in self.area:
			var tile_resources =  GlobalConfig.biome_resources[GlobalConfig.map[i]]
			for j in tile_resources.keys():
				if self.resources_per_turn.keys().has(j):
					self.resources_per_turn[j] += tile_resources[j]
				else:
					self.resources_per_turn[j] = tile_resources[j]
					
		for i in self.improvements.keys():
				if self.resources_per_turn.keys().has(i):
					self.resources_per_turn[i] += improvements[i]
				else:
					self.resources_per_turn[i] = improvements[i]
					
		print("resources: ", self.resources_per_turn)
		self.update_build_options()
	
	
func set_hex_pos(h):
	hex_pos = h
	GlobalConfig.building_tiles[h] = self
	
func turn_start() -> bool:
	if self.mode == BUILD:
		var build_finished = true
		for i in self.build_resources_left.keys():
			print("key: " + str(i))
			self.build_resources_left[i] -= self.resources_per_turn[i]
			print(self.build_resources_left[i])
			if self.build_resources_left[i] > 0:
				build_finished = false
		
		if build_finished:
			self.build_resources_left = Dictionary()
			var new_unit = UnitFactory.build_unit(build_curr,hex_pos,self.get_parent())
			self.get_parent().new_unit(new_unit)
			mode = DEFAULT
		else:
			return false
			

	return true
	
func turn_end():
	pass

func can_build(building = null) -> bool:
	if self.mode == BUILD:
		return false
	elif self.mode == DEFAULT and building == null:
		return true
	if building != null:
		self.update_build_options()
		if self.build_options.has(building):
			var cost = self.build_options[building]["cost"]
			for i in cost.keys():
				if !i in self.resources_per_turn.keys():
					return false
				elif resources_per_turn[i] <= 0:
					return false
			return true
	return false

func start_build(building_name:String):
	if self.can_build(building_name):
		if BuildingFactory.building_templates_by_name.has(building_name):
			pass
#			self.build_turns_left = BuildingFactory.building_templates_by_name[building_name]["build_turns"]
#			if build_turns_left == 0:
#				build_turns_left = -1
#				var new_building = BuildingFactory.build_building(building_name,hex_pos,self.get_parent())
#				self.get_parent().new_building(new_building)
#				mode = DEFAULT
#			else:
#				self.build_curr = building_name
#				self.mode = BUILD
		elif self.build_options.has(building_name):
			print("building start unit")
			self.build_resources_left = self.build_options[building_name]["cost"].duplicate()
			self.build_curr = building_name
			self.mode = BUILD
	else:
		return false
		
func update_build_options():
	self.build_options.clear()
	for i in UnitFactory.unit_templates:
		self.build_options[i["name"]] = {"name":i["name"],"cost":i["cost"].duplicate(),"type":"Unit"}
		
func kill():
	self.visible = false
	SignalManager.kill_building(self)
	self.queue_free()
			
			
func _draw():
	print("draw")
	if is_city:
		print("draw city")
		for i in self.area:
			var points = Array()
			var pos = Hex.hex_to_point(i)
			points.append(pos + Vector2(-Hex.width/4,-Hex.height/2)-self.position)
			points.append(pos + Vector2(Hex.width/4,-Hex.height/2)-self.position)
			points.append(pos + Vector2(Hex.width/2,0)-self.position)
			points.append(pos + Vector2(Hex.width/4,Hex.height/2)-self.position)
			points.append(pos + Vector2(-Hex.width/4,Hex.height/2)-self.position)
			points.append(pos + Vector2(-Hex.width/2,0)-self.position)
			var polygon = PoolVector2Array(points)
			draw_polygon(polygon,PoolColorArray([self.get_parent().colour]))
			
