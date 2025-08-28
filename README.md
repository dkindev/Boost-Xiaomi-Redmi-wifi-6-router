Xiaomi Redmi AX5 AX1800 Wi-Fi 6 Mesh Router
===============

Данное руководство поможет обойти DPI методы, заблокировать рекламу и трекинг на вашем роутере без необходимости настройки каждого устройства в локальной сети.

Поддерживаемые роутеры:

- Redmi AX5 (RA67)
- Redmi AX1800

## Быстрая навиграция

- [Как получить SSH доступ](#ssh-access)
- [Как настроить byedpi](#configure-byedpi)
  - [Как разблокировать свой сайт](#configure-byedpi__add-custom-host)
  - [Если byedpi не работает](#configure-byedpi__not-working)

## <a href="#ssh-access" id="ssh-access" name="ssh-access">Как получить SSH доступ</a>

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

## <a href="#configure-byedpi" id="configure-byedpi" name="configure-byedpi">Как настроить byedpi</a>

> [!NOTE]
> [byedpi](https://github.com/hufrea/byedpi) — это локальный SOCKS-прокси-сервер, реализует некоторые методы обхода DPI.

- Зайдите в админку и скопируйте значение `stock` из адреса

![browser-stock.png](https://github.com/dkindev/Boost-Xiaomi-Redmi-wifi-6-router/raw/main/assets/browser-stock.png)

- Вставьте значение `stock` в строку ниже и запустите в браузере

```
http://192.168.31.1/cgi-bin/luci/;stok=STOKVALUEHERE/api/misystem/set_config_iotdev?bssid=gallifrey&user_id=doctor&ssid=-h%0Acurl%20--insecure%20https%3A%2F%2Fraw.githubusercontent.com%2Fdkindev%2FBoost-Xiaomi-Redmi-wifi-6-router%2Fmain%2Fscripts%2Fconfigure-byedpi.sh%20%7C%20ash%0A
```

- В ответ вы должны получить `{"code":0}`
- Теперь YouTube и несколько других сервисов должены работать

### <a href="#configure-byedpi__add-custom-host" id="configure-byedpi__add-custom-host" name="configure-byedpi__add-custom-host">Разблокировать свой сайт</a>

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

### <a href="#configure-byedpi__not-working" id="configure-byedpi__not-working" name="configure-byedpi__not-working">Если byedpi не работает</a>

- Войдите по SSH
- Отредактируйте файл `/etc/init.d/run-byedpi`

```sh
vi /etc/init.d/run-byedpi
```

- Измените параметры запуска byedpi, попробуйте какие-нибудь из этих

  - 1

  ```
  -d1+s -O1 -s29+s -t 5 -An -Ku -a5 -s443+s -d80+s -d443+s -s80+s -s443+s -d53+s -s53+s -d443+s -An
  ```

  - 2

  ```
  -Ku -a3 -O10 -An -Kt,h -o0 -d1 -r1+s -t10 -b1500 -S -s0+s -d3+s -As,n -q1+s -s29+s -o5+s -f3 -S -As,n -d1+s -s3+s -d5+s -s7+s -r2+s -Mh,d -An
  ```
  - 3

  ```
  -s1 -q1 -Y -Ar -s5 -o1+s -At -f-1 -r1+s -As -s1 -o1 +s -s-1 -An -b+500
  ```

- Перезапустите byedpi

```sh
/etc/init.d/run-byedpi restart
```

- Если ничего не помогло, читайте [документацию](https://github.com/hufrea/byedpi) к byedpi

## Как настроить AdGuard Home

> [!NOTE]
> [AdGuard Home](https://github.com/AdguardTeam/AdGuardHome) — это DNS-сервер, блокирующий рекламу и трекинг. Его цель – дать вам возможность контролировать всю вашу сеть и все подключённые устройства. Он не требует установки клиентских программ.

## Как освободить память

## Если роутер не запускается