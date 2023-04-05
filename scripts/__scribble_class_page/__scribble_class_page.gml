#macro __SCRIBBLE_PAGE_VALIDATE_LINE_INDEX  if (_line_index < 0) __scribble_error("Line index ", _line_index, " doesn't exist. Minimum line index is 0");\
                                            var _line_count = array_length(__line_array);\
                                            if (_line_index >= _line_count) __scribble_error("Line index ", _line_index, " doesn't exist. Maximum line index is ", _line_count-1);

function __scribble_class_page() constructor
{
    static __scribble_state = __scribble_get_state();
    
    __text = "";
    __glyph_grid = undefined;
    
    __created_frame = __scribble_state.__frames;
    __frozen = undefined;
    
    __character_count = 0;
    
    __glyph_start = undefined;
    __glyph_end   = undefined;
    __glyph_count = 0;
    
    __line_start = undefined;
    __line_end   = undefined;
    __line_count = 0;
    
    __line_array = [];
    
    __width  = 0;
    __height = 0;
    __min_x  = 0;
    __min_y  = 0;
    __max_x  = 0;
    __max_y  = 0;
    
    __vertex_buffer_array = [];
    if (!__SCRIBBLE_ON_WEB) __material_alias_to_vertex_buffer_dict = {}; //FIXME - Workaround for pointers not being stringified properly on HTML5
    
    __char_events  = {};
    __line_events  = {};
    __region_array = [];
    
    static __submit = function(_double_draw)
    {
        if (SCRIBBLE_INCREMENTAL_FREEZE && !__frozen && (__created_frame < __scribble_state.__frames)) __freeze();
        
        var _old_tex_filter = gpu_get_tex_filter();
        
        var _i = 0;
        repeat(array_length(__vertex_buffer_array))
        {
            __vertex_buffer_array[_i].__submit(_double_draw);
            ++_i;
        }
        
        gpu_set_tex_filter(_old_tex_filter);
    }
    
    static __freeze = function()
    {
        if (SCRIBBLE_VERBOSE) var _t = get_timer();
        
        var _i = 0;
        repeat(array_length(__vertex_buffer_array))
        {
            vertex_freeze(__vertex_buffer_array[_i].__vertex_buffer);
            ++_i;
        }
        
        __frozen = true;
            
        if (SCRIBBLE_VERBOSE) __scribble_trace("Incrementally froze page vertex buffers, time taken = ", (get_timer() - _t)/1000, "ms");
    }
    
    /// @param glyphIndex
    static __get_glyph_data = function(_index)
    {
        if (!SCRIBBLE_ALLOW_GLYPH_DATA_GETTER) __scribble_error("Cannot get glyph data, SCRIBBLE_ALLOW_GLYPH_DATA_GETTER = <false>\nPlease set SCRIBBLE_ALLOW_GLYPH_DATA_GETTER to <true> to get glyph data");
        
        if (_index < 0)
        {
            return {
                unicode: 0,
                left:    __glyph_grid[# 0, __SCRIBBLE_GLYPH_LAYOUT.__LEFT  ],
                top:     __glyph_grid[# 0, __SCRIBBLE_GLYPH_LAYOUT.__TOP   ],
                right:   __glyph_grid[# 0, __SCRIBBLE_GLYPH_LAYOUT.__LEFT  ],
                bottom:  __glyph_grid[# 0, __SCRIBBLE_GLYPH_LAYOUT.__BOTTOM],
            };
        }
        else
        {
            _index = min(_index, __glyph_count-1);
            
            return {
                unicode: __glyph_grid[# _index, __SCRIBBLE_GLYPH_LAYOUT.__UNICODE],
                left:    __glyph_grid[# _index, __SCRIBBLE_GLYPH_LAYOUT.__LEFT   ],
                top:     __glyph_grid[# _index, __SCRIBBLE_GLYPH_LAYOUT.__TOP    ],
                right:   __glyph_grid[# _index, __SCRIBBLE_GLYPH_LAYOUT.__RIGHT  ],
                bottom:  __glyph_grid[# _index, __SCRIBBLE_GLYPH_LAYOUT.__BOTTOM ],
            };
        }
    }
    
    /// @param lineIndex
    static __get_line_y = function(_line_index)
    {
        __SCRIBBLE_PAGE_VALIDATE_LINE_INDEX
        return __line_array[_line_index].__y;
    }
    
    /// @param lineIndex
    static __get_line_height = function(_line_index)
    {
        __SCRIBBLE_PAGE_VALIDATE_LINE_INDEX
        return __line_array[_line_index].__height;
    }
    
    static __get_scroll_max = function()
    {
        var _line_count = array_length(__line_array);
        if (_line_count <= 0) return 0;
        
        with(__line_array[_line_count-1])
        {
            return __y + __height;
        }
    }
    
    static __ensure_vertex_buffer = function(_material_alias)
    {
        if (!__SCRIBBLE_ON_WEB)
        {
            var _data = __material_alias_to_vertex_buffer_dict[$ string(_material_alias)];
        }
        else //FIXME - Workaround for pointers not being stringified properly on HTML5
        {
            var _data = undefined;
            var _i = 0;
            repeat(array_length(__vertex_buffer_array))
            {
                var _vbuff_data = __vertex_buffer_array[_i];
                if (_vbuff_data.__material_alias == _material_alias)
                {
                    _data = _vbuff_data;
                    break;
                }
                
                ++_i;
            }
        }
        
        if (_data == undefined)
        {
            var _data = new __scribble_class_vertex_buffer(_material_alias);
            array_push(__vertex_buffer_array, _data);
            __material_alias_to_vertex_buffer_dict[$ string(_material_alias)] = _data;
        }
        
        return _data.__vertex_buffer;
    }
    
    static __finalize_vertex_buffers = function(_freeze)
    {
        var _i = 0;
        repeat(array_length(__vertex_buffer_array))
        {
            var _vbuff = __vertex_buffer_array[_i].__vertex_buffer;
            vertex_end(_vbuff);
            if (_freeze) vertex_freeze(_vbuff);
            
            ++_i;
        }
        
        __frozen = _freeze;
    }
    
    static __flush = function()
    {
        var _i = 0;
        repeat(array_length(__vertex_buffer_array))
        {
            __vertex_buffer_array[_i].__flush();
            ++_i;
        }
        
        __material_alias_to_vertex_buffer_dict = {};
        array_resize(__vertex_buffer_array, 0);
    }
}