A powerful and lightweight XML parser written entirely in GML — perfect for reading and manipulating XML files directly in GameMaker, with no external dependencies or DLLs.

# Key Features:
- Load XML string from file using buffer (it's implemented on the script, you don't have to manage this) or just parse XML from string
- Struct-based architecture: XMLDocument, XMLNode
- Supports nested nodes, attributes, inner text, and CDATA(as inner text)
- Ignores comments from XML file/string
- Easy to integrate
- 100% GML, no external dependencies
- Ideal for level data, game settings, dialogue systems, and more
- Find nodes using find_first_by_tag or find_all_by_tag
- Getting and setting functions for tag, inner_text, child, children
- Add/remove child node functions
- Generate a new XML string
- Save a XML file

# How to Use:

## 1 - Instance the constructor

```GML
var document = new XMLDocument();
```

## 2 - Load or parse XML string

Examples:

```GML
// Load a XML file
if (document.load(working_directory + "test.xml"))
{
	// Do something with document here
}
```

```GML
// Parse a XML string
document.parse("<?xml version="1.0" encoding="UTF-8"?>
<player name="Hero" level="5">
        <inventory>
            <item id="1" name="Sword" />
            <item id="2" name="Shield" />
        </inventory>
    </player>");
// Do something with document here
```

## 3 - Do something with document variable

```GML
// Make an auxiliar variable and set it to document's root, if you don't have to access root document more than once, you don't need to make this variable, just use document.root
var _root = document.root;
```

```GML
// Find first "player" tag
var _player = document.root.find_first_by_tag("player");
// If the node was found
if(!is_undefined(_player))
{
	// Get name attribute
	var _name = _player.get_attribute("name");
	// If name attribute exists
	if(!is_undefined(_name))
	{
		name = _name;
	}
}
```

- This example loads name, level and items for a player

```GML
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
```
