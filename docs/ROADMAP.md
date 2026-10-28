# BroZombie — Yol Haritası

> **Aktif kilometre taşı: v0.0 Kurulum**
>
> Her aşamanın sonunda oyun oynanabilir olmalıdır. Aktif aşamanın dışındaki işi istenmeden yapma. Biten görevin kutucuğunu işaretle. 🔒 işaretli maddelerde kod yazmadan önce kullanıcıya sor.
> İlk sürümlerde görseller placeholder olabilir (`Polygon2D`, `ColorRect`, `Label`).

---

## v0.0 Kurulum
- [x] `git init`, `.gitignore` kontrolü
- [x] GUT eklentisini `addons/gut/` altına kur, `tests/unit/` altında örnek bir test geçsin
- [x] Klasör iskeleti (`CLAUDE.md` > Klasör yapısı)
- [x] `localization/strings.csv` (`keys,tr,en`) + project settings'te çeviri kaydı, varsayılan dil
- [x] Input map: `move_left/right/up/down`, `interact`, `pause` (klavye + gamepad)
- [x] Sanal joystick (Godot 4.7 yerleşik `VirtualJoystick`) + etkileşim butonu (yalnızca dokunmatik cihazda görünür)
- [x] `MoveInput` soyutlaması: klavye, gamepad ve joystick aynı vektörü üretir
- [x] `Monetization` ve `Platform` arayüzleri + mock/no-op uygulamaları
- [x] Yatay ekran, `SafeArea`, pencere boyutu/stretch ayarları
- [x] `build/.gdignore`, export preset'leri (`Android`, `iOS`, `macOS`, `Windows`)
- [ ] Android cihazda `scenes/ui/platform_check.tscn` testi: joystick hareket vektörü üretiyor, joystick ve butona aynı anda basılabiliyor

**Bitti:** Boş bir sahne PC'de ve bir Android cihazda açılıyor, joystick hareket vektörü üretiyor, testler geçiyor.

## v0.1 Savunma çekirdeği
- [ ] Stat + Modifier sistemi (`scripts/core/`) + testleri
- [ ] Oyuncu hareketi, kamera takibi
- [ ] Otomatik nişanlı 1 silah (tabanca), mermi pooling
- [ ] 2 zombi tipi (yürüyen, koşucu) `.tres` olarak
- [ ] Zombi hareketi (navigasyon / akış alanı)
- [ ] 1 harita: ev + bahçe, zombi giriş noktaları
- [ ] Sonsuz dalga, veriden ölçekleme
- [ ] HUD: can, dalga, mermi
- [ ] Ölüm → yeniden başlat
- [ ] 🔒 Hedef cihaz ve zombi sayısı bütçesi (performans testi öncesi)

**Test edilen soru:** Savunma eğlenceli mi?

## v0.2 Build
- [ ] Drop sistemi: XP, para, 1 materyal. Toplama menzili, dalga sonunda çekim
- [ ] Seviye atlama + 3 karttan 1'i seçme ekranı
- [ ] 10 kart (`data/cards/`)

**Test edilen soru:** Build kurmak keyifli mi?

## v0.3 Ev geliştirme
- [ ] `BuildSpot` sahnesi + veri (yanına yürü, maliyet balonu, basılı tut)
- [ ] Barikat (tahta → metal → elektrikli), zombilerin barikata saldırması
- [ ] 1 tuzak
- [ ] Tamir
- [ ] Dalga arası mola fazı

**Test edilen soru:** Ev geliştirme anlamlı mı?

## v0.4 Alan genişletme
- [ ] 🔒 Silah slotu sayısı kararı
- [ ] Kilitli kapı / oda açma, oda bonusu
- [ ] Duvar silahları, 3-4 silah
- [ ] Run hedefi: 20. dalgada kazanma ekranı + sonsuz moda devam

**Test edilen soru:** Alan genişletmenin riski/ödülü çalışıyor mu?

## v0.5 Çeşitlilik
- [ ] Tank zombi, boss dalgası
- [ ] Özel dalgalar (sis, elektrik kesintisi, koşucu sürüsü)
- [ ] Taret
- [ ] Gizemli sandık
- [ ] Denge simülasyonu aracı (`tools/balance_sim.gd`)

**Test edilen soru:** Çeşitlilik yeterli mi?

## v0.6+ Tekrar oynanabilirlik ve yayın
- [ ] 2. harita
- [ ] Meta ilerleme, `Profile` kaydı
- [ ] Run kaydı (mola fazında) ve devam etme
- [ ] Ana menü, ayarlar, dil seçimi
- [ ] Ses ve görsel cilalama
- [ ] 🔒 Mobil monetizasyon detayları + gerçek reklam/IAP entegrasyonu
- [ ] 🔒 Oyunun kesin adı

**Test edilen soru:** Oyuncu bir run daha oynamak istiyor mu?
