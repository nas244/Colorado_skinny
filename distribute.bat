"C:\Program Files\7-Zip\7z.exe" a -tzip ColoradoSkinny.love assets\* entities\* libs\* main.lua

copy /b 64\love.exe+ColoradoSkinny.love 64\ColoradoSkinny.exe
copy /b 32\love.exe+ColoradoSkinny.love 32\ColoradoSkinny.exe

pause