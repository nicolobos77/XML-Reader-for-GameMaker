enum TAGSTYPE { TAG_START, TAG_INLINE}

/// @func XMLNode
/// @param {Struct.XMLNode} _parent Parent Node
/// @param {String} _tag Tag
/// @param {String} _inner_text Inner Text
/// @param {Struct} _attributes Attributes
/// @param {Array<Struct.XMLNode>} _children Children Nodes
function XMLNode(_parent = undefined, _tag = "", _inner_text = "", _attributes = {}, _children = array_create(0)) constructor
{
	tag = _tag;
	inner_text = _inner_text;
	parent = _parent;
	attributes = _attributes;
	childrenNodes = _children;
	
	if(!is_undefined(parent))
	{
		parent.add_child(self);
	}
	
	/// @func get_tag
	/// @return {String}
	function get_tag()
	{
		return tag;	
	}
	
	/// @func set_tag
	/// @param {String} _tag Tag
	function set_tag(_tag)
	{
		tag = _tag;
	}
	
	/// @function get_child
	/// @param {Real} _index Index
	/// @return {Struct.XMLNode}
	function get_child(_index)
	{
		return childrenNodes[_index];
	}
	
	/// @function get_children
	/// @return {Array<Struct.XMLNode>}
	function get_children()
	{
		return childrenNodes;
	}
	
	/// @function add_child
	/// @param {Struct.XMLNode} _child Child
	function add_child(_child)
	{
		array_push(childrenNodes,_child);	
	}
	
	/// @function remove_child
	/// @param {Struct.XMLNode|Real} _child Child to remove
	/// @return {Bool}
	function remove_child(_child = 0)
	{
		if(typeof(_child) == "Struct.XMLNode")
		{
			var _ind = array_get_index(childrenNodes,_child);
			if(_ind != -1)
			{
				array_delete(childrenNodes,_ind,1);
				return true;
			}
		}
		else if(typeof(_child) == "Real")
		{
			if(_child < array_length(childrenNodes))
			{
				array_delete(childrenNodes,_child,1);
				return true;
			}
		}
		return false;
	}
		
	/// @function get_attribute
	/// @param {String} _key Key
	/// @return {String}
	function get_attribute(_key = "")
	{
		return struct_get(attributes,_key);
	}
	
	/// @function set_attribute
	/// @param {String} _key Key
	/// @param {String} _value Value
	function set_attribute(_key,_value)
	{
		struct_set(attributes,_key,_value);
	}
	
	/// @func get_inner_text
	/// @return {String}
	function get_inner_text()
	{
		return inner_text;
	}
	
	/// @func set_inner_text
	/// @param {String} _inner_text Inner text
	function set_inner_text(_inner_text)
	{
		inner_text = _inner_text;
	}
	
	/// @func find_first_by_tag
	/// @param {String|undefined} _tag Tag
	function find_first_by_tag(_tag)
	{
	    for (var _i = 0; _i < array_length(get_children()); _i++) 
		{
	        var child = get_child(_i);
	        if (child.get_tag() == _tag) return child;
	    }
	    return undefined;
	}

	/// @func find_all_by_tag
	/// @param {String} _tag Tag name to search for
	/// @return {Array<Struct.XMLNode>} List of nodes matching the tag
	function find_all_by_tag(_tag)
	{
	    var _result = array_create(0);
		
	    // Recursive function to search all children
		/// @func search_children
		/// @param {Struct.XMLNode} _node Node
		/// @param {String} _tag Tag
	    function search_children(_node,_tag,_result)
	    {
	        if (_node.get_tag() == _tag)
	        {
	            array_push(_result, _node);
	        }
	        // Recur on children nodes
	        for (var _i = 0; _i < array_length(_node.get_children()); _i++)
	        {
	            search_children(_node.get_child(_i),_tag,_result);
	        }
	    }
	    search_children(self,_tag,_result);
	    return _result;
	}
}
	
/// @func XMLDocument
/// @param {Struct.XMLNode} _root Root node
/// @param {String} _version Version
/// @param {String} _encoding Encoding
function XMLDocument(_root = new XMLNode(), _version = "", _encoding = "") constructor
{
	root = _root;
	version = _version;
	encoding = _encoding;
	
	/// @func load
	/// @param {String} _file XML File
	/// @return {Bool}
	load = function load(_file)
	{
		
		if(file_exists(_file))
		{
			var _buf = buffer_load(_file);
			var _size = buffer_get_size(_buf);
				
			var _str = "";
			while(buffer_tell(_buf) < _size)
			{
				_str += ansi_char(buffer_read(_buf,buffer_u8));
			}
			if(buffer_exists(_buf))
			{
				buffer_delete(_buf);	
			}
			
			return parse(_str);
		}
		else
		{
			show_debug_message("File not found");
			return false;	
		}
	}
	
	/// @func parse_attrs
	/// @param {String} _str XML String
	/// @param {Array<Real>} _i Index
	/// @param {Array<String>} _lex Current reading text
	/// @param {Array<Real>} _lexi Reading text size
	/// @param {Struct.XMLNode} _curr_node Node
	parse_attrs = function parse_attrs(_str, _i, _lex, _lexi, _curr_node)
	{
		var _value = "";
		var _key = "";
		while(string_char_at(_str,_i[0]) != ">")
		{
			_lex[0] = string(_lex[0]) + string_char_at(_str,_i[0]);
			_lexi[0]++;
			_i[0]++;
			
			// Tag name
			if(string_char_at(_str,_i[0]) == " " && _curr_node.tag == "")
			{
				_lex[0] = string_copy(_lex[0],1,_lexi[0]);
				_curr_node.tag = _lex[0];
				_lexi[0] = 0;
				_i[0]++;
				_lex[0] = "";
				continue;
			}
			
			// Usually ignore spaces
	        if (string_char_at(_lex[0],_lexi[0]) == " ")
			{
	            _lexi[0]--;
	        }
			
	        // Attribute key
	        if (string_char_at(_str,_i[0]) == "=")
			{
	            _key = _lex[0];
	            _lexi[0] = 0;
				_lex[0] = "";
	            continue;
	        }
			
	        // Attribute value
	        if (string_char_at(_str,_i[0]) == "\"")
			{
	            if (_key == "") {
	                show_debug_message("Value has no key\n");
	                return TAGSTYPE.TAG_START;
	            }

	            _lexi[0] = 0;
				_lex[0] = "";
	            _i[0]++;
				
	            while (string_char_at(_str,_i[0]) != "\"")
				{
	                _lex[0] = string(_lex[0]) + string_char_at(_str,_i[0]);
					_lexi[0]++;
					_i[0]++;
				}
				_lex[0] = string_copy(_lex[0],1,_lexi[0]);
	            _value = string_trim(_lex[0]);
				_key = string_trim(_key);
				_curr_node.set_attribute(string(_key),string(_value));
				_key = "";
				_value = "";
	            _lexi[0] = 0;
				_lex[0] = "";
	            _i[0]++;
	            continue;
	        }

	        // Inline node
	        if (string_char_at(_str,_i[0]-1) == "/" && string_char_at(_str,_i[0]) == ">")
			{
				_lex[0] = string_copy(_lex[0],1,_lexi[0]);
	            if (_curr_node.tag == "")
	                _curr_node.tag = _lex[0];
	            _i[0]++;
				_lex[0] = "";
				_lexi[0] = 0;
	            return TAGSTYPE.TAG_INLINE;
	        }
	    }

	    return TAGSTYPE.TAG_START;
	}
		
	/// @func parse
	/// @param {String} _str XML String
	/// @return {Bool}
	parse = function parse(_str)
	{
		var _strlen = string_length(_str);
		
		var _curr_node = root;
			
		var _lex = [""];
		var _lexi = [0];
		var _i = [1];
				
		while(_i[0] <= _strlen+1)
		{
			if(string_char_at(_str,_i[0]) == "<")
			{
				_lex[0] = string_copy(_lex[0],1,_lexi[0]);
								
				// Inner Text
				if(_lexi[0] > 0)
				{
					if(is_undefined(_curr_node))
					{
						show_debug_message("Text outside of document\n");
						return false;
					}
					if(_curr_node.parent == undefined)
					{
						_lex[0] = "";	
					}
					if(string_count("\n",_lex[0]) > 0 || string_count("\r",_lex[0]) > 0)
					{
						_lex[0] = string_trim(_lex[0]);
					}
					if(_lex[0] != "")
					{
						if(_curr_node.get_inner_text() == "")
						{
							_curr_node.set_inner_text(_lex[0]);
						}
						else
						{
							_curr_node.set_inner_text(string_join("\r\n",_curr_node.get_inner_text(), _lex[0]));
						}
					}
					_lexi[0] = 0
					_lex[0] = "";
				}
				
				// End of node
				if(string_char_at(_str,_i[0] + 1) == "/")
				{
					_i[0]+=2;
					while(string_char_at(_str,_i[0]) != ">")
					{
						_lex[0] = string(_lex[0]) + string_char_at(_str,_i[0]);
						_i[0]++
						_lexi[0]++;
					}
					
					if(is_undefined(_curr_node))
					{
						show_debug_message("Already at the root\n");
						return false;
					}
					
					if(_curr_node.get_tag() != _lex[0])
					{
						show_debug_message("Mismatched tags (" + string(_curr_node.get_tag()) + " != " + string(_lex[0]) + ")\n");
						return false;	
					}
					
					_curr_node = _curr_node.parent;
					_lex[0] = "";
					_lexi[0] = 0;
					_i[0]++;
					continue;
				}
				
				// Special nodes
				if(string_char_at(_str,_i[0] + 1) == "!")
				{
					var _c = string_char_at(_str,_i[0]);
					while(_c != " " && _c != ">" && _i[0] <= string_length(_str))
					{
						_lex[0] = string(_lex[0]) + string_char_at(_str,_i[0]);
						_i[0]++;
						_lexi[0]++;
						_c = string_char_at(_str,_i[0]);
					}
					// Comments
					if(string_starts_with(_lex[0],"<!--"))
					{
						while(!string_ends_with(_lex[0],"-->") && _i[0] <= string_length(_str))
						{
							_lex[0] = string(_lex[0]) + string_char_at(_str,_i[0]);
							_lexi[0]++;
							_i[0]++;
						}
						
						// UNCOMMENT NEXT THE LINE IF YOU WANT TO READ COMMENTS FROM XML TO DO SOMETHING
						//_lex[0] = string_trim(string_copy(_lex[0],5,_lexi[0]-7));
						
						_lex[0] = "";
						_lexi[0] = 0;
						
						continue;
					}
					
					// CDATA
					if(string_starts_with(_lex[0],"<![CDATA["))
					{
						while(!string_ends_with(_lex[0],"]]>") && _i[0] <= string_length(_str))
						{
							_lex[0] = string(_lex[0]) + string_char_at(_str,_i[0]);
							_lexi[0]++;
							_i[0]++;
						}
						
						_lex[0] = string_copy(_lex[0],10,_lexi[0]-12);
						if(_curr_node.get_inner_text() == "")
						{
							_curr_node.set_inner_text(_lex[0]);
						}
						else
						{
							_curr_node.set_inner_text(string_join("\r\n",_curr_node.get_inner_text(), _lex[0]));
						}
						_lex[0] = "";
						_lexi[0] = 0;
						
						if(_i[0] > string_length(_str))
						{
							show_debug_message("CDATA not closed correctly");
							return false;
						}
						continue;
					}
				}
				
				// Declaration tags
				if(string_char_at(_str,_i[0] + 1) == "?")
				{
					while(string_char_at(_str,_i[0]) != " " && string_char_at(_str,_i[0]) != ">" && _i[0] <= string_length(_str))
					{
						_lex[0] = string(_lex[0]) + string_char_at(_str,_i[0]);
						_lexi[0]++;
						_i[0]++;
					}
					_lex[0] = string_copy(_lex[0],1,_lexi[0]);
					
					// This is the XML declaration
					if(_lex[0] == "<?xml")
					{
						_lexi[0] = 0;
						_lex[0] = "";
						var _desc = new XMLNode();
						parse_attrs(_str,_i,_lex,_lexi,_desc);
						version = is_undefined(_desc.get_attribute("version")) ? "" : _desc.get_attribute("version");
						encoding = is_undefined(_desc.get_attribute("encoding")) ? "" : _desc.get_attribute("encoding");
												
						_lex[0]= "";
						continue;
					}
				}
				
				// Set current node
				_curr_node = new XMLNode(_curr_node);
				
				// Start tag
				_i[0]++;
				_lexi[0] = 0;
				_lex[0] = "";
				if(parse_attrs(_str,_i,_lex,_lexi,_curr_node) == TAGSTYPE.TAG_INLINE)
				{
					_curr_node = _curr_node.parent;
					_i[0]++;
					continue;
				}
				
				// Set tag name if none
				_lex[0] = string_copy(_lex[0],1,_lexi[0]);
				if(_curr_node.tag == "")
				{
					_curr_node.tag = _lex[0];
				}
				
				// Reset lexer
				_lexi[0] = 0;
				_lex[0] = "";
				_i[0]++;
				continue;
			}
			else
			{
				_lex[0] = string(_lex[0]) + string_char_at(_str,_i[0]);
				_lexi[0]++;
				_i[0]++;
			}
		}
		return true;
	}
	
	/// @func generate_xml
	/// @param {Struct.XMLNode} _node Node to start generating XML from
	/// @return {String} XML string representation
	generate_xml = function generate_xml(_node)
	{
	    var _xml = "";
    
	    // If tag is empty, just serialize children
	    if (_node.tag == "")
	    {
	        for (var _i = 0; _i < array_length(_node.get_children()); _i++)
	        {
	            _xml += generate_xml(_node.get_child(_i));
	        }
	        return _xml;
	    }

	    // Normal code if tag wasn't empty
	    _xml = "<" + _node.tag;
    
	    var _attr_keys = struct_get_names(_node.attributes);
	    for (var _i = 0; _i < array_length(_attr_keys); _i++)
	    {
	        _xml += " " + _attr_keys[_i] + "=\"" + _node.get_attribute(_attr_keys[_i]) + "\"";
	    }

	    if (array_length(_node.get_children()) > 0)
	    {
	        _xml += ">";
	        for (var _i = 0; _i < array_length(_node.get_children()); _i++)
	        {
	            _xml += generate_xml(_node.get_child(_i));
	        }
	        _xml += "</" + _node.tag + ">";
	    }
	    else
	    {
	        _xml += ">" + string_trim(_node.inner_text) + "</" + _node.tag + ">";
	    }

	    return _xml;
	}

	/// @func find_first_by_tag
	/// @param {Struct.XMLNode} _node Node
	/// @param {String|undefined} _tag Tag
	find_first_by_tag = function find_first_by_tag(_node, _tag)
	{
	    for (var _i = 0; _i < array_length(_node.get_children()); _i++) 
		{
	        var child = _node.get_child(_i);
	        if (child.get_tag() == _tag) return child;
	    }
	    return undefined;
	}

	/// @func find_all_by_tag
	/// @param {Struct.XMLNode} _node Node
	/// @param {String} _tag Tag name to search for
	/// @return {Array<Struct.XMLNode>} List of nodes matching the tag
	find_all_by_tag = function find_all_by_tag(_node,_tag)
	{
	    var _result = array_create(0);
	    // Recursive function to search all children
		/// @func search_children
		/// @param {Struct.XMLNode} _node Node
		/// @param {String} _tag Tag
	    function search_children(_node,_tag,_result)
	    {
	        if (_node.get_tag() == _tag)
	        {
	            array_push(_result, _node);
	        }
	        // Recur on children nodes
	        for (var _i = 0; _i < array_length(_node.get_children()); _i++)
	        {
	            search_children(_node.get_child(_i),_tag,_result);
	        }
	    }
	    search_children(_node,_tag,_result);
	    return _result;
	}

	/// @func save_xml_to_file
	/// @param {String} _file_name File name where the XML should be saved
	/// @return {Bool} True if the file was saved successfully
	save_xml_to_file = function save_xml_to_file(_file_name)
	{
	    var _xml_string = generate_xml(root);
	    var _file = file_text_open_write(_file_name);
	    if (_file != -1)
	    {
	        file_text_write_string(_file, _xml_string);
	        file_text_close(_file);
	        return true;
	    }
	    return false;
	}

}