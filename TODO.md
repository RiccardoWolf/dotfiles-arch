# TODO

## TODO for Tools and Integrations

- [ ] Add OCR tool install and config: aggiungere installazione, dipendenze e configurazione dello strumento OCR usato nel setup.
- [ ] Add syncthing automated config: automatizzare la configurazione iniziale di Syncthing, inclusi file di configurazione e comportamento atteso dopo l'installazione.
- [ ] Add higher quality icons for nwg-bar and rofi: sostituire o aggiungere icone di qualita migliore per `nwg-bar` e `rofi`, verificando i path usati dalle rispettive configurazioni.
- [x] Add printer setup (cups+avahi+IPP): aggiungere setup stampanti con `cups`, `avahi` e supporto IPP, includendo servizi da abilitare e pacchetti necessari.
- [x] Add setup for colorpicker: aggiungere installazione e configurazione del color picker, includendo eventuali bind o integrazione con Hyprland.
- [x] Add setup openvpn + waybar widget: aggiungere installazione/configurazione OpenVPN e un widget Waybar per mostrare stato o controllo VPN. (https://openvpn.net/community-docs/openvpn-client-for-linux.html)
- [ ] Add fonts config: aggiungere configurazione font, pacchetti richiesti.
- [ ] Add mime types: aggiungere gestione MIME types per associare applicazioni predefinite ai formati usati nel desktop.

## TODO for System

- [ ] Definire le task di sistema mancanti: questa sezione era presente nel contenuto originale ma senza task specifiche.

## TODO for README

- [ ] Add hyprpm+hypr plugins: documentare installazione, aggiornamento e uso di `hyprpm` e dei plugin Hyprland usati dalla configurazione.
- [ ] Refactor all: riorganizzare completamente il README per renderlo piu chiaro, mantenendo istruzioni, prerequisiti e flusso di installazione.
- [ ] Documentare workaround Electron quando `scaling != 1`: spiegare quando applicare la configurazione XWayland seguente per le app Electron.

```conf
xwayland {
    force_zero_scaling = true
}
```

## TODO package list

- [ ] Snipping tool (`hyprshot`): aggiungere `hyprshot` alla lista pacchetti e verificare eventuale configurazione o bind.
- [ ] Color picker (`hyprpicker`): aggiungere `hyprpicker` alla lista pacchetti e collegarlo al setup colorpicker.
- [ ] Mail client (`thunderbird`): aggiungere Thunderbird come client mail.
- [ ] Clipboard manager (`nwg-clipman`): aggiungere `nwg-clipman` e verificare integrazione con Wayland/Hyprland.
- [ ] Text OCR (`normcap`): aggiungere `normcap` come strumento OCR testuale con pacchetto lingua inglese sempre, italiano optional
- [ ] `brightnessctl`: aggiungere gestione luminosita tramite `brightnessctl`.
- [ ] `syncthing`: aggiungere Syncthing alla lista pacchetti e collegarlo alla task di configurazione automatica.
- [ ] `remmina`: aggiungere Remmina per connessioni remote.
- [ ] `obsidian`: aggiungere Obsidian alla lista pacchetti e config automatica da definire
- [ ] aggiungere GIMP o alternative alla lista pacchetti opzionali

## Theme management

### Waybar

- [ ] Waybar - invert file name: invertire o rinominare i file tema Waybar secondo la convenzione desiderata.
- [ ] Waybar - `reload_style_on_change`: valutare e configurare l'opzione per ricaricare automaticamente lo stile CSS quando cambia il file o un CSS importato.
- [ ] Waybar - mantenere riferimento opzione originale:

```text
reload_style_on_change
typeof: bool
default: false
Option to enable reloading the css style if a modification is detected on the style sheet file or any imported css files.
```

### Applicazioni GTK/XDG

la gestione del tema dovrebbe solo avere uno dark e uno light, solo per i pacchetti descritti sotto

- [ ] `code`: aggiungere gestione tema per Visual Studio Code.
- [ ] `chrome`: aggiungere gestione tema per Chrome.
- [ ] `blueman`: aggiungere gestione tema per Blueman.
- [ ] `thunar`: aggiungere gestione tema per Thunar.
- [ ] `obsidian`: aggiungere gestione tema per Obsidian.
- [ ] `libre`: aggiungere gestione tema per LibreOffice.
- [ ] `discord`: aggiungere gestione tema per Discord.
- [ ] `spotify(change pkg)`: gestire tema Spotify e valutare cambio pacchetto come indicato nel contenuto originale.
- [ ] `gtk xdg`: aggiungere gestione tema GTK e impostazioni XDG collegate.

### Rofi

- [ ] `rofi`: aggiungere gestione tema Rofi.
- [ ] `awk config.rasi line`: modificare la linea corretta di `config.rasi` con `awk` o altra logica robusta per cambiare tema.

### Kitty

- [ ] `kitty`: aggiungere gestione tema Kitty.

### Zsh

- [ ] `cambiare thema zsh`: aggiungere cambio tema Zsh alla gestione temi.

### Nvim

- [ ] `nvim`: aggiungere gestione tema Neovim.
- [ ] `awk change theme`: modificare il tema Neovim con `awk` o altra logica robusta.

### Dunst

- [ ] `dusnt`: aggiungere gestione tema Dunst, mantenendo attenzione al nome originale scritto come `dusnt`.
- [ ] `same as waybar`: applicare a Dunst una logica simile a Waybar per aggiornamento o cambio tema.
