extends GutTest

const STRINGS_PATH: String = "res://localization/strings.csv"
const TEST_SETTINGS_PATH: String = "user://test_settings.cfg"

var _original_settings_path: String
var _original_locale: String


func before_each() -> void:
	_original_settings_path = Game.settings_path
	_original_locale = Game.get_locale()
	Game.settings_path = TEST_SETTINGS_PATH


func after_each() -> void:
	Game.set_locale(_original_locale, false)
	Game.settings_path = _original_settings_path
	DirAccess.remove_absolute(TEST_SETTINGS_PATH)


func test_every_key_has_all_languages() -> void:
	var file := FileAccess.open(STRINGS_PATH, FileAccess.READ)
	var header: PackedStringArray = file.get_csv_line()
	for locale in Game.SUPPORTED_LOCALES:
		assert_has(header, locale, "CSV'de '%s' sütunu yok" % locale)
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() <= 1 and row[0].is_empty():
			continue
		for column in range(1, header.size()):
			assert_false(row[column].strip_edges().is_empty(), "%s için '%s' boş" % [row[0], header[column]])


func test_switching_locale_changes_text() -> void:
	Game.set_locale("tr")
	assert_eq(tr("LANGUAGE_NAME"), "Türkçe")
	Game.set_locale("en")
	assert_eq(tr("LANGUAGE_NAME"), "English")


func test_unsupported_locale_falls_back_to_default() -> void:
	Game.set_locale("de")
	assert_eq(Game.get_locale(), Game.DEFAULT_LOCALE)


func test_locale_is_saved() -> void:
	Game.set_locale("tr")
	var config := ConfigFile.new()
	assert_eq(config.load(TEST_SETTINGS_PATH), OK)
	assert_eq(config.get_value("general", "locale"), "tr")


func test_cycle_locale_visits_all_languages() -> void:
	Game.set_locale("tr", false)
	Game.cycle_locale()
	assert_eq(Game.get_locale(), "en")
	Game.cycle_locale()
	assert_eq(Game.get_locale(), "tr")
