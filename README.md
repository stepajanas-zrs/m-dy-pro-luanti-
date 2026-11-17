# Spears Mod pro Luanti (Minetest Game & Mineclonia)

Rozšíření do hry **Luanti** (dříve Minetest), které do světa přidává vrhací i kontaktní oštěpy. Mód je navržen jako čistý, otevřený Lua skript bez jakýchkoliv externích závislostí nebo spustitelných souborů.

🌐 **Oficiální stahovací stránka:** [Odkaz na váš web na Vercelu](https://modsforyou.vercel.app)

---

## 📦 Dostupné edice

Mód je dostupný ve dvou samostatných variantách podle toho, jakou hru v klientovi Luanti hrajete:

1. **Edice pro Minetest Game (`spears-mtg.zip`)**
   * Využívá standardní suroviny ze základní hry (dřevo, kámen, ocel, bronz, mese, diamant).
   * Plně kompatibilní s klasikou Minetest Game a jejími odvozeninami.
2. **Edice pro Mineclonia (`spears-mineclonia.zip`)**
   * Přizpůsobeno pro herní mechaniky, suroviny a recepty hry Mineclonia (železo, zlato, diamant, netherit).

---

## ⚔️ Hlavní funkce

* **Boj zblízka s delším dosahem:** Oštěpy umožňují zasáhnout nepřátele na větší vzdálenost než běžný meč.
* **Vrhání na dálku:** Oštěp lze hodit po cíli a po dopadu jej opět sebrat ze země.
* **100% Open-Source:** Veškerý zdrojový kód je veřejně čitelný přímo v tomto repozitáři.

---

## 🛠️ Jak mód nainstalovat

1. Stáhněte si příslušný `.zip` balíček z [webu projektu](https://modsforyou.vercel.app) (nebo ze složky `mods/` v tomto repozitáři).
2. Rozbalte stažený archiv. Uvnitř najdete složku pojmenovanou **`spears`**.
3. Zkopírujte složku `spears` do adresáře `mods` ve vaší instalaci hry Luanti:
   * **Windows:** `C:\Cesta_k_Luanti\mods\`
   * **Linux:** `~/.minetest/mods/` nebo `~/.var/app/net.minetest.Minetest/.minetest/mods/`
4. Spusťte hru Luanti, vyberte svůj svět, klikněte na **Nastavit (Configure)** a mód `spears` povolte.

---

## 📁 Struktura tohoto repozitáře

```text
├── index.html                  # Zdrojový kód webové stránky pro Vercel
├── README.md                   # Tento popis projektu
└── mods/
    ├── spears-mtg.zip          # Balíček pro Minetest Game
    └── spears-mineclonia.zip   # Balíček pro Mineclonia
```

---

## 📄 Licence

Tento projekt je šířen jako svobodný open-source software pod licencí **MIT**. Kód můžete volně kontrolovat, upravovat a sdílet.
