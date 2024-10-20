::
:: file create by liunianliang for windows fastboot flash image
::
:: 20180117
::
@echo off
@echo ------------------------
@echo Begin fastboot flashall
@echo ------------------------

@setlocal enabledelayedexpansion

:: get platform
@set platform=sdm660
@set buildtype=eng
@set current-slot=a
@set frp-partition=QHYBSBJk
@set input=%1%
@set deviceId=%2%
@set flashtype=%3%

if !input! == 0 (
    @echo Earse Data: No
) else (
    @echo Earse Data: Yes
)

if "!deviceId!" == "" (
    @echo Support All device !
) else (
    @echo Support one device: !deviceId!
)

if "!deviceId!" == "" (
@fastboot getvar platform 2>&1 | findstr platform > platform.txt
@fastboot getvar current-slot 2>&1 | findstr current-slot > current-slot.txt
@fastboot getvar build-type 2>&1 | findstr build-type > build-type.txt
@fastboot getvar secret-key-opt 2>&1 | findstr secret-key-opt > secret-key-opt.txt
@fastboot oem get_random_partition 2>&1 | findstr bootloader > frp-partition.txt
) else (
@fastboot -s !deviceId! getvar platform 2>&1 | findstr platform > platform.txt
@fastboot -s !deviceId! getvar current-slot 2>&1 | findstr current-slot > current-slot.txt
@fastboot -s !deviceId! getvar build-type 2>&1 | findstr build-type > build-type.txt
@fastboot -s !deviceId! getvar secret-key-opt 2>&1 | findstr secret-key-opt > secret-key-opt.txt
@fastboot -s !deviceId! oem get_random_partition 2>&1 | findstr bootloader > frp-partition.txt
)

@for /f "tokens=2 delims=: " %%i in (current-slot.txt) do @(
    set "current-slot=%%i"
    @echo current-slot is !current-slot!

    @for /f "tokens=2 delims=: " %%a in (build-type.txt) do (
        set "buildtype=%%a"
    )

    @for /f "tokens=2 delims=: " %%n in (platform.txt) do (
        set "platform=%%n"
    )

    @for /f "tokens=2 delims=: " %%k in (secret-key-opt.txt) do (
        set "secret_key=%%k"
        set /p =!secret_key!<nul> default_key.bin
    )

    @for /f "tokens=2 delims=: " %%m in (frp-partition.txt) do (
        set "frp-partition=%%m"
    )

    @echo buildtype is !buildtype!
    if !buildtype! == user (
        if "!deviceId!" == "" (
            fastboot flash !frp-partition! default_key.bin
            fastboot flashing unlock
            fastboot flashing unlock_critical
        ) else (
            fastboot -s !deviceId! flash !frp-partition! default_key.bin
            fastboot -s !deviceId! flashing unlock
            fastboot -s !deviceId! flashing unlock_critical
        )
    )

    if "!deviceId!" == "" (
        if !input! == 0 (
            @echo not do factory reset...
        ) else (
            fastboot oem recovery_and_reboot
        )
    ) else (
        if !input! == 0 (
            @echo not do factory reset...
        ) else (
            fastboot -s !deviceId! oem recovery_and_reboot
        )
    )
)

@echo All is download
goto:eof

:: function for download
:flash_one_image
@echo --------------------------------
@echo begin to flash partition %1
@if exist %~dp0!platform!_%2 (
    if "!deviceId!" == "" (
        fastboot flash %1 %~dp0!platform!_%2
    ) else (
        fastboot -s !deviceId! flash %1 %~dp0!platform!_%2
    )
) else (
    if exist %~dp0%2 (
        if "!deviceId!" == "" (
            fastboot flash %1 %~dp0%2
        ) else (
            fastboot -s !deviceId! flash %1 %~dp0%2
        )
    ) else (
        @echo can't flash partion %1
    )
)
@echo done!
@echo --------------------------------
