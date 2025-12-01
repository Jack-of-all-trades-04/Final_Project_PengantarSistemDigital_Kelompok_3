# Final Project Pengantar Sistem Digital Kelompok 3
Anggota :
- Arya Wibawa Atmanegara (2406420431)
- Ganendra Garda Pratama (2306250642)
- Novan Agung Wicaksono (2406401294)
- Zulfahmi Fajri (2406345425)

# "Simulasi Cryptocurrency 67-bit"

## Ringkasan
Proyek ini adalah simulasi blockchain + cryptocurrency sederhana yang dirancang untuk pengimplementasian FPGA/VHDL. Sistem ini menggunakan:
* **Header Blok 67-bit**
* **Hash 64-bit kustom** (Yang telah disederhanakan agar mudah dibuat)
* **3-bit Linear Linking** (Untuk referensi blok sebelumnya)
* **Proof-of-Work mining** menggunakan pencarian **nonce**
* **Dua miner (Wallet A & Wallet B)** yang bersaing membuat blok baru
* **Reward 1 coin** untuk setiap blok baru yang berhasil ditambang
Tujuan proyek ini adalah mempelajari cara kerja dasar cryptocurrency: mining, linking, validasi blok, konsensus, dan manajemen saldo dalam bentuk yang sederhana yang bisa diterapkan pada FPGA atau simulator VHDL.
---

# 1. Arsitektur Sistem

## 1.1 Komponen

### **1. Wallet A & Wallet B**
Setiap wallet memiliki:
* `public_key` (8-bit atau sesuai kebutuhan)
* `balance` (jumlah coin)
### **2. Modul Miner**
* Melakukan perhitungan hash
* Meningkatkan nilai nonce setiap siklus
* Mengecek apakah hash memenuhi target
* Miner yang menemukan hash valid pertama menjadi pemenang
### **3. Penyimpanan Blockchain**
* Menyimpan rantai blok (maksimal 8 blok karena 3-bit index)
* Setiap blok disimpan dalam memori RAM atau array VHDL
### **4. Modul Konsensus**
* Menentukan miner pemenang
* Menambahkan blok baru ke blockchain
* Mengupdate saldo wallet pemenang
---

# 2. Format Header Blok (67-bit)
```
[ 3-bit prev_index ][ 8-bit miner_id ][ 24-bit timestamp ][ 16-bit nonce ][ 16-bit hash_fragment ]
```
Total = 67 bit.
### Penjelasan setiap field:
* **prev_index (3-bit)**: indeks blok sebelumnya
* **miner_id (8-bit)**: ID miner yang membuat blok
* **timestamp (24-bit)**: counter waktu atau siklus clock
* **nonce (16-bit)**: meningkat setiap siklus untuk mencari hash valid
* **hash_fragment (16-bit)**: bagian bawah hash 64-bit (untuk verifikasi)
---

# 3. Proses Proof-of-Work (Mining)
### Algoritma Mining:

```
nonce = 0
ulang:
    block_data = semua field kecuali hash_fragment
    hash64 = HASH(block_data)
    jika hash64 < TARGET:
        blok valid → pemenang!
    nonce = nonce + 1
```
### Contoh Target Sederhana:

```
Hash harus dimulai dengan 6 bit nol.
< 0b000000xxxxxxxx........
```
---

# 4. Tingkat Kesulitan (Difficulty)
Difficulty akan dibuat mudah karena untuk hanya simulasi:
* Hash memiliki 6–8 bit nol di bagian atas
* Atau hash mod 32 = 0
---

# 5. Aturan Validasi Blok
Sebuah blok dianggap valid jika:
1. `prev_index` cocok dengan block head saat ini
2. Hash memenuhi target
3. Nonce adalah nilai yang menghasilkan hash valid
4. `miner_id` sesuai dengan wallet yang menang
Ketika miner menang:
* Blok dimasukkan ke dalam memori blockchain
* Saldo wallet pemenang bertambah **1 coin**
* Pointer "block head" pindah ke blok baru
---

# 6. Struktur File VHDL
Berikut adalah struktur file proyek yang akan dibuat dan dipakai:
### `hash64.vhd`
* Mengimplementasikan fungsi hash 64-bit sederhana
* Menggunakan operasi XOR, rotasi, penjumlahan, dsb.
### `miner.vhd`
* Mengatur iterasi nonce
* Menghitung hash
* Mengecek validitas hash
* Mengirim sinyal *block-found*
### `wallet.vhd`
* Menyimpan saldo
* Menyimpan ID miner
### `block_header.vhd`
* Mendefinisikan format header blok 67-bit
### `blockchain_storage.vhd`
* Memori berisi maksimal 8 blok
* Menyimpan header blok dan pointer
### `consensus_controller.vhd`
* Menentukan miner pemenang
* Mengupdate blockchain
### `top.vhd`
* Menghubungkan seluruh modul
* Mengatur clock/reset
### `tb_top.vhd`
* Testbench untuk simulasi mining
---

# 7. Alur Mining Contoh Untuk Testbench
1. Kedua miner membaca header blok sebelumnya
2. Kedua miner memulai nonce dari 0
3. Mereka menghitung:
```
HASH(prev_header || miner_id || timestamp || nonce)
```
4. Miner pertama yang mendapatkan hash valid langsung menang
5. Blok baru dibentuk
6. Saldo wallet pemenang naik menjadi +1
7. Blockchain menambahkan blok baru ke rantai
---

# 8. Tujuan Proyek
* Memahami logika blockchain pada level hardware
* Memahami Proof-of-Work di level bit
* Memahami bagaimana miner bersaing
* Belajar merancang sistem digital kompleks dalam VHDL
---

# Fitur Tambahan (Opsional)
* Menambahkan transaksi
* Menambahkan Merkle root
* Difficulty yang dinamis
* Menambah jumlah miner
* Menambah ukuran blockchain
* Hash pipelined
---
