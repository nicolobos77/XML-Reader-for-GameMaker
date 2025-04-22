// Instance XMLDocument
document = new XMLDocument();

// Make an array for items
items = [];

// Make name variable
name = "";

// Make level variable
level = 1;

// Load XML file and check if it's OK
if(document.load(working_directory + "test.xml"))
{
	// Find first "player" tag
	var _player = document.root.find_first_by_tag("player");
	// If the node was found
	if(!is_undefined(_player))
	{
		// Get level attribute
		var _level = _player.get_attribute("level");
		// Get name attribute
		var _name = _player.get_attribute("name");
		// If level and name attributes exist
		if(!is_undefined(_level) && !is_undefined(_name))
		{
			name = _name;
			level = real(_level);
		}
		// Find inventory node
		var _inventory = _player.find_first_by_tag("inventory");
		// If the node was found
		if(!is_undefined(_inventory))
		{
			// Get children array
			var _items = _inventory.get_children();
			// Loop through children array
			for(var _i = 0; _i < array_length(_items); _i++)
			{
				// Get item
				var _item = _items[_i];
				// Get id attribute
				var _id = _item.get_attribute("id");
				// Get name attribute
				var _item_name = _item.get_attribute("name");
				// If id and name attributes exist
				if(!is_undefined(_id) && !is_undefined(_item_name))
				{
					// Create a struct for loaded item
					var _litem = {};
					// Set item struct keys
					struct_set(_litem,"id",_id);
					struct_set(_litem,"name",_item_name);
					// Add it to items array
					array_push(items,_litem);
				}
			}
		}
	}
}