# Moje módy pro Luanti (Minetest Game & Mineclonia)

Kolekce otevřených (open-source) Lua módů pro hru **Luanti** (dříve Minetest). Všechny módy jsou čisté textové skripty a textury bez jakýchkoliv spustitelných souborů, reklam nebo externích instalerů.

🌐 **Oficiální stahovací web:** [https://modsforyou.vercel.app](https://modsforyou.vercel.app)

---

## 📦 Přehled dostupných módů

Každý mód je dostupný ve dvou samostatných edicích podle toho, jakou hru v klientovi Luanti hrajete:

### 1. Spears Mod (Oštěpy)
Rozšiřuje bojový systém o vrhací a kontaktní oštěpy s delším dosahem než běžný meč.
* **Minetest Game:** `mods/spears-mtg.zip` (využívá standardní suroviny ze základní hry)
* **Mineclonia:** `mods/spears-mineclonia.zip` (přizpůsobeno pro herní mechaniky a suroviny Mineclonie)

### 2. More Totems
Přidává do světa nové druhy totemů s unikátními ochrannými a podpůrnými schopnostmi.
* **Minetest Game:** `mods/more-totems-mtg.zip`
* **Mineclonia:** `mods/more-totems-mineclonia.zip`

### 3. Mód @a
Praktické rozšíření pro příkazy v chatu a správu světa, které umožňuje cílit příkazy na všechny hráče najednou pomocí selektoru `@a`.
* **Minetest Game:** `mods/at-a-mtg.zip`
* **Mineclonia:** `mods/at-a-mineclonia.zip`

---

## 🛠️ Jak módy nainstalovat

1. Stáhněte si požadovaný `.zip` balíček z [webové stránky projektu](https://modsforyou.vercel.app) nebo přímo ze složky `mods/` výše.
2. Rozbalte stažený archiv. Uvnitř najdete složku s technickým názvem módu (např. `spears` nebo `more_totems`).
3. Zkopírujte rozbalenou složku do adresáře `mods` ve vaší instalaci hry Luanti:
   * **Windows:** `C:\Cesta_k_Luanti\mods\`
   * **Linux:** `~/.minetest/mods/` nebo `~/.var/app/net.minetest.Minetest/.minetest/mods/`
4. Spusťte Luanti, vyberte svůj svět, klikněte na **Nastavit (Configure)** a stažený mód povolte.

---

## 📁 Struktura repozitáře

```text
├── index.html                        # Zdrojový kód webové stránky pro Vercel
├── README.md                         # Dokumentace projektu
└── mods/
    ├── spears-mtg.zip                # Spears (Minetest Game)
    ├── spears-mineclonia.zip         # Spears (Mineclonia)
    ├── more-totems-mtg.zip           # More Totems (Minetest Game)
    ├── more-totems-mineclonia.zip    # More Totems (Mineclonia)
    ├── at-a-mtg.zip                  # Mód @a (Minetest Game)
    └── at-a-mineclonia.zip           # Mód @a (Mineclonia)
```

---

## 📄 Licence

Všechny módy v tomto repozitáři jsou šířeny pod svobodnou licencí **MIT**. Zdrojový kód si může kdokoliv volně zkontrolovat, upravit i sdílet.
