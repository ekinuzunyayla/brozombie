# BroZombie — Oyun Tasarım Dokümanı

> Bu doküman projenin referans kaynağıdır. Mekanikle ilgili bir işe başlamadan önce okunmalı, tasarım kararları değiştikçe güncellenmelidir.
> Çalışma adı: **BroZombie** (kesin isim 🔒 belirlenecek)
> Geliştirme aşamaları ve görevler: `docs/ROADMAP.md`

---

## 1. Özet

Üstten bakışlı (top-down 2D), kapalı haritalarda geçen bir **zombi dalga savunma roguelite** oyunu.

Oyuncu bir mekânda (ev, çiftlik, benzin istasyonu vb.) mahsur kalır. Mekânın dışına çıkamaz, açık dünya yoktur. Zombiler dalgalar halinde gelir ve her dalga bir öncekinden güçlüdür. Oyuncu yalnızca hareket eder, silahlar **otomatik nişan alıp ateş eder**. Öldürülen zombilerden **XP, para ve materyal** düşer:

- **XP** → seviye atlayınca rastgele **özellik kartları** arasından seçim (karakter build'i)
- **Para** → silah satın alma
- **Materyal** → evi geliştirme: barikat, tuzak, taret, yeni oda açma

Oyuncu ölünce run sıfırdan başlar. Her run farklı kart kombinasyonları ve farklı ev geliştirmeleriyle farklı bir deneyimdir.

**Platform:** PC (Steam) ve mobil (iOS/Android) aynı anda geliştirilir. Yatay ekran. Oyun içi diller Türkçe ve İngilizce. Tek oyunculu.

### İlham kaynakları (sadece tasarım düzeyinde)
| Oyun | Alınan fikir |
|---|---|
| Call of Duty Zombies | Kapalı harita, kapı/oda açarak alanı genişletme, duvar silahları, gizemli sandık, artan dalgalar |
| Brotato | Dalga yapısı, otomatik nişan, stat odaklı build, level up'ta kart seçimi, görsel stil |
| Thronefall | Önceden belirlenmiş inşa noktaları, yanına yürüyüp inşa etme, yükseltme yolları |
| Don't Starve / 7 Days to Die / Zomboid | Hayatta kalma atmosferi, üssü güçlendirme |

### Tasarım ilkeleri
1. **İçerik değil sistem üret.** Yeni silah, kart, zombi veya yapı eklemek kod değil, veri dosyası (`.tres`) eklemek olmalı.
2. **Her aşama oynanabilir olmalı.** Bir özellik eklenmeden önce mevcut sürümün eğlenceli olup olmadığı test edilir.
3. **Solo geliştirici kapsamı.** Açık dünya, açlık/susuzluk ve karmaşık crafting ağacı yok. Haritalar küçük ve elle yapılır.
4. **Dokunmatikte de rahat oynanmalı.** Hiçbir mekanik hassas nişan, hover veya çoklu dokunma gerektirmez.

---

## 2. Temel Oyun Döngüsü

```
DALGA      → Zombiler gelir. Silahlar otomatik ateş eder. Öldürdükçe XP + para + materyal düşer.
LEVEL UP   → (Dalga içinde veya sonunda) 3 rastgele karttan 1'i seçilir.
MOLA (~30sn)
           → İnşa noktalarına yürü: barikat, tuzak, taret kur, kapı/oda aç.
           → Parayla silah al (duvar silahları / gizemli sandık).
           → Hasarlı barikatları tamir et.
SONRAKİ DALGA → Daha fazla, daha güçlü zombi.
```

### Run hedefi
- **20. dalgayı** geçen oyuncu run'ı kazanır (sayı veride tutulur).
- Kazanınca oyuncu isterse **sonsuz moda** devam eder. Sonsuz modda skor ve ulaşılan dalga kaydedilir.

### Tempo
Gündüz/gece fazı yoktur. Tempo şunlarla sağlanır:
- Dalga arası **hazırlık molası** (gerilim → rahatlama)
- Birkaç dalgada bir **özel dalgalar**: boss, sis (görüş azalır), elektrik kesintisi (taretler çalışmaz), koşucu sürüsü

---

## 3. Oyun Sistemleri

### 3.1 Oyuncu
- Üstten bakış. Oyuncu yalnızca **hareket eder** (klavye, gamepad sol analog veya dokunmatik sanal joystick).
- **Nişan otomatiktir.** Her silah menzilindeki bir hedefe kendisi ateş eder. Hedefleme kuralı silah verisinde tutulur (en yakın, en düşük can, en çok zombi vb.).
- Statlar: can, hareket hızı, hasar, atış hızı, menzil, şarjör, şarj süresi, kritik şansı, toplama menzili, zırh
- Tüm statlar **Stat + Modifier** sistemiyle hesaplanır (bkz. 6. Mimari)

### 3.2 Silahlar
- 🔒 **Silah slotu sayısı henüz belli değil.** İki seçenek değerlendiriliyor:
  - *Çok silah, hepsi aynı anda ateş eder* (Brotato gibi 4-6 slot): build derinliği yüksek olur
  - *Az silah (2-3)*: her silah seçimi daha anlamlı olur
- Slot sayısı veride tutulur (`max_weapon_slots`). v0.1 tek silahla başlar. Karar v0.4'ten önce verilir.
- Edinme yolları: duvar silahları (sabit fiyat, sabit yer) ve gizemli sandık (rastgele silah, pahalı)
- Örnek başlangıç seti: Tabanca, Pompalı, Tüfek, SMG, Beyzbol sopası (yakın dövüş, otomatik savurma)

### 3.3 Zombiler
| Tip | Özellik |
|---|---|
| Yürüyen | Yavaş, standart, kalabalık |
| Koşucu | Hızlı, düşük can |
| Tank | Yavaş, çok yüksek can, barikatlara ekstra hasar |
| (Sonra) Patlayan, Tükürücü, Çığlıkçı | Çeşitlilik için sonraki sürümlerde |
| Boss | Her 5. dalgada |

- Zombiler en yakın hedefe gider: oyuncu veya yol üstündeki barikat
- Barikatlar zombileri durdurur, zombiler onları kırmaya çalışır
- Dalga ölçeklemesi: zombi sayısı, canı ve hızı dalga numarasına göre artar (formüller veri dosyasında tutulur)
- Zombi tipleri silüet ve renkle, uzaktan ve küçük ekranda da ayırt edilebilmeli

### 3.4 Düşenler (Drop)
- **XP**: her zombiden
- **Para**: her zombiden, küçük miktar
- **Materyaller**: şansa bağlı
  - Hurda → barikat ve tuzak
  - Tahta → barikat ve tamir
  - Elektronik → taret ve elektrikli yapılar (nadir)
- Drop'lar yerde kalır, oyuncu toplama menzili içindekileri otomatik toplar
- Dalga bitince yerde kalan drop'lar oyuncuya çekilir (mobilde toplamak için koşturma olmasın)

### 3.5 Özellik Kartları (Build)
- Level up'ta 3 rastgele kart sunulur, oyuncu 1'ini seçer
- Kartlar stat modifier'ları veya özel efektler ekler
- Bazı kartlar **takas** içerir (ör. "+%30 hasar, -%15 hareket hızı")
- Nadirlik: Sıradan / Nadir / Efsanevi
- Örnekler:
  - *Kalın Deri*: +20 max can
  - *Hızlı Eller*: -%20 şarj süresi
  - *Hurdacı*: materyal düşme şansı +%25
  - *Usta Marangoz*: barikatlar %30 daha dayanıklı
  - *Adrenalin*: canın %30'un altındayken +%40 atış hızı

### 3.6 Ev Geliştirme (İnşa Noktaları)
Oyuncu her yere serbestçe inşa edemez. Haritada önceden belirlenmiş **inşa noktaları** (BuildSpot) vardır.

**Etkileşim (Thronefall tarzı):**
1. Oyuncu bir noktanın yanına yürür.
2. Noktanın üstünde maliyet balonu belirir (hangi materyalden ne kadar gerektiği).
3. Oyuncu etkileşim girdisini **basılı tutar** (klavye/gamepad tuşu ya da ekrandaki büyük buton). Dolum halkası dolunca yapı kurulur veya yükseltilir.
4. Hasarlı yapının yanında aynı etkileşim **tamir** yapar.

Menü veya kamera değişimi yoktur, oyuncu dalga sırasında da inşa edebilir (risk onun).

| Nokta tipi | Yükseltme yolu |
|---|---|
| Pencere / Kapı | Tahta barikat → Metal barikat → Elektrikli barikat |
| Tuzak noktası | Dikenli tel / Ayı kapanı / Mayın |
| Taret noktası | Basit taret → Gelişmiş taret (elektronik gerekir) |
| Kilitli kapı | Açılınca yeni oda |

- Tüm noktalar aynı `BuildSpot` sahnesini kullanır. Davranışını içindeki veri belirler.
- Bir noktada birden fazla seçenek varsa (ör. tuzak tipi), seçim noktanın yanında beliren büyük butonlarla yapılır.

### 3.7 Oda Açma
- Kilitli kapılar materyal veya parayla açılır (inşa noktasıyla aynı etkileşim)
- Yeni oda yeni inşa noktaları, duvar silahları veya oda bonusu getirir
  - *Mutfak*: dalga sonunda can yenileme
  - *Garaj*: tezgâh, barikat yükseltmeleri ucuzlar
  - *Çatı*: menzil bonusu olan atış noktası
- **Risk/ödül**: Açılan her oda savunulması gereken alanı büyütür (yeni zombi giriş noktaları açılabilir)

### 3.8 Haritalar
- Her harita elle yapılmış, kapalı ve küçük bir mekândır
- İlk sürümde **1 harita**: müstakil ev + bahçe
- Sonraki haritalar: çiftlik evi, benzin istasyonu, hastane, karakol
- Her haritanın kendi zombi giriş noktaları, inşa noktaları ve kilitli odaları vardır
- Kamera oyuncuyu takip eder. Telefon ekranında da haritanın yeterli kısmı görünmeli

### 3.9 Meta İlerleme (sonraki sürümler)
- Run'lar arasında kalıcı açılımlar: yeni karakterler, kart havuzuna yeni kartlar, yeni haritalar
- Run içi güç kalıcı değildir, yalnızca çeşitlilik açılır

---

## 4. Platform ve Kontroller

| Girdi | Hareket | Etkileşim (inşa/tamir/satın al) | Kart seçimi / menü |
|---|---|---|---|
| Klavye + fare | WASD / ok tuşları | `E` basılı tut | Fare tıklaması veya klavye |
| Gamepad | Sol analog | `A` basılı tut | D-pad + `A` |
| Dokunmatik | Sanal joystick (ekranın sol yarısında, dokunulan yerde belirir) | Sağ alttaki büyük buton, basılı tut | Dokunma |

- Nişan otomatik olduğu için ikinci bir joystick yoktur.
- Hover'a bağlı hiçbir bilgi yoktur. Kart ve yapı açıklamaları her zaman görünür ya da dokunarak açılır.
- Uygulama arka plana geçince oyun otomatik duraklar.
- Dokunma alanları en az ~120 px (1080p referansında).

---

## 5. Para Kazanma

| Platform | Model |
|---|---|
| PC (Steam) | Premium, tek seferlik satın alma. Reklam ve IAP yok |
| Mobil | F2P + ödüllü reklam + IAP |

Mobil fikirler (🔒 detaylar kesinleşmedi):
- Ödüllü reklam: ölünce bir kez diriliş, kart seçiminde ekstra yenileme, dalga sonu materyal bonusu
- IAP: reklamları kaldırma / "tam sürüm" paketi, kozmetik karakter görünümleri
- Run içi güç satın alınmaz (pay-to-win yok)

Teknik kural: reklam, satın alma, başarımlar ve bulut kaydı `Monetization`/`Platform` arayüzlerinin arkasında durur. PC'de bu arayüzlerin boş (no-op) uygulaması kullanılır.

---

## 6. Teknik Mimari

### 6.1 Teknoloji
- **Motor:** Godot 4.7
- **Dil:** GDScript (statik tipler kullanılır)
- **Renderer:** Mobile
- **Görünüm:** 2D top-down, vektör/çizim stili (kalın kontur, düz renkler)
- **Harita:** `TileMapLayer` + navigasyon. Kalabalık zombi için paylaşılan akış alanı (flow field) düşünülür

### 6.2 Klasör Yapısı
Güncel hedef yapı `CLAUDE.md` içindedir.

### 6.3 Temel Prensipler
1. **Veri odaklı tasarım:** Silah, zombi, kart, inşa edilebilir yapı ve dalga ayarları `Resource` sınıflarıyla tanımlanır. Yeni içerik = yeni `.tres` dosyası.
2. **Stat + Modifier sistemi:** Statlar taban değer ve modifier listesinden hesaplanır (düz ekleme ve yüzde çarpan). Kartlar ve yükseltmeler yalnızca modifier ekler, kodu değiştirmez.
3. **Component yapısı:** Can, hasar verme/alma ve hareket ayrı component'lerdir. Oyuncu, zombi, barikat ve taret aynı `HealthComponent`'i kullanır.
4. **EventBus:** Sistemler birbirini doğrudan çağırmaz, sinyal yayınlar (`zombie_died`, `wave_started`, `wave_ended`, `player_leveled_up`, `resource_changed`, `room_unlocked` ...).
5. **Performans:** Mobil öncelikli. Zombi, mermi ve drop için object pooling. Zombi AI'ı basit tutulur.

### 6.4 Örnek Veri Sınıfları (taslak)
```gdscript
# scripts/resources/zombie_data.gd
class_name ZombieData extends Resource
@export var id: StringName
@export var name_key: String  # çeviri anahtarı, ör. "ZOMBIE_WALKER_NAME"
@export var max_health: float = 20.0
@export var speed: float = 60.0
@export var damage: float = 10.0
@export var barricade_damage_mult: float = 1.0
@export var xp_value: int = 1
@export var money_value: int = 5
@export var drop_table: Array[DropEntry] = []
@export var scene: PackedScene
```

```gdscript
# scripts/resources/card_data.gd
class_name CardData extends Resource
enum Rarity { COMMON, RARE, LEGENDARY }
@export var id: StringName
@export var title_key: String
@export var description_key: String
@export var rarity: Rarity = Rarity.COMMON
@export var icon: Texture2D
@export var modifiers: Array[StatModifier] = []
```

---

## 7. Referans Materyaller ve Kurallar

Yerel diskte şu klasörler bulunur:
- `/Users/ekin/Downloads/Brotato`: Godot 3, dekompile edilmiş ticari oyun
- `/Users/ekin/Downloads/Thronefall`: Unity/C#, dekompile edilmiş ticari oyun

**Kurallar:**
- Bu klasörlerdeki **kod, görsel, ses, metin ve veri dosyaları projeye kopyalanmaz** ve uyarlanarak da aktarılmaz. Telif hakkıyla korunan içeriklerdir.
- Yalnızca **genel mimari fikirleri anlamak** için okunabilir. Uygulama bu projede sıfırdan, Godot 4 için yazılır.
- Görseller kendi üretimimizdir ya da lisansı uygun paketlerden gelir. Lisanslar `assets/LICENSES.md` dosyasında tutulur.

---

## 8. Açık Sorular

- [ ] Oyunun kesin adı 🔒
- [ ] Silah slotu sayısı ve yakın dövüşün rolü 🔒 (v0.4'ten önce)
- [ ] Mobil monetizasyon detayları 🔒 (ödüllü reklam noktaları, IAP paketleri)
- [ ] Hedef en düşük mobil cihaz ve ekrandaki azami zombi sayısı bütçesi 🔒
- [x] Görsel stil: 2D vektör/çizim (Brotato gibi)
- [x] Godot sürümü: 4.7
- [x] Run hedefi: 20 dalga ile kazanma + sonsuz mod
- [x] Tek oyunculu, co-op yok (ileride gelirse büyük refactor gerekeceği kabul edildi)
- [x] Nişan: otomatik
- [x] İnşa etkileşimi: yanına yürü + basılı tut
- [x] Platform: PC + mobil aynı anda. Dil: TR + EN
