# TODO

## TODO for Tools and Integrations

- [ ] Add OCR tool install and config: aggiungere installazione, dipendenze e configurazione dello strumento OCR usato nel setup.
- [ ] Add syncthing automated config: automatizzare la configurazione iniziale di Syncthing, inclusi file di configurazione e comportamento atteso dopo l'installazione.
- [ ] Add Obsidian automated config: definire quali impostazioni/plugin vanno installati e come applicarli senza sovrascrivere vault o dati utente.
- [ ] Add higher quality icons for nwg-bar and rofi: sostituire o aggiungere icone di qualita migliore per `nwg-bar` e `rofi`, verificando i path usati dalle rispettive configurazioni.
- [x] Add printer setup (cups+avahi+IPP): aggiungere setup stampanti con `cups`, `avahi` e supporto IPP, includendo servizi da abilitare e pacchetti necessari.
- [x] Add setup for colorpicker: aggiungere installazione e configurazione del color picker, includendo eventuali bind o integrazione con Hyprland.
- [x] Add setup openvpn + waybar widget: aggiungere installazione/configurazione OpenVPN e un widget Waybar per mostrare stato o controllo VPN. (https://openvpn.net/community-docs/openvpn-client-for-linux.html)
- [ ] Add fonts config: aggiungere configurazione font, pacchetti richiesti.
- [x] Add mime types: aggiungere gestione MIME types per associare applicazioni predefinite ai formati usati nel desktop.

## TODO for System

- [ ] Definire le task di sistema mancanti: questa sezione era presente nel contenuto originale ma senza task specifiche.

## TODO for README

- [ ] Add hyprpm+hypr plugins: documentare installazione, aggiornamento e uso di `hyprpm` e dei plugin Hyprland usati dalla configurazione.
- [ ] Refactor all: riorganizzare completamente il README per renderlo piu chiaro, mantenendo istruzioni, prerequisiti e flusso di installazione.
- [x] Documentare usage base installer e workflow tema corrente nel README.
- [ ] Documentare workaround Electron quando `scaling != 1`: spiegare quando applicare la configurazione XWayland seguente per le app Electron.

```conf
xwayland {
    force_zero_scaling = true
}
```

## TODO package list

- [x] Snipping tool (`hyprshot`): aggiungere `hyprshot` alla lista pacchetti e verificare eventuale configurazione o bind.
- [x] Color picker (`hyprpicker`): aggiungere `hyprpicker` alla lista pacchetti e collegarlo al setup colorpicker.
- [x] Mail client (`thunderbird`): aggiungere Thunderbird come client mail.
- [x] Clipboard manager (`nwg-clipman`): aggiungere `nwg-clipman` e verificare integrazione con Wayland/Hyprland.
- [x] Text OCR (`normcap`): aggiungere `normcap` come strumento OCR testuale; resta da verificare lingua inglese sempre, italiano optional.
- [x] `brightnessctl`: aggiungere gestione luminosita tramite `brightnessctl`.
- [x] `syncthing`: aggiungere Syncthing alla lista pacchetti; config automatica resta nella task Tools.
- [x] `remmina`: aggiungere Remmina per connessioni remote.
- [x] `obsidian`: aggiungere Obsidian alla lista pacchetti; config automatica resta da definire.
- [x] aggiungere GIMP o alternative alla lista pacchetti opzionali.

## Theme management

la gestione del tema dovrebbe solo avere uno dark e uno light, solo per i pacchetti descritti sotto

Revisione corrente: `theme-switch apply <dark|light>` e `theme-switch toggle` aggiornano tutti i target supportati: link runtime, GTK/XDG, VS Code, Chrome live, Zsh, Codex e Spicetify se configurato.

### Waybar

- [x] Waybar - legacy file cleanup: rimuovere o marcare come legacy `style-light.css`; `style.css` ora importa `dotfiles-arch/themes/current/waybar.css`.
- [x] Waybar - widget tema: mostrare stato dark/light e togglare con click tramite `theme-widget.sh`, aggiornando tutti i target supportati nella stessa invocazione.
- [x] Waybar - `reload_style_on_change`: valutare e configurare l'opzione per ricaricare automaticamente lo stile CSS quando cambia il file o un CSS importato.
- [x] Waybar - mantenere riferimento opzione originale:

```text
reload_style_on_change
typeof: bool
default: false
Option to enable reloading the css style if a modification is detected on the style sheet file or any imported css files.
```

### Applicazioni GTK/XDG

- [x] `code`: aggiungere gestione tema per Visual Studio Code.
- [x] `chrome`: aggiungere gestione tema per Chrome.
- [x] `blueman`: aggiungere gestione tema per Blueman tramite GTK/XDG.
- [x] `thunar`: aggiungere gestione tema per Thunar.
- [ ] `obsidian`: aggiungere gestione tema per Obsidian.
- [ ] `libre`: aggiungere gestione tema per LibreOffice.
- [ ] `discord`: aggiungere gestione tema per Discord.
- [ ] `spotify(change pkg)`: gestire tema Spotify e valutare cambio pacchetto come indicato nel contenuto originale; `theme-switch` supporta Spicetify solo se configurato via env.
- [x] `gtk xdg`: aggiungere gestione tema GTK e impostazioni XDG collegate.

### Rofi

- [x] `rofi`: aggiungere gestione tema Rofi.
- [x] `awk config.rasi line`: non serve piu; `config.rasi` punta a `dotfiles-arch/themes/current/rofi.rasi`.
- [x] Sistemare path icone Rofi: le theme file referenziano icone locali agli asset tema (`search.svg` in dark/light).

### Kitty

- [x] `kitty`: aggiungere gestione tema Kitty.

### Zsh

- [x] `cambiare thema zsh`: aggiungere cambio tema Zsh alla gestione temi.

### Dunst

- [x] `dusnt`: aggiungere gestione tema Dunst, mantenendo attenzione al nome originale scritto come `dusnt`.
- [x] `same as waybar`: rendere coerente anche lo startup Dunst; `theme-switch apply` crea il link runtime a `themes/current/dunst.conf`.

### Theme workflow cleanup

- [x] Default install: `install.sh` include `theme` prima di `rofi-wayland` e `waybar`, cosi `theme-switch prepare/apply` crea `themes/current` prima delle config che lo importano.
- [x] Semplificare `theme-switch apply`: un singolo comando aggiorna core link/reload e adapter app (`code`, Chrome live, zsh, Codex, Spicetify).
- [x] Aggiungere backup coerenti per i writer diretti senza rompere i target symlinkati.
- [x] Sistemare palette light: Rofi, Waybar e nwg-bar light hanno asset espliciti e meno scuri.
- [x] Hyprland shortcut: `SUPER+SHIFT+T` toggla dark/light tramite `theme-switch toggle`.
- [x] `runs/theme.sh`: evitare di stoware tutto `home/bin`; installare solo `theme-switch` e lasciare launcher Chrome/Thunar a `runs/xdg.sh`.
- [x] Rimuovere legacy non usati: `kitty-light.conf`, `waybar/style-light.css`, `nwg-bar/style-light.css`, wrapper Rofi `spotlight-blurred*`, wrapper `dark.sh`/`light.sh`, e `home/.config/dunst/dunstrc`.
- [x] Rendere il runtime indipendente dal checkout del repo copiando gli asset tema in `~/.local/state/dotfiles-arch/themes`.
- [x] Verificare asset non referenziati e pesanti, per esempio `home/.config/hypr/old.png`: `old.png` e tracciato, pesa circa 2.4M e non ha riferimenti nel repo; lasciato in place per evitare rimozioni implicite.
