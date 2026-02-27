# 🎮 Game Development Tutorial
**Nama:** Malvin Scafi  
**NPM:** 2306152430  
**Kelas:** Game Development
---

## 📌 Riwayat Tutorial
| **Tutorial** | **Tautan**                   |
|--------------|------------------------------|
| Tutorial 3   | [Lihat Tutorial 3](#📘-Tutorial-3) |

---

## 📘 Tutorial 3

## Latihan: Mandiri

Berikut adalah fitur-fitur lanjutan yang telah ditambahkan:
1. **Double Jump**
2. **Dashing**
3. **Crouching**
4. **Sistem Respawn (Jika Karakter Keluar Peta)**
5. **Sistem State Animasi**

---

### Proses Pengerjaan dan Implementasi

#### 1. Double Jump
* Konsep: Pemain dapat melompat sekali lagi ketika sedang berada di udara.
* Implementasi: Menggunakan variabel `max_jumps = 2` dan `jump_count`. Setiap kali karakter menyentuh lantai (`is_on_floor()`), nilai `jump_count` akan reset menjadi 0. Ketika pemain menekan tombol lompat (`ui_up`), sistem akan cek apakah karakter ada di lantai dan `jump_count` masih di bawah `max_jumps`. Jika syarat terpenuhi, `velocity.y` diatur ke `jump_speed` (memberikan gaya ke atas) dan `jump_count` bertambah 1.

#### 2. Dashing
* Konsep: Pemain dapat berlari lebih cepat secara sementara dengan mengetuk (double tap) tombol arrow kiri atau kanan dengan cepat dan hanya bisa dilakukan saat karakter berada di lantai.
* Implementasi:
  * Deteksi Double Press: Terdapat variabel `time_since_last_tap` yang terus bertambah berdasarkan `delta`. Saat pemain menekan arrow, fungsi `_check_dash(dir)` dipanggil. Jika arrow yang ditekan sama dengan *Press* sebelumnya dan jeda waktunya di bawah `double_tap_time` (0.25 detik), maka status `is_dashing` menjadi `true`.
  * Efek Kecepatan: Saat `is_dashing` aktif, kecepatan karakter (`current_speed`) yang tadinya `walk_speed` (200) diubah menjadi `dash_speed` (450) selama durasi `dash_timer` (0.2 detik).

#### 3. Crouching dengan Deteksi Atap
* Konsep: Karakter dapat berjongkok untuk melewati celah sempit, kecepatannya melambat, dan *hitbox* karakternya mengecil. Pemain juga tidak akan berdiri jika masih berada di dalam tunnel yang sempit, meskipun tombol jongkok sudah dilepaskan.
* Implementasi:
  * Perubahan Hitbox: Terdapat dua buah node `CollisionShape2D` (satu untuk berdiri, satu untuk jongkok). Properti `disabled` pada kedua node ini diaktifkan dan dinonaktifkan secara bergantian berdasarkan status `is_crouching`.
  * Sensor Atap (RayCast2D): Menambahkan dua node `RayCast2D` (`CeilingCheckLeft` dan `CeilingCheckRight`) di bahu karakter yang menghadap ke atas. Jika salah satu sensor mendeteksi benturan (`is_colliding()`), skrip akan mengabaikan input pemain dan memaksa status `is_crouching = true` hingga karakter benar-benar keluar dari bawah objek solid.

#### 4. Sistem Respawn
* Konsep: Jika karakter terjatuh keluar dari batas peta, maka akan otomatis dikembalikan ke posisi awal.
* Implementasi:
  Pada fungsi `_ready()`, posisi awal karakter disimpan ke dalam variabel `spawn_position`. Di dalam `_physics_process`, sistem terus memantau `global_position.y`. Jika nilainya melebihi `fall_limit` (675.0), maka fungsi `_respawn()` dipanggil untuk mengembalikan `global_position` ke posisi awal dan mereset momentum `velocity` menjadi nol.

#### 5. Sistem Animasi
* Konsep: Mengubah animasi secara otomatis berdasarkan *state* atau aksi yang sedang dilakukan pemain menggunakan `AnimatedSprite2D`.
* Implementasi:
  Fungsi `_update_animation()` dipanggil setiap *frame*. Animasi diprioritaskan dari aksi yang paling spesifik:
  1. Memutar sprite ke kiri/kanan berdasarkan `velocity.x` (`flip_h`).
  2. Mengecek status udara (membedakan animasi "jump" jika `velocity.y < 0` dan "fall" jika `velocity.y > 0`).
  3. Memutar animasi "crouch", "dash", "walk", atau "idle" tergantung dari bendera status (*state flags*) yang sedang aktif.