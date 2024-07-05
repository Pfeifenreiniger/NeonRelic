extends Resource
class_name HealUpStats


###----------PROPERTIES----------###

@export_enum("health", "stamina") var heal_category:String
@export_range(0, 1) var heal_percentage:float = 0
