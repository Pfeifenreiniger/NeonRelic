extends Node
class_name EnumBase


###----------METHODS----------###

func _get_all_constants() -> Dictionary:
	return get_script().get_script_constant_map()


func has_value(value:Variant) -> bool:
	
	var value_present:bool = false
	
	var all_constants:Dictionary = _get_all_constants()
	
	for constant in all_constants:
		if all_constants[constant] == value:
			value_present = true
			break
	
	return value_present
