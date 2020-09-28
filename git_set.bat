mkdir ygorepos
cd ygorepos

mkdir mycard-ygopro-database
cd mycard-ygopro-database
git init
git remote add -f origin https://github.com/mycard/ygopro-database
git config core.sparsecheckout true
echo locales/en-US/ >> .git/info/sparse-checkout
git update-index --assume-unchanged .
git pull origin master
cd ..

mkdir Fluorohydride-ygopro-scripts
cd Fluorohydride-ygopro-scripts
git init
git remote add -f origin https://github.com/Fluorohydride/ygopro-scripts.git
git pull origin master
cd ..

mkdir Fluorohydride-ygopro-pre-script
cd Fluorohydride-ygopro-pre-script
git init
git remote add -f origin https://github.com/Fluorohydride/ygopro-pre-script.git
git pull origin master
cd ..

mkdir ProjectIgnis-DeltaHopeHarbinger
cd ProjectIgnis-DeltaHopeHarbinger
git init
git remote add -f origin https://github.com/ProjectIgnis/DeltaHopeHarbinger
git config core.sparsecheckout true
echo prerelea* >> .git/info/sparse-checkout
echo !prerelease-unofficial* >> .git/info/sparse-checkout
git update-index --assume-unchanged .
git pull origin master
cd ..