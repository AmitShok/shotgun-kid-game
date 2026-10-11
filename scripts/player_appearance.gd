extends Node
const CATALOG=preload("res://scripts/wardrobe_catalog.gd")
var hat: Sprite2D
var neck: Sprite2D
@onready var player=get_parent()
@onready var body: Sprite2D=player.get_node("Sprite2D")
func _ready() -> void:
 hat=Sprite2D.new();hat.name="Hat";hat.hframes=8;body.add_child(hat)
 neck=Sprite2D.new();neck.name="NeckWrap";neck.hframes=8;body.add_child(neck)
 SaveData.appearance_changed.connect(apply)
 apply()
func apply() -> void:
 var frame=body.frame
 body.texture=CATALOG.texture("outfits",SaveData.appearance.outfits)
 body.frame=frame
 hat.texture=CATALOG.texture("hats",SaveData.appearance.hats)
 neck.texture=CATALOG.texture("scarves",SaveData.appearance.scarves)
 player.get_node("Scarf").set_style(SaveData.appearance.scarves)
 _process(0)
func _process(_delta: float) -> void:
 hat.frame=body.frame;neck.frame=body.frame
 hat.flip_h=body.flip_h;neck.flip_h=body.flip_h
