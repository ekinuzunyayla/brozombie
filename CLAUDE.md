# BroZombie

Godot 4.7 ile üstten bakışlı (2D) zombi dalga savunma roguelite. Dil: GDScript.
Ticari oyun: PC/Mac (Steam) ve iOS/Android aynı anda geliştirilir. Yatay ekran, tek oyunculu. Oyun içi diller Türkçe + İngilizce.
İlham: Brotato (otomatik nişan, kart build'i), CoD Zombies (kapalı harita, oda açma, duvar silahı), Thronefall (inşa noktaları).
Kullanıcıyla Türkçe konuş. Kod, dosya ve sınıf adları İngilizce.

- Tasarım kararları, mekanikler, kontroller, para kazanma modeli: `docs/GDD.md`. Mekanikle ilgili bir işe başlamadan önce oku. Yeni bir karar verildiğinde güncelle.
- Kilometre taşları ve "bitti" kriterleri: `docs/ROADMAP.md`. Her oturumun başında aktif kilometre taşını oradan öğren. Biten görevin kutucuğunu işaretle.
- Godot'ya özgü işlerde (sahne, script, resource, shader, project settings) önce `AGENTS.md` ve `addons/fennara/ai/guidelines.md` dosyalarını oku. Fennara MCP araçları bu projede kullanılabilir.

## Doğrulama komutları

`godot` PATH'te yok. Binary: `/Users/ekin/Downloads/Godot.app/Contents/MacOS/Godot` (4.7.2). Aşağıda `$GODOT` diye geçiyor.
macOS'ta `timeout` komutu yok, onun yerine `--quit-after` kullan.

- Projeyi içe aktar ve tüm scriptleri parse et: `$GODOT --headless --path . --import`
- Testleri çalıştır (GUT, `tests/` altındaki `test_*.gd`): `$GODOT --headless --path . -s res://addons/gut/gut_cmdln.gd`. Başarısız test olursa exit code 1 döner. Tek dosya için sonuna `-gtest=res://tests/unit/test_x.gd` ekle.
- Tek script kontrolü: `$GODOT --headless --path . --check-only --script res://path/to/file.gd`
- Sahneyi kısa süre çalıştır: `$GODOT --headless --path . res://scenes/maps/house.tscn --quit-after 300`
- Ekran görüntüsü al (headless olmadan): `$GODOT --path . --write-movie <scratchpad>/f.png --quit-after 5`. Son kareyi oku.
- Godot editörü açıksa Fennara MCP araçlarını tercih et: script diagnostics, `screenshot_scene`, oyun içi davranış için `runtime_session`/`runtime_script`.
- Export: `$GODOT --headless --path . --export-debug "Android" build/android/BroZombie.apk`. Preset adları: `Android`, `iOS`, `macOS`, `Windows`. `build/` içinde `.gdignore` olmalı, yoksa Godot build çıktılarını tarar ve import dakikalarca sürer.
- Kullanıcının Godot editörü projede açıkken `--import` takılabilir. Editör açıksa import'u editöre bırak, testler ve sahne çalıştırma etkilenmez.
- `--import` bazen editör açık değilken de işini bitirdikten sonra kapanmıyor. Çıktıda `loading_editor_layout` için `DONE` görüldüyse import bitmiştir, süreci öldürmek güvenlidir.
- Script hatası olsa bile Godot exit code 0 dönebilir. Çıktıda `SCRIPT ERROR`, `Parse Error` ve `ERROR:` ara.
- Bir işi "bitti" saymadan önce en az import/parse kontrolünü çalıştır ve çıktısını göster.
- Editör kapalıyken sahne veya project settings değişikliği: scratchpad'de `extends SceneTree` bir script yazıp `$GODOT --headless --path . -s <script>` ile çalıştır. Sahneyi `PackedScene.pack` + `ResourceSaver.save`, ayarları `ProjectSettings.set_setting` + `save()` ile Godot kaydetsin. Autoload'lar `_init` sırasında henüz yüklü değildir, işi ilk `_process` karesinde yap. Input map'teki klavye olaylarına `device = -1` ver.
- Dokunmatik kontrolleri masaüstünde görmek için proje köküne geçici bir `override.cfg` koy (`[input_devices]` altında `pointing/emulate_touch_from_mouse=true`). İş bitince sil.
- (v0.5'ten itibaren) Denge simülasyonu: `$GODOT --headless --path . -s res://tools/balance_sim.gd -- --runs=300`. Değişiklik öncesi ve sonrası aynı seed'lerle karşılaştır.

## Mimari ilkeler

- **Mantık ve görünüm ayrı.** `scripts/core/` saf oyun mantığıdır (`RefCounted`/`Resource`): `RunState`, Stat + Modifier, dalga planlama, ekonomi, kart havuzu, drop tabloları. Sahneye ve UI'a bağlı olmaz, headless testle çalışır. Gerçek zamanlı varlık davranışı (hareket, çarpışma, ateş) Node'larda kalır, ama statları ve kuralları core'dan okur. UI yalnızca durumu gösterir ve girdiyi iletir, core durumunu doğrudan değiştirmez.
- **İçerik veri olarak yazılır.** Silahlar, zombiler, kartlar, inşa edilebilir yapılar, dalga ayarları ve haritalar `data/` altındaki `.tres` Resource dosyalarıdır. Yeni içerik için kod değil veri gerekmeli. Özel davranışlar küçük, yeniden kullanılabilir sınıflara gider (ör. hedefleme kuralı, kart efekti).
- **Kartlar ve yükseltmeler sadece modifier ekler.** Stat değeri her zaman taban + modifier listesinden hesaplanır. Hiçbir sistem stat'ı doğrudan değiştirmez.
- **Component yapısı.** `HealthComponent`, `HitboxComponent`, `HurtboxComponent` ve `StatsComponent` oyuncu, zombi, barikat ve taret tarafından ortak kullanılır.
- **Sistemler sinyalle konuşur.** Sistemler birbirini doğrudan çağırmaz, `EventBus` üzerinden sinyal yayınlar. Autoload'ları az tut: `Game` (ayarlar, dil, platform), `EventBus` ve run durumu. Oyun mantığını autoload'a yığma.
- **Rastgelelik tek kaynaktan gelir.** Run başına bir tane seed'li `RandomNumberGenerator` kullan. `randi()` ve `randf()` global fonksiyonlarını kullanma.
- **Kaydedilebilir durum.** `RunState` ve `Profile` düz veriye çevrilebilir olmalı (`to_dict()`/`from_dict()`). Node referansı veya sinyal bağlantısı taşımaz. Run, dalga arası molada kaydedilir. Uygulama arka plana geçince oyun duraklar.
- **Mobil performans öncelikli.** Zombi, mermi, drop ve hasar yazısı için object pooling kullan. Her zombiye ayrı `NavigationAgent2D` verme. Paylaşılan akış alanı (flow field) ya da sınırlı yol bulma kullan. `_process` içinde node arama ve fizik sorgusu yapma. Performans bütçesi ROADMAP'te 🔒.
- **Platform kodu arayüz arkasında.** Reklam, satın alma, başarımlar ve bulut kaydı `Monetization`/`Platform` arayüzlerinden geçer. Core bunları doğrudan çağırmaz. Editörde mock uygulama, PC'de no-op uygulama kullanılır.
- **Güncel kapsam:** `docs/ROADMAP.md`'deki aktif kilometre taşı. Onun dışındaki işi istenmeden yapma. 🔒 işaretli karar kapılarında kod yazmadan önce kullanıcıya sor.

## Giriş ve kontroller

- Nişan otomatiktir. Oyuncu yalnızca hareket eder ve etkileşir. Fare veya sağ analogla nişan alma kodu yazma.
- Hareket tek bir `MoveInput` soyutlamasından okunur. Klavye, gamepad ve dokunmatik sanal joystick aynı `Vector2`'yi üretir. Oyuncu kodu girdi kaynağını bilmez.
- İnşa, tamir, satın alma ve kapı açma tek bir `interact` eylemiyle yapılır: oyuncu noktanın yanına gelir, etkileşimi basılı tutar. Dokunmatikte bunun için ekranda büyük bir buton olur.
- Dokunmatik joystick Godot 4.7'nin yerleşik `VirtualJoystick` node'udur ve `move_*` eylemlerine doğrudan güç yazar (`scenes/ui/touch_controls.tscn`). `VirtualJoystick` adında kendi sınıfını tanımlama, yerleşik sınıfla çakışır.
- Dokunmatikte joystick ve etkileşim butonu aynı anda kullanılır (iki parmak). Bu yüzden `TouchActionButton` (`scripts/input/touch_action_button.gd`) dokunmaları `InputEventScreenTouch` index'iyle izler. Bu iki kontrol dışındaki UI tek dokunuşla çalışır ve yalnızca fare olaylarını (`emulate_mouse_from_touch`) dinler.
- UI testleri: GUT'un kendi paneli 128. katmanda girdiyi yakalar. Test edilen node'u `layer = 200` olan bir `CanvasLayer` içine koy (`tests/unit/test_touch_controls.gd`).
- Hover'a bağlı özellik olmaz. Dokunma alanı en az ~120 px (1080p'de). Tam ekran UI kökleri `SafeArea` içine konur.
- Tüm menüler gamepad ile de gezilebilir olmalı (focus komşuları ayarlanır).

## Tema ↔ mekanik sözlüğü

Kodda soldaki terimi kullan, oyuncuya sağdakini göster.

| Kod | Oyunda | Not |
|---|---|---|
| `wave` | Dalga | Run 20. dalgada kazanılır, sonra sonsuz mod |
| `break_phase` | Mola | Dalga arası hazırlık süresi |
| `build_spot` | İnşa Noktası | Haritada önceden yerleştirilmiş |
| `buildable` | Yapı | Barikat, tuzak, taret tanımları |
| `barricade` | Barikat | Tahta → Metal → Elektrikli |
| `scrap` / `wood` / `electronics` | Hurda / Tahta / Elektronik | Materyaller |
| `money` | Para | Silah satın alma |
| `card` | Özellik Kartı | Seviye atlayınca 3'ten 1 |
| `wall_weapon` | Duvar Silahı | Sabit yer, sabit fiyat |
| `mystery_box` | Gizemli Sandık | Rastgele silah |
| `locked_door` / `room` | Kilitli Kapı / Oda | |

## GDScript kuralları

- Her yerde statik tip kullan: `var hp: int`, `func deal(amount: int) -> void`. Diziler `Array[CardData]` gibi tipli olsun.
- Paylaşılan tipleri `class_name` ile tanımla.
- Sinyal adları geçmiş zamanda olsun: `zombie_died`, `wave_started`, `hp_changed`.
- Node referansları için `@onready var x: Type = %UniqueName` kullan. Uzun `$A/B/C` yollarından kaçın.
- Oyuncunun gördüğü hiçbir metin koda veya `.tres` içine gömülmez. Her metin çeviri anahtarıyla yazılır (`tr("CARD_THICK_SKIN_NAME")`). Çeviriler `localization/` altındaki CSV dosyalarında, `tr` ve `en` sütunlarıyla durur.
- Girinti tab ile (Godot varsayılanı). Dosya adları `snake_case`, sınıf adları `PascalCase`.

## Klasör yapısı (hedef)

```
data/          .tres içerikleri: weapons/, zombies/, cards/, buildables/, waves/, maps/
scripts/core/  saf oyun mantığı (run state, stats, waves, economy, cards)
scripts/resources/   veri sınıfları (WeaponData, ZombieData, CardData, BuildableData, StatModifier ...)
scripts/components/  HealthComponent, HitboxComponent, HurtboxComponent, StatsComponent
scripts/systems/     sahneye bağlı yöneticiler (WaveSpawner, DropManager, BuildManager, pooling)
scripts/input/       MoveInput, sanal joystick
scripts/platform/    Monetization, Platform arayüzleri ve mock'ları
scripts/ui/          görünüm scriptleri
scripts/autoload/    Game, EventBus
scenes/        player/, zombies/, weapons/, projectiles/, buildables/, pickups/, ui/, maps/
tests/unit/    GUT testleri (test_*.gd)
tools/         denge simülasyonu gibi geliştirici araçları
assets/        art/, shaders/, vfx/, audio/, fonts/, LICENSES.md
localization/  çeviri CSV'leri
docs/          GDD.md, ROADMAP.md
```

## Görsel yön

- 2D vektör/çizim stili (Brotato'ya yakın): düz renkler, kalın koyu kontur, abartılı silüetler. Okunabilirlik önce gelir: zombi tipleri, mermiler, drop'lar ve inşa noktaları telefon ekranında bir bakışta ayırt edilmeli.
- "Canlılık" sistemden gelir: yürürken squash/stretch ve sallanma (tween ya da shader), hasarda beyaz flash ve geri itme, ölümde parçalanma partikülü, drop'ta zıplama. Varlığa özel fark parametrelerdir ve bunlar `.tres` içinde durur. Shader'lar `assets/shaders/` altında, `canvas_item` tipindedir.
- Görsel henüz yoksa placeholder (`Polygon2D`, `ColorRect`, `Label`) kullan. Mantık asla görsele bağlı olmamalı.
- Renderer `mobile`. Shader'larda bu renderer'da çalışmayan özelliklere dikkat et. Partikül sayısını mobil için sınırlı tut.
- Her harici asset'in kaynağı ve lisansı `assets/LICENSES.md` dosyasına yazılır.

## Referans: Brotato ve Thronefall decompile

- `/Users/ekin/Downloads/Brotato/` (`$BROTATO`): Godot 3 projesi. Kod `Source_Code/`, asset'ler `Game_Assets/` altında.
- `/Users/ekin/Downloads/Thronefall/` (`$THRONEFALL`): Unity/C#. Kod `Source_Code/Assembly-CSharp/`, asset'ler `Game_Assets/` altında.

Kod ve asset'lerin hepsi sahiplerine aittir. **Sadece incelemek için.** Çalıştırma, projeye kopyalama, kod/asset/metin/isim taşıma. Kavramı anla, kendi tasarımımızla Godot 4 için sıfırdan yaz. Hiçbir asset `res://` altına girmez, placeholder olarak da kullanılmaz.

Brotato Godot 3 söz dizimindedir (`KinematicBody2D`, `yield`, `onready`, `export`, `setget`). Godot 4'te geçerli değildir, oradan satır uyarlama.

Bakılacak yerler (içerikleri okunarak doğrulandı). Brotato yolları `$BROTATO/Source_Code/`, Thronefall yolları `$THRONEFALL/Source_Code/Assembly-CSharp/` altındadır.

**Brotato: stat ve build**
- Stat hesabı: `singletons/run_data.gd` (`get_stat`, `get_stat_gain`, `add_stat`, `get_armor_coef`). Statlar efekt sözlüğünde düz toplamla tutulur, `gain_*` yüzdesiyle çarpılır.
- Stat önbelleği: `singletons/utils.gd` (`get_stat`, `reset_stat_cache`). Nihai değer = kalıcı + geçici (`singletons/temp_stats.gd`) + bağlı (`singletons/linked_stats.gd`). `linked_stats.gd` stat sisteminin kendisi değildir, "her X için +Y" türü stat'ları hesaplar.
- Modifier/efekt verisi: `items/global/effect.gd` (`key`, `value`, `storage_method`).
- Oyuncunun run verisi ve kaydı: `singletons/player_run_data.gd` (`serialize`/`deserialize`).
- Level-up kart seçimi: `singletons/item_service.gd` (`get_upgrades`, `get_upgrade_data`, `get_tier_from_wave`). Tekrar önleme ve belirli seviyelerde nadirlik zorlama burada. Kart verisi: `items/upgrades/upgrade_data.gd`.

**Brotato: dalga ve spawn**
- Dalga zamanlaması ve grup tekrarı: `zones/wave_manager.gd`
- Veri: `zones/zone_data.gd`, `zones/wave_data.gd`, `zones/wave_group_data.gd` (spawn zamanı, tekrar aralığı, min/max dalga), `zones/wave_unit_data.gd`
- Sonsuz mod ölçeklemesi: `singletons/zone_service.gd` (`get_wave_data`, `get_additional_groups`)
- Spawn ve object pooling: `global/entity_spawner.gd`, `main.gd` (`get_node_from_pool`, `add_node_to_pool`)

**Brotato: otomatik nişan, düşman, yapı, drop**
- Otomatik nişan: `weapons/weapon.gd` (`get_direction_and_calculate_target`, `should_shoot`, `_on_Range_body_entered`). Menzil alanına giren hedefler listede tutulur, en yakın olana ateş edilir.
- Ateş davranışları: `weapons/shooting_behaviors/` (ranged/melee), silah statları: `weapons/weapon_stats/`
- Düşman hareketi: `entities/units/movement_behaviors/` (ör. `follow_target_movement_behavior.gd`), saldırı: `entities/units/enemies/attack_behaviors/`. `enemy_data.gd` yalnızca kimlik ve sahne tutar.
- Taret: `entities/structures/structure.gd`, `entities/structures/turret/turret.gd`
- Drop: `main.gd` (`spawn_loot`, `spawn_gold`, `spawn_consumables`, `on_gold_picked_up`), materyal: `items/materials/gold.gd`, toplama menzili: `entities/units/player/item_attract_area.gd`

**Thronefall: inşa ve etkileşim**
- İnşa noktası, yükseltme seviyeleri ve dallanma: `BuildSlot.cs` (`Upgrade`/`UpgradeBranch` sınıfları, `TryToBuildOrUpgradeAndPay`, `ExecuteUpgrade`). Bir noktanın açılması başka bir noktanın seviyesine bağlanabilir (`activatorBuilding`).
- Basılı tutarak ödeme: `BuildingInteractor.cs` (`InteractionBegin/Hold/End`) ve `CostDisplay.cs` (`FillUp`, `Deny`, `CancelFill`). Basılı tutuldukça para tek tek yuvalara dolar, bırakılınca iade edilir.
- En yakın etkileşim noktasını seçme ve para mıknatısı: `PlayerInteraction.cs` (`FetchInteractors`, `FetchCoins`, `RunInteraction`)
- Seçim ekranı (yükseltme dalı seçimi): `ChoiceManager.cs`, `Choice.cs`

**Thronefall: savunma ve düşman**
- Hedef önceliği (etiket filtresi + menzil): `TargetPriority.cs`, `AutoAttack.cs` (`FindAutoAttackTarget`), taret: `AutoAttackTower.cs`
- Düşmanın hedef seçimi (oyuncu, bina veya yuvaya dönüş): `PathfindMovementEnemy.cs` (`FindMoveToTarget`)
- Can, hasar, yıkılan binaların geri gelmesi: `Hp.cs` (`TakeDamage`, `Heal`, `Revive`)
- Dalga ve spawn verisi: `Wave.cs`, `Spawn.cs`, `EnemySpawner.cs` (dalga akışı, spawn noktası işaretleri). Sonsuz mod: `EndlessModeWaveGen.cs`

Dosyalar binlerce tane. `find`/`grep` ile hedefli ara, klasörleri toplu listeleme.

## Dokunma

- `.godot/`: editörün cache'i, elle düzenleme.
- `addons/fennara/`: Fennara MCP altyapısı ve `_fennara_game_capture` autoload'u. Kullanıcı açıkça istemedikçe değiştirme, kaldırma.
- `addons/godotty/`: editör içi terminal eklentisi, oyunla ilgisi yok.
- `project.godot`: mümkünse editör ya da Fennara `project_settings` üzerinden değişsin. Elle düzenlemen gerekirse (ör. `run/main_scene`, autoload, input map) yalnızca ilgili satırı değiştir.
- `.tscn`/`.tres`/`.res` dosyalarını düz metin olarak elle düzenleme. Godot'nun kendisi serileştirsin (Fennara `run_scene_edit_script` veya editör).
- `*.uid` ve `*.import` dosyalarını Godot üretir. Yeni script veya asset eklendiğinde import komutunu çalıştır, kendin yazma.
