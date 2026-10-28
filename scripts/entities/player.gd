class_name Player
extends CharacterBody2D
## Oyuncu karakteri. Yalnızca hareket eder; nişan ve ateş silahlara aittir.

## Hedef hıza ulaşma ve durma ivmesi (px/s²). Yüksek değer daha keskin kontrol demek.
@export var acceleration: float = 6000.0
@export var character: CharacterData

var stats: Stats

@onready var camera: Camera2D = %Camera


func _ready() -> void:
	stats = character.create_stats()


func _physics_process(delta: float) -> void:
	var target: Vector2 = MoveInput.get_vector() * stats.get_value(StatIds.MOVE_SPEED)
	velocity = velocity.move_toward(target, acceleration * delta)
	move_and_slide()
