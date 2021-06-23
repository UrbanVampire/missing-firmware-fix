# missing-firmware-fix
Русская инструкция ниже.

### English readme

So, you're faced the "Possible Missing Firmware" message during kernel generation on your Linux system. This is a fairly common problem and this script is the solution.

The usage is very simple: just download the script, make it executable and run as sudo:
```
wget https://raw.githubusercontent.com/UrbanVampire/missing-firmware-fix/main/missing-firmware-fix.sh
chmod +x missing-firmware-fix.sh
sudo ./missing-firmware-fix.sh
```
In case of errors You can use the **'--debug'** option to get some extended error info:
`sudo ./missing-firmware-fix.sh --debug`

Tested on Debian 9, Debian 10, Ubuntu 18.04, Ubuntu 20.04, Linux Mint 20.01.

### Русская инструкция

Итак, вы получили сообщение "Possible Missing Firmware" при генерации ядра. Проблема нередкая, но решение есть.

Использовать скрипт очень просто: качаете, делаете исполняемым и запускаете с правами sudo:
```
wget https://raw.githubusercontent.com/UrbanVampire/missing-firmware-fix/main/missing-firmware-fix.sh
chmod +x missing-firmware-fix.sh
sudo ./missing-firmware-fix.sh
```
Если что-то пошло не так, можно запустить скрипт с ключом **'--debug'** для получения расширенной информации об ошибках:
`sudo ./missing-firmware-fix.sh --debug`

Скрипт тестировался на Debian 9, Debian 10, Ubuntu 18.04, Ubuntu 20.04, Linux Mint 20.01.
