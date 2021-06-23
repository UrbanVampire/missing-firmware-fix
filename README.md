# Automatic "Possible missing firmware" warning fix.
## English readme.
[:arrow_down:Русская инструкция](#### Инструкция на русском ниже.)

So, you're faced the "Possible Missing Firmware" message when generating a kernel on your Linux system during `apt updgrade` or `update-initramfs`. This is a fairly common problem and this script is the solution. It detects all missing firmware, downloads and installs them.

The usage is very simple: just download the script:
```
wget https://raw.githubusercontent.com/UrbanVampire/missing-firmware-fix/main/missing-firmware-fix.sh
```
make it executable:
```
chmod +x missing-firmware-fix.sh
```
and run as sudo:
```
sudo ./missing-firmware-fix.sh
```
In case of errors You can use the **'--debug'** option to get some extended error info:
`sudo ./missing-firmware-fix.sh --debug`

Tested on Debian 9, Debian 10, Ubuntu 18.04, Ubuntu 20.04, Linux Mint 20.01.

# Автоматическое исправление предупреждений "Possible missing firmware".
## Русская инструкция
[:arrow_up:Русская инструкция](#### English readme is above.)

Итак, вы получили сообщение "Possible Missing Firmware" при генерации ядра во время обновления системы или при вызове `update-initramfs`. Проблема нередкая, но решение есть. Этот скрипт определяет все недостающие прошивки, скачивает их и устанавливает.

Использовать скрипт очень просто. Качаете:
```
wget https://raw.githubusercontent.com/UrbanVampire/missing-firmware-fix/main/missing-firmware-fix.sh
```
делаете исполняемым:
```
chmod +x missing-firmware-fix.sh
```
и запускаете с правами sudo:
```
sudo ./missing-firmware-fix.sh
```
Если что-то пошло не так, можно запустить скрипт с ключом **'--debug'** для получения расширенной информации об ошибках:
`sudo ./missing-firmware-fix.sh --debug`

Скрипт тестировался на Debian 9, Debian 10, Ubuntu 18.04, Ubuntu 20.04, Linux Mint 20.01.
