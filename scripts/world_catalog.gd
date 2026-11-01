extends RefCounted
## The five worlds, in campaign order. Each has five levels: stage 1 introduces the world's
## mechanic, stages 2-5 mix it with every mechanic introduced before it, rising in difficulty.
const STAGES := 5
const WORLDS := [
 {"id":"lantern_ridge","title":"LANTERN RIDGE","mechanic":"BOOST MINES & SHELLS",
  "intro":"Shoot a mine to ride its blast. Floating shells give back a shot mid-air.",
  "color":Color(1.0,0.79,0.57),"sky":"background","layers":["mountains_far","mountains_near"],"mote":""},
 {"id":"mossy_comet","title":"MOSSY COMET","mechanic":"SPORE PODS",
  "intro":"Shoot a glowing pod to be pulled to it, then fly on past it.",
  "color":Color(0.64,0.92,0.58),"sky":"mossy_comet_sky","layers":["mossy_comet_far","mossy_comet_middle","mossy_comet_near"],"mote":"mossy_comet_mote"},
 {"id":"copper_cloud","title":"COPPER CLOUD","mechanic":"PHASE PLATES",
  "intro":"Shoot a switch to swap which plates are solid.",
  "color":Color(0.98,0.62,0.36),"sky":"copper_cloud_sky","layers":["copper_cloud_far","copper_cloud_middle","copper_cloud_near"],"mote":"copper_cloud_mote"},
 {"id":"velvet_glacier","title":"VELVET GLACIER","mechanic":"CRUMBLING & SLICK ICE",
  "intro":"Crumbles break under you. Slick ice keeps your momentum.",
  "color":Color(0.66,0.85,1.0),"sky":"velvet_glacier_sky","layers":["velvet_glacier_far","velvet_glacier_middle","velvet_glacier_near"],"mote":"velvet_glacier_mote"},
 {"id":"echo_orchard","title":"ECHO ORCHARD","mechanic":"WIND GUSTS",
  "intro":"Gusts blow on a beat: ride updrafts, wait out headwinds.",
  "color":Color(0.96,0.72,0.9),"sky":"echo_orchard_sky","layers":["echo_orchard_far","echo_orchard_middle","echo_orchard_near"],"mote":"echo_orchard_mote"},
]
static func texture(name: String) -> Texture2D:
 return load("res://assets/textures/%s.png" % name) if name!="" else null
