draw_text(8,0,"Character: " + string(name));
draw_text(8,16,"Level: " + string(level));
for(var _i = 0; _i < array_length(items); _i++)
{
	var _item = items[_i];
	if(struct_exists(_item,"name") && struct_exists(_item,"id"))
	{
		draw_text(8, 32 + _i*16, "Item " + string(_item.id) + ": " + string(_item.name));
	}
}