extends Control
## Geliştirme sahnesi: dilin, girdinin (klavye, gamepad, dokunmatik) ve güvenli alanın
## cihazda çalıştığını gösterir.

@onready var _title_label: Label = %TitleLabel
@onready var _info_label: Label = %InfoLabel
@onready var _input_label: Label = %InputLabel
@onready var _language_button: Button = %LanguageButton


func _ready() -> void:
	Game.locale_changed.connect(_on_locale_changed)
	_language_button.pressed.connect(Game.cycle_locale)
	get_viewport().size_changed.connect(_refresh_info)
	_refresh_info()


func _process(_delta: float) -> void:
	var move: Vector2 = MoveInput.get_vector()
	_input_label.text = "%s\n%s" % [
		tr("PLATFORM_CHECK_MOVE") % ("(%.2f, %.2f)" % [move.x, move.y]),
		tr("PLATFORM_CHECK_INTERACT") % _state_text(Input.is_action_pressed(&"interact")),
	]


func _on_locale_changed(_locale: String) -> void:
	_refresh_info()


func _refresh_info() -> void:
	_title_label.text = tr("PLATFORM_CHECK_TITLE")
	_language_button.text = tr("BUTTON_SWITCH_LANGUAGE") % tr("LANGUAGE_NAME")
	_info_label.text = "%s (%s)\n%s: %s\n%s: %s\n%s: %s\n%s" % [
		OS.get_name(), OS.get_model_name(),
		tr("INFO_WINDOW"), DisplayServer.window_get_size(),
		tr("INFO_VIEWPORT"), Vector2i(get_viewport_rect().size),
		tr("INFO_SAFE_AREA"), DisplayServer.get_display_safe_area(),
		tr("PLATFORM_CHECK_TOUCHSCREEN") % _state_text(DisplayServer.is_touchscreen_available()),
	]


func _state_text(on: bool) -> String:
	return tr("STATE_ON") if on else tr("STATE_OFF")
