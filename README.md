Xiaomi Redmi AX5 AX1800 Wi-Fi 6 Mesh Router
===============

Данное руководство поможет обойти DPI методы, заблокировать рекламу и трекинг на вашем роутере без необходимости настройки каждого устройства в локальной сети.

Поддерживаемые роутеры:

- Redmi AX5 (RA67)
- Redmi AX1800

## Быстрая навигация

- [Как получить SSH доступ](#ssh-access)
- [Как настроить byedpi](#configure-byedpi)
  - [Как разблокировать свой сайт](#configure-byedpi__add-custom-host)
  - [Если byedpi не работает](#configure-byedpi__not-working)
- [Как настроить AdGuard Home](#configure-agh)
- [Как освободить память](#clear-memory)
  - [Отключить админку (опционально)](#clear-memory__disable-admin-panel)
  - [Включить админку](#clear-memory__enable-admin-panel)
- [Если роутер не запускается / сломан](#restore)

## <a id="ssh-access">Как получить SSH доступ</a>

- Необходимо откатится до прошивки `1.0.33`
  - Загрузите прошивку `miwifi_ra67_firmware_6d62a_1.0.33.bin` из папки `firmwares`
  - Зайдите в админку – [192.168.31.1](http://192.168.31.1)
  - Перейдите в настройки

    ![firmware1.png](https://github.com/dkindev/Boost-Xiaomi-Redmi-wifi-6-router/raw/main/assets/firmware1.png)

  - Установите прошивку

    ![firmware2.png](https://github.com/dkindev/Boost-Xiaomi-Redmi-wifi-6-router/raw/main/assets/firmware2.png)

  - В появившемся окне установите галочку чтобы сбросить настройки

    ![firmware3.png](https://github.com/dkindev/Boost-Xiaomi-Redmi-wifi-6-router/raw/main/assets/firmware3.png)

  - После перезагрузки роутера установите пароль и настройки доступа в интернет
- Зайдите в админку и скопируйте значение `stock` из адреса

![browser-stock.png](https://github.com/dkindev/Boost-Xiaomi-Redmi-wifi-6-router/raw/main/assets/browser-stock.png)

- Вставьте значение `stock` в строку ниже и запустите в браузере

```
http://192.168.31.1/cgi-bin/luci/;stok=STOKVALUEHERE/api/misystem/set_config_iotdev?bssid=gallifrey&user_id=doctor&ssid=-h%0Acurl%20--insecure%20https%3A%2F%2Fraw.githubusercontent.com%2Fdkindev%2FBoost-Xiaomi-Redmi-wifi-6-router%2Fmain%2Fscripts%2Funlock-ssh.sh%20%7C%20ash%0A
```
- В ответ вы должны получить `{"code":0}` и роутер перезагрузится
- Добавьте возможность установки соединения по `ssh-rsa` в `~/.ssh/config`

```
Host 192.168.31.1
    HostKeyAlgorithms +ssh-rsa
```

- Теперь вы можете войти по SSH. Пароль: _**password**_

```bash
ssh root@192.168.31.1
```

- Задайте новый пароль

```sh
passwd root
```

- (Опционально) Настройте вход по SSH ключу и отключите вход по паролю в `/etc/config/dropbear`

## <a id="configure-byedpi">Как настроить byedpi</a>

> [!NOTE]
> [byedpi](https://github.com/hufrea/byedpi) — это локальный SOCKS-прокси-сервер, реализует некоторые методы обхода DPI.

- Зайдите в админку и скопируйте значение `stock` из адреса

![browser-stock.png](https://github.com/dkindev/Boost-Xiaomi-Redmi-wifi-6-router/raw/main/assets/browser-stock.png)

- Вставьте значение `stock` в строку ниже и запустите в браузере

```
http://192.168.31.1/cgi-bin/luci/;stok=STOKVALUEHERE/api/misystem/set_config_iotdev?bssid=gallifrey&user_id=doctor&ssid=-h%0Acurl%20--insecure%20https%3A%2F%2Fraw.githubusercontent.com%2Fdkindev%2FBoost-Xiaomi-Redmi-wifi-6-router%2Fmain%2Fscripts%2Fconfigure-byedpi.sh%20%7C%20ash%0A
```

- В ответ вы должны получить `{"code":0}`
- Теперь YouTube и несколько других сервисов должны работать

### <a id="configure-byedpi__add-custom-host">Разблокировать свой сайт</a>

- Войдите по SSH
- Отредактируйте файл `/etc/config/byedpi/hosts`

```sh
vi /etc/config/byedpi/hosts
```

- Добавьте хосты
- Перезапустите byedpi

  ```sh
  /etc/init.d/run-byedpi restart
  ```

### <a id="configure-byedpi__not-working">Если byedpi не работает</a>

- Войдите по SSH
- Отредактируйте файл `/etc/init.d/run-byedpi`

```sh
vi /etc/init.d/run-byedpi
```

- Измените параметры запуска byedpi в строке

```sh
procd_set_param command "$COMMAND" -p 1080 --transparent --hosts $HOSTS_FILE -s1 -q1 -Y -Ar -s5 -o1+s -At -f-1 -r1+s -As -s1 -o1 +s -s-1 -An -b+500 --auto=none
```

- Замените

```
-s1 -q1 -Y -Ar -s5 -o1+s -At -f-1 -r1+s -As -s1 -o1 +s -s-1 -An -b+500
```

  - на какие-нибудь из этих
      - 1

      ```
      -d1+s -O1 -s29+s -t 5 -An -Ku -a5 -s443+s -d80+s -d443+s -s80+s -s443+s -d53+s -s53 +s -d443+s -An
      ```

      - 2

      ```
      -Ku -a3 -O10 -An -Kt,h -o0 -d1 -r1+s -t10 -b1500 -S -s0+s -d3+s -As,n -q1+s -s29+s -o5+s -f3 -S -As,n -d1+s -s3+s -d5+s -s7+s -r2+s -Mh,d -An
      ```

      - 3

      ```
      -Ku -a1 -An -d1 -s3+s
      ```

- Перезапустите byedpi

```sh
/etc/init.d/run-byedpi restart
```

- Если ничего не помогло, читайте [документацию](https://github.com/hufrea/byedpi) к byedpi

## <a id="configure-agh">Как настроить AdGuard Home</a>

> [!NOTE]
> [AdGuard Home](https://github.com/AdguardTeam/AdGuardHome) — это DNS-сервер, блокирующий рекламу и трекинг. Его цель – дать вам возможность контролировать всю вашу сеть и все подключённые устройства. Он не требует установки клиентских программ.

- Перед этим выполните шаг [Как освободить память](#clear-memory). AdGuard Home требует много RAM
- Зайдите в админку и скопируйте значение `stock` из адреса

![browser-stock.png](https://github.com/dkindev/Boost-Xiaomi-Redmi-wifi-6-router/raw/main/assets/browser-stock.png)

- Вставьте значение `stock` в строку ниже и запустите в браузере

```
http://192.168.31.1/cgi-bin/luci/;stok=STOKVALUEHERE/api/misystem/set_config_iotdev?bssid=gallifrey&user_id=doctor&ssid=-h%0Acurl%20--insecure%20https%3A%2F%2Fraw.githubusercontent.com%2Fdkindev%2FBoost-Xiaomi-Redmi-wifi-6-router%2Fmain%2Fscripts%2Fconfigure-agh.sh%20%7C%20ash%0A
```

- В ответ вы должны получить `{"code":0}`
- Не пугайтесь что у вас не открываются сайты
- Переходим к установке – [192.168.31.1:3000/install.html](http://192.168.31.1:3000/install.html)
- В данном окне выставляем `Сетевой интерфейс -> Все интерфейсы` и порты

![agh1.png](https://github.com/dkindev/Boost-Xiaomi-Redmi-wifi-6-router/raw/main/assets/agh1.png)

- Задайте логин и пароль для входа
- После завершения войдите в админку – [192.168.31.1:8081/login.html](http://192.168.31.1:8081/login.html)
- Переходим в `Настройки -> Основные настройки`
  - В `Настройка журнала` выставляем `Частота ротации журнала запросов` на 24 часа и сохраняем
  - В `Конфигурация статистики` выставляем `Сохранение статистики` на 24 часа и сохраняем
- Переходим в `Настройки -> Настройки DNS`
  - В `Приватные серверы для обратного DNS` вставляем `127.0.0.1:54` и отмечаем галочку `Использовать приватные обратные DNS-резолверы`, нажимаем `Применить`
  - В `Настройки DNS-сервера` отмечаем галочку `Включить DNSSEC`, нажимаем `Применить`
  - (Опционально) Добавить Cloudflare `Bootstrap DNS-серверы` 1.1.1.1 и 1.0.0.1, но чтобы они располагались в самом верху списка
  - (Опционально) Добавить Cloudflare `Upstream DNS-серверы` https://cloudflare-dns.com/dns-query на первое место
- (Опционально) В `Фильтры -> Чёрные списки DNS` включить `AdAway Default Blocklist` 

## <a id="clear-memory">Как освободить память</a>

Это необходимо для запуска/установки дополнительных компонентов, в том числе AdGuard Home

- Зайдите в админку и скопируйте значение `stock` из адреса

![browser-stock.png](https://github.com/dkindev/Boost-Xiaomi-Redmi-wifi-6-router/raw/main/assets/browser-stock.png)

- Вставьте значение `stock` в строку ниже и запустите в браузере

```
http://192.168.31.1/cgi-bin/luci/;stok=STOKVALUEHERE/api/misystem/set_config_iotdev?bssid=gallifrey&user_id=doctor&ssid=-h%0Acurl%20--insecure%20https%3A%2F%2Fraw.githubusercontent.com%2Fdkindev%2FBoost-Xiaomi-Redmi-wifi-6-router%2Fmain%2Fscripts%2Fclear-memory.sh%20%7C%20ash%0A
```

- В ответ вы должны получить `{"code":0}`

### <a id="clear-memory__disable-admin-panel">Отключить админку (опционально)</a>

Это еще больше снизит нагрузку на роутер

> [!WARNING]
> Если вы отключите админку, то не сможете зайти в нее и выполнить скрипты в браузере.

- Запустите в браузере (замените значение `stock`)

```
http://192.168.31.1/cgi-bin/luci/;stok=STOKVALUEHERE/api/misystem/set_config_iotdev?bssid=gallifrey&user_id=doctor&ssid=-h%0Acurl%20--insecure%20https%3A%2F%2Fraw.githubusercontent.com%2Fdkindev%2FBoost-Xiaomi-Redmi-wifi-6-router%2Fmain%2Fscripts%2Fdisable-admin-panel.sh%20%7C%20ash%0A
```

### <a id="clear-memory__enable-admin-panel">Включить админку</a>

- Войдите по SSH
- Выполните

```sh
/etc/init.d/nginx enable
/etc/init.d/nginx start
```

## <a id="restore">Если роутер не запускается / сломан</a>

- Скачиваете утилиту восстановления `MIWIFIRepairTool.x86.zip` из папки `utils` 
- Скачиваете прошивку `miwifi_ra67_firmware_6d62a_1.0.33.bin` из папки `firmwares`
- Подключаете роутер через LAN порт с помощью патч-корда к компьютеру
- Отключаете все сетевые адаптеры, кроме того, к которому подключён роутер
- Запускаете утилиту восстановления. Разрешаете программе доступ в окне брандмауэра
- В первом окне необходимо указать файл прошивки и нажать далее
- Во втором нужно указать сетевой адаптер, к которому подключён роутер в данный момент, и нажать далее
- В третьем окне нужно следовать инструкции: выключить роутер, зажать скрепкой кнопку Reset и включить питание. Нужно держать зажатой кнопку Reset до тех пор, пока индикатор не начнёт мигать жёлтым светом, затем её нужно отпустить
- Если всё сделали правильно, начнётся процесс восстановления, должно появиться окошко прогресса, как на четвёртой картинке
- Далее нужно подождать, пока индикатор не замигает синим светом. На этом процесс восстановления завершён, можно отключать питание роутера
