extends PointLight2D

###----------SCENE REFERENCES----------###

@onready var whip: Whip = $".." as Whip


###----------PROPERTIES----------###

const ANIMATION_CONFIG:Dictionary = {
	'right' : {
		0 : {
			'position' : Vector2(-57.5, -1),
			'energy' : 1.88,
			'texture_scale' : 1.
		},
		1 : {
			'position' : Vector2(-50, -1),
			'energy' : 1.92,
			'texture_scale' : 1.1
		},
		2: {
			'position' : Vector2(-44, -1),
			'energy' : 1.94,
			'texture_scale' : 1.2
		},
		3 : {
			'position' : Vector2(-35, -1),
			'energy' : 1.96,
			'texture_scale' : 1.3
		},
		4 : {
			'position' : Vector2(-26.5, -1),
			'energy' : 1.98,
			'texture_scale' : 1.4
		},
		5 : {
			'position' : Vector2(-21.5, -1),
			'energy' : 2.,
			'texture_scale' : 1.5
		},
		6 : {
			'position' : Vector2(-12.5, -1),
			'energy' : 2.02,
			'texture_scale' : 1.6
		},
		7 : {
			'position' : Vector2(-4, -1),
			'energy' : 2.04,
			'texture_scale' : 1.7
		},
		8 : {
			'position' : Vector2(10, -1),
			'energy' : 2.06,
			'texture_scale' : 1.8
		},
		9 : {
			'position' : Vector2(17.5, -1),
			'energy' : 2.08,
			'texture_scale' : 1.9
		},
		10 : {
			'position' : Vector2(19, -1),
			'energy' : 2.10,
			'texture_scale' : 2.
		},
		11 : {
			'position' : Vector2(20.5, -1),
			'energy' : 2.22,
			'texture_scale' : 2.1
		}
	},
	'left' : {
		0 : {
			'position' : Vector2(57.5, -1),
			'energy' : 1.88,
			'texture_scale' : 1.
		},
		1 : {
			'position' : Vector2(50, -1),
			'energy' : 1.92,
			'texture_scale' : 1.1
		},
		2: {
			'position' : Vector2(44, -1),
			'energy' : 1.94,
			'texture_scale' : 1.2
		},
		3 : {
			'position' : Vector2(35, -1),
			'energy' : 1.96,
			'texture_scale' : 1.3
		},
		4 : {
			'position' : Vector2(26.5, -1),
			'energy' : 1.98,
			'texture_scale' : 1.4
		},
		5 : {
			'position' : Vector2(21.5, -1),
			'energy' : 2.,
			'texture_scale' : 1.5
		},
		6 : {
			'position' : Vector2(12.5, -1),
			'energy' : 2.02,
			'texture_scale' : 1.6
		},
		7 : {
			'position' : Vector2(4, -1),
			'energy' : 2.04,
			'texture_scale' : 1.7
		},
		8 : {
			'position' : Vector2(-10, -1),
			'energy' : 2.06,
			'texture_scale' : 1.8
		},
		9 : {
			'position' : Vector2(-17.5, -1),
			'energy' : 2.08,
			'texture_scale' : 1.9
		},
		10 : {
			'position' : Vector2(-19, -1),
			'energy' : 2.10,
			'texture_scale' : 2.
		},
		11 : {
			'position' : Vector2(-20.5, -1),
			'energy' : 2.22,
			'texture_scale' : 2.1
		}
	}
}


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	await whip.ready
	
	whip.attack_animation_done.connect(_on_whip_attack_animation_done)


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta: float) -> void:
	if whip.do_attack_animation && !whip.done_attack_animation:
		_adjust_size()


###----------METHODS----------###

func _adjust_size() -> void:
	var current_frame:int = whip.get_frame()
	position = ANIMATION_CONFIG[whip.attack_side][current_frame]['position']
	energy =  ANIMATION_CONFIG[whip.attack_side][current_frame]['energy']
	texture_scale = ANIMATION_CONFIG[whip.attack_side][current_frame]['texture_scale']
	
	if !enabled:
		enabled = true


###----------CONNECTED SIGNALS----------###

func _on_whip_attack_animation_done() -> void:
	if enabled:
		enabled = false
