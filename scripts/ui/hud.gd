class_name Hud
extends CanvasLayer
## Oyun içi göstergeler: can, dalga, mermi ve dolum. Yalnızca gösterir, oyun durumunu değiştirmez.

## Bu oranın altındaki can kırmızı gösterilir.
const LOW_HEALTH_RATIO: float = 0.3
const HEALTH_COLOR := Color("4caf50")
const LOW_HEALTH_COLOR := Color("e53935")

var _weapon: Weapon
var _wave: int = 0
var _health_fill: StyleBoxFlat

@onready var _health_bar: ProgressBar = %HealthBar
@onready var _health_label: Label = %HealthLabel
@onready var _wave_label: Label = %WaveLabel
@onready var _ammo_label: Label = %AmmoLabel
@onready var _reload_bar: ProgressBar = %ReloadBar


func _ready() -> void:
	# Renk değişimi diğer çubukları etkilemesin diye stil kopyalanır.
	_health_fill = (_health_bar.get_theme_stylebox("fill") as StyleBoxFlat).duplicate()
	_health_bar.add_theme_stylebox_override("fill", _health_fill)
	_reload_bar.hide()
	Game.locale_changed.connect(_on_locale_changed)


func bind(player: Player) -> void:
	player.health.health_changed.connect(_on_health_changed)
	_on_health_changed(player.health.current, player.health.maximum)
	_weapon = player.weapon
	_weapon.ammo_changed.connect(_on_ammo_changed)
	_on_ammo_changed(_weapon.get_ammo(), _weapon.get_magazine_size())


func set_wave(wave: int) -> void:
	_wave = wave
	_wave_label.text = tr("HUD_WAVE") % wave


func _process(_delta: float) -> void:
	if _weapon == null:
		return
	var reloading: bool = _weapon.is_reloading()
	_reload_bar.visible = reloading
	if reloading:
		_reload_bar.value = _weapon.get_reload_progress()


func _on_health_changed(current: float, maximum: float) -> void:
	_health_bar.max_value = maximum
	_health_bar.value = current
	_health_label.text = "%d / %d" % [ceili(current), roundi(maximum)]
	var low: bool = maximum > 0.0 and current / maximum < LOW_HEALTH_RATIO
	_health_fill.bg_color = LOW_HEALTH_COLOR if low else HEALTH_COLOR


func _on_ammo_changed(current: int, magazine: int) -> void:
	_ammo_label.text = "%d / %d" % [current, magazine]


func _on_locale_changed(_locale: String) -> void:
	set_wave(_wave)
