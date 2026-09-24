extends SceneTree
## Run headlessly after import to regenerate the editor-native atlas and TileMapLayers.
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var tiles := TileSet.new()
 tiles.tile_size=Vector2i(16,16)
 var atlas := TileSetAtlasSource.new()
 atlas.texture=load("res://assets/textures/terrain_atlas.png")
 atlas.texture_region_size=Vector2i(16,16)
 for y in range(4):
  for x in range(8): atlas.create_tile(Vector2i(x,y))
 tiles.add_source(atlas,0)
 ResourceSaver.save(tiles,"res://assets/terrain_tileset.tres")
 var level=load("res://scenes/levels/training_yard.tscn").instantiate()
 for ledge in level.get_node("Terrain").get_children():
  for old in ledge.get_children():
   if old is Sprite2D or old is TileMapLayer:
    ledge.remove_child(old)
    old.free()
  var shape: RectangleShape2D=ledge.get_node("CollisionShape2D").shape
  var grid := TileMapLayer.new()
  grid.name="TerrainTiles"
  grid.tile_set=tiles
  grid.position=-shape.size/2
  ledge.add_child(grid)
  grid.owner=level
  var width := int(shape.size.x/16)
  var height := int(shape.size.y/16)
  for y in range(height):
   for x in range(width):
    var edge := 0 if x==0 else (4 if x==width-1 else 1+posmod(x*7+y*3+ledge.get_index(),3))
    var row := 0 if y==0 else (2 if y==height-1 else 1)
    grid.set_cell(Vector2i(x,y),0,Vector2i(edge,row))
  for x in range(width):
   if posmod(x+ledge.get_index(),3)!=1: grid.set_cell(Vector2i(x,height),0,Vector2i(posmod(x,8),3))
 var packed := PackedScene.new()
 packed.pack(level)
 ResourceSaver.save(packed,"res://scenes/levels/training_yard.tscn")
 # Reusable actors already own their signal connections; avoid serializing duplicates.
 var scene_path := "res://scenes/levels/training_yard.tscn"
 var lines := FileAccess.get_file_as_string(scene_path).split("\n")
 var clean := PackedStringArray()
 for text in lines:
  if not text.begins_with("[connection "): clean.append(text)
 var output := FileAccess.open(scene_path,FileAccess.WRITE)
 output.store_string("\n".join(clean))
 output.close()
 level.free()
 print("Saved shared TileSet and 13 editable TileMapLayers; explicit collisions retained.")
 quit()
