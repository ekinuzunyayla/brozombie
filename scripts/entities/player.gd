class_name Player
extends CharacterBody2D
## Oyuncu karakteri. Yalnızca hareket eder; nişan ve ateş silahlara aittir.

## Hedef hıza ulaşma ve durma ivmesi (px/s²). Yüksek değer daha keskin kontrol demek.
@export var acceleration: float = 6000.0
@export var character: CharacterData

var stats: Stats
var _flash: Tween

@onready var camera: Camera2D = %Camera
@onready var health: HealthComponent = %Health
@onready var weapon: Weapon = %Weapon


func _ready() -> void:
	stats = character.create_stats()
	weapon.owner_stats = stats
	health.reset(stats.get_value(StatIds.MAX_HP))
	health.damaged.connect(_on_damaged)


func _physics_process(delta: float) -> void:
	var target: Vector2 = MoveInput.get_vector() * stats.get_value(StatIds.MOVE_SPEED)
	velocity = velocity.move_toward(target, acceleration * delta)
	move_and_slide()


func _on_damaged(_amount: float) -> void:
	if _flash:
		_flash.kill()
	modulate = Color(2.5, 1.0, 1.0)
	_flash = create_tween()
	_flash.tween_property(self, "modulate", Color.WHITE, 0.2)
