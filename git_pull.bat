cd ygorepos
for /D %%G in ("*") do (echo %%G) && (cd %%G) && (git pull origin master) && (cd ..)
cd..