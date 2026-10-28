class_name Zombie
extends CharacterBody2D
## Zombi. Hedefine yürür, yeterince yaklaşınca belirli aralıklarla vurur.
## Havuzdan alınıp `setup` ile her doğuşta yeniden kurulur.

## Can sıfırlandığında. Doğurucu zombiyi havuza geri koyar.
signal died(zombie: Zombie)

const GROUP: StringName = &"zombies"

var data: ZombieData
var target: Node2D
## Varsa yön buradan gelir (duvarların etrafından dolaşır), yoksa hedefe düz yürür.
var flow: FlowFieldSystem
var _target_health: HealthComponent
var _attack_cooldown: float = 0.0
var _flash: Tween

@onready var health: HealthComponent = %Health
@onready var _shape: CollisionShape2D = %Collision
@onready var _body: Polygon2D = %Body
@onready var _outline: Line2D = %Outline


func _ready() -> void:
	health.died.connect(_on_died)


func setup(p_data: ZombieData, p_target: Node2D, target_health: HealthComponent, at: Vector2, p_flow: FlowFieldSystem = null) -> void:
	data = p_data
	target = p_target
	flow = p_flow
	_target_health = target_health
	global_position = at
	velocity = Vector2.ZERO
	_attack_cooldown = data.attack_interval
	health.reset(data.max_health)
	modulate = Color.WHITE
	_apply_look()
	add_to_group(GROUP)


func is_alive() -> bool:
	return data != null and not health.is_dead()


func take_hit(damage: float) -> void:
	if not is_alive():
		return
	health.take_damage(damage)
	if is_alive():
		_play_hit_flash()


func _physics_process(delta: float) -> void:
	if not is_alive() or target == null:
		return
	var to_target: Vector2 = target.global_position - global_position
	var direction: Vector2 = flow.get_direction(global_position) if flow else to_target.normalized()
	velocity = direction * data.speed
	move_and_slide()
	_attack_cooldown -= delta
	if _attack_cooldown <= 0.0 and to_target.length() <= data.attack_range and _target_health:
		_attack_cooldown = data.attack_interval
		_target_health.take_damage(data.damage)


func _on_died() -> void:
	remove_from_group(GROUP)
	if _flash:
		_flash.kill()
	died.emit(self)


func _play_hit_flash() -> void:
	if _flash:
		_flash.kill()
	modulate = Color(2.5, 2.5, 2.5)
	_flash = create_tween()
	_flash.tween_property(self, "modulate", Color.WHITE, 0.12)


# Placeholder: daire boyutu ve rengi veriden gelir. Çarpışma şekli sahnede local_to_scene.
func _apply_look() -> void:
	(_shape.shape as CircleShape2D).radius = data.radius
	var points := PackedVector2Array()
	for i in 24:
		points.append(Vector2.from_angle(TAU * i / 24.0) * data.radius)
	_body.polygon = points
	_body.color = data.color
	_outline.points = points
