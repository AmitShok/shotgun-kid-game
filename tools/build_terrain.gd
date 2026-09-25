extends SceneTree
## Configure native tile collision and migrate legacy platforms without altering painted cells.
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var tiles := TileSet.new()
 tiles.tile_size=Vector2i(16,16)
 tiles.add_physics_layer()
 tiles.set_physics_layer_collision_layer(0,1)
 tiles.set_physics_layer_collision_mask(0,0)
 var atlas := TileSetAtlasSource.new()
 atlas.texture=load("res://assets/textures/terrain_atlas.png")
 atlas.texture_region_size=Vector2i(16,16)
 for y in range(4):
  for x in range(8):
   var cell := Vector2i(x,y)
   atlas.create_tile(cell)
 tiles.add_source(atlas,0)
 for y in range(3):
  for x in range(8):
   var data := atlas.get_tile_data(Vector2i(x,y),0)
   data.set_collision_polygons_count(0,1)
   data.set_collision_polygon_points(0,0,PackedVector2Array([Vector2(-8,-8),Vector2(8,-8),Vector2(8,8),Vector2(-8,8)]))
 # Bottom-row hanging rocks/icicles are purely decorative and stay non-solid.
 ResourceSaver.save(tiles,"res://assets/terrain_tileset.tres")
 tiles.take_over_path("res://assets/terrain_tileset.tres")
 var level=load("res://scenes/levels/training_yard.tscn").instantiate()
 var terrain=level.get_node("Terrain")
 for ledge in terrain.get_children():
  if ledge is TileMapLayer:
   ledge.tile_set=tiles
   continue
  var old_grid: TileMapLayer=ledge.get_node("TerrainTiles")
  var grid := TileMapLayer.new()
  grid.name=ledge.name
  grid.position=ledge.position+old_grid.position
  grid.tile_set=tiles
  for cell in old_grid.get_used_cells():
   grid.set_cell(cell,old_grid.get_cell_source_id(cell),old_grid.get_cell_atlas_coords(cell),old_grid.get_cell_alternative_tile(cell))
  terrain.remove_child(ledge)
  ledge.free()
  terrain.add_child(grid)
  grid.owner=level
 var packed := PackedScene.new()
 packed.pack(level)
 ResourceSaver.save(packed,"res://scenes/levels/training_yard.tscn")
 # Instanced actors already contain their own connections.
 var path := "res://scenes/levels/training_yard.tscn"
 var lines := FileAccess.get_file_as_string(path).split("\n")
 var clean := PackedStringArray()
 for line in lines:
  if not line.begins_with("[connection "): clean.append(line)
 var file := FileAccess.open(path,FileAccess.WRITE)
 file.store_string("\n".join(clean))
 file.close()
 level.free()
 print("Native TileSet physics configured; platform collision boxes removed; painted cells preserved.")
 quit()
