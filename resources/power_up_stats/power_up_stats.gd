extends Resource
class_name PowerUpStats


###----------PROPERTIES----------###

@export_enum("sword_damage_increase", "whip_damage_increase", "unlimited_stamina", "movement_speed_increase") var buff_type:String
## time duration (in seconds) of buff effect, maximum of 90 seconds
@export_range(1, 90) var buff_duration:float = 1
