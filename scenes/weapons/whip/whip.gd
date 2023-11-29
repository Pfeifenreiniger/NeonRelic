extends AnimatedSprite2D


const IS_WHIP = true

const WHIP_ATTACK_INIT_DAMAGE:int = 10
const WHIP_ATTACK_MAX_DAMAGE:int = 60
const WHIP_ATTACK_DAMAGE_INCREASE:int = 10
var current_whip_attack_damage:int = WHIP_ATTACK_INIT_DAMAGE
var charges_whip_attack:bool = false

@onready var charge_timer:Timer = $ChargeTimer
var started_charge_timer:bool = false


func _ready():
	charge_timer.timeout.connect(on_charge_timer_timeout)


func _process(delta):
	if charges_whip_attack and not started_charge_timer:
		charge_timer.start()
		started_charge_timer = true
		print("Starte Charge")
	elif not charges_whip_attack and started_charge_timer:
		print("Stoppe Charge")
		charge_timer.stop()
		started_charge_timer = false


func increase_whip_attack_damage():
	current_whip_attack_damage += WHIP_ATTACK_DAMAGE_INCREASE
	print("CHARGE! MEIN DAMAGE LAUTET %s" % current_whip_attack_damage)


func reset_whip_attack_damage():
	current_whip_attack_damage = WHIP_ATTACK_INIT_DAMAGE

###----------CONNECTED SIGNALS----------###

func on_charge_timer_timeout():
	if current_whip_attack_damage < WHIP_ATTACK_MAX_DAMAGE:
		print("und erhoehe damage!")
		increase_whip_attack_damage()
	else:
		print("Am Maximum angekommen")
		charges_whip_attack = false
