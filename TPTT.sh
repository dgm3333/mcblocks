cd "/home/david/.minetest/mods/mcimportpy"
rm -r "/home/david/.minetest/worlds/mcw/convert/TPTT-theltsoh"
mkdir "/home/david/.minetest/worlds/mcw/convert/TPTT-theltsoh"
cp "/home/david/.minetest/worlds/mcw/convert/world.mt" "/home/david/.minetest/worlds/mcw/convert/TPTT-theltsoh"
cp "/home/david/.minetest/worlds/mcw/convert/auth.txt" "/home/david/.minetest/worlds/mcw/convert/TPTT-theltsoh"
cp "/home/david/.minetest/worlds/mcw/convert/map_meta.txt" "/home/david/.minetest/worlds/mcw/convert/TPTT-theltsoh"
python3 mcimport.py "/home/david/.minetest/worlds/mcw/TPTT-theltsoh" "/home/david/.minetest/worlds/mcw/convert/TPTT-theltsoh"
cp "/home/david/.minetest/worlds/mcw/convert/TPTT-theltsoh/map.sqlite" "/home/david/.minetest/worlds/TPTT-theltsoh"
cp "/home/david/.minetest/worlds/mcw/convert/TPTT-theltsoh/map_meta.txt" "/home/david/.minetest/worlds/TPTT-theltsoh"

echo -n "Press [ENTER] to continue,...: "
read var_name


