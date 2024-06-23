extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = get_tree().create_tween()
	tween.tween_method(
		tween_methode_zum_aufrufen, 0.0, 1.0, 0.5
		)
	tween.tween_callback(habe_fertig)


func tween_methode_zum_aufrufen(prozent:float) -> void:
	print("Tween zu %s fertig" % prozent)
	

func habe_fertig() -> void:
	print("Der Tween ist fertig")
