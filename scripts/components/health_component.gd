class_name HealthComponent
extends Node
## Can. Oyuncu, zombi, barikat ve taret aynı bileşeni kullanır.

signal health_changed(current: float, maximum: float)
signal damaged(amount: float)
## Can sıfıra indiğinde bir kez yayılır.
signal died

var current: float = 0.0
var maximum: float = 0.0


## Canı doldurur. Havuzdan yeniden kullanılan varlıklar her doğuşta bunu çağırır.
func reset(p_maximum: float) -> void:
	maximum = p_maximum
	current = p_maximum
	health_changed.emit(current, maximum)


func is_dead() -> bool:
	return current <= 0.0


func take_damage(amount: float) -> void:
	if is_dead() or amount <= 0.0:
		return
	current = maxf(0.0, current - amount)
	damaged.emit(amount)
	health_changed.emit(current, maximum)
	if is_dead():
		died.emit()


func heal(amount: float) -> void:
	if is_dead() or amount <= 0.0:
		return
	current = minf(maximum, current + amount)
	health_changed.emit(current, maximum)
