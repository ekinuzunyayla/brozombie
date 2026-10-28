extends GutTest


func test_base_monetization_never_rewards() -> void:
	var monetization := Monetization.new()
	watch_signals(monetization)
	assert_false(monetization.is_rewarded_ad_ready(&"revive"))
	monetization.show_rewarded_ad(&"revive")
	await wait_process_frames(2)
	assert_signal_emitted_with_parameters(monetization, "rewarded_ad_finished", [&"revive", false])


func test_base_monetization_purchase_fails() -> void:
	var monetization := Monetization.new()
	watch_signals(monetization)
	monetization.purchase(&"remove_ads")
	await wait_process_frames(2)
	assert_signal_emitted_with_parameters(monetization, "purchase_finished", [&"remove_ads", false])
	assert_false(monetization.is_owned(&"remove_ads"))


func test_mock_ad_rewards() -> void:
	var monetization := MockMonetization.new()
	watch_signals(monetization)
	assert_true(monetization.is_rewarded_ad_ready(&"revive"))
	monetization.show_rewarded_ad(&"revive")
	await wait_process_frames(2)
	assert_signal_emitted_with_parameters(monetization, "rewarded_ad_finished", [&"revive", true])


func test_mock_purchase_is_owned() -> void:
	var monetization := MockMonetization.new()
	monetization.purchase(&"remove_ads")
	assert_true(monetization.is_owned(&"remove_ads"))


func test_mock_purchase_failure() -> void:
	var monetization := MockMonetization.new()
	monetization.purchases_succeed = false
	monetization.purchase(&"remove_ads")
	assert_false(monetization.is_owned(&"remove_ads"))


func test_mock_platform_tracks_achievements() -> void:
	var platform := MockPlatform.new()
	assert_false(platform.is_achievement_unlocked(&"first_wave"))
	platform.unlock_achievement(&"first_wave")
	assert_true(platform.is_achievement_unlocked(&"first_wave"))


func test_debug_build_uses_mocks() -> void:
	assert_true(Game.monetization is MockMonetization)
	assert_true(Game.platform is MockPlatform)
