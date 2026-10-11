extends RefCounted
## Stable IDs and atlas rows. Purely cosmetic; never changes player physics.
const ITEMS = preload("res://data/wardrobe_items.gd").ITEMS
const SHEETS = {"hats":preload("res://assets/textures/wardrobe_hats.png"),"outfits":preload("res://assets/textures/wardrobe_outfits.png"),"scarves":preload("res://assets/textures/wardrobe_necks.png")}
const TAILS = preload("res://assets/textures/wardrobe_tails.png")
const DEFAULTS = {"hats":"rose_beanie","scarves":"lagoon","outfits":"trail_coat"}
static var textures: Dictionary = {}
static func entries(category: String) -> Array:
 return ITEMS.get(category,[])
static func item(category: String,id: String) -> Dictionary:
 for entry in entries(category):
  if entry.id==id: return entry
 return entries(category)[0]
static func valid(category: String,id: Variant) -> bool:
 if not id is String: return false
 for entry in entries(category):
  if entry.id==id: return true
 return false
static func texture(category: String,id: String,icon: bool=false) -> Texture2D:
 var key=category+"/"+id+str(icon)
 if textures.has(key): return textures[key]
 var atlas=AtlasTexture.new()
 atlas.atlas=SHEETS[category]
 atlas.region=Rect2(0,int(item(category,id).row)*24,24 if icon else 192,24)
 textures[key]=atlas
 return atlas
static func tail(id: String) -> Texture2D:
 if id=="no_scarf": return null
 var key="tail/"+id
 if not textures.has(key):
  var atlas=AtlasTexture.new();atlas.atlas=TAILS
  atlas.region=Rect2(0,int(item("scarves",id).row)*3,5,3)
  textures[key]=atlas
 return textures[key]
