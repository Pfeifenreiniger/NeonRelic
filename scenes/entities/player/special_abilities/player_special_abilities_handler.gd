class_name PlayerSpecialAbilitiesHandler
extends Node


###----------NODE REFERENCES----------###

@onready var all_or_nothing_ability: AllOrNothingAbility = $AllOrNothingAbility as AllOrNothingAbility
@onready var platzhalter_ability: Node = $PlatzhalterAbility as Node


###----------PROPERTIES----------###

var all_abilities:Dictionary


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	all_abilities['all_or_nothing'] = all_or_nothing_ability


###----------METHODS----------###

func use_currently_active_ability() -> void:
	for ability in all_abilities:
		if !'is_active' in all_abilities[ability]:
			printerr("DER ABILITY %s FEHLT DAS 'is_active' ATTRIBUT!" % ability)
			continue
		
		if all_abilities[ability].is_active:
			all_abilities[ability].use_ability()
