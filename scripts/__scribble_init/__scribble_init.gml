var _font_directory = SCRIBBLE_INCLUDED_FILES_SUBDIRECTORY;

//If we've already initialized, don't try to do it again
if (variable_global_exists("__scribble_lcg")) return undefined;

__scribble_trace("Welcome to Scribble by @jujuadams! This is version " + __SCRIBBLE_VERSION + ", " + __SCRIBBLE_DATE);
    
if (__SCRIBBLE_ON_MOBILE)
{
    if (_font_directory != "")
    {
        __scribble_trace("Included Files work a bit strangely on iOS and Android. Please use an empty string for the font directory and place fonts in the root of Included Files.");
        show_error("Scribble:\nGameMaker's Included Files work a bit strangely on iOS and Android.\nPlease use an empty string for the font directory and place fonts in the root of Included Files.\n ", true);
        exit;
    }
}
else if (__SCRIBBLE_ON_WEB)
{
    if (_font_directory != "")
    {
        __scribble_trace("Using folders inside Included Files might not work properly on HTML5. If you're having trouble, try using an empty string for the font directory and place fonts in the root of Included Files.");
    }
}
    
if (_font_directory != "")
{
    //Fix the font directory name if it's weird
    var _char = string_char_at(_font_directory, string_length(_font_directory));
    if (_char != "\\") && (_char != "/") _font_directory += "\\";
}
    
if (!__SCRIBBLE_ON_WEB)
{
    //Check if the directory exists
    if ((_font_directory != "") && !directory_exists(_font_directory))
    {
        __scribble_trace("WARNING! Font directory \"" + string(_font_directory) + "\" could not be found in \"" + game_save_id + "\"!");
    }
}
    
//Declare global variables
global.__scribble_lcg                 = date_current_datetime()*100;
global.__scribble_font_directory      = _font_directory;
global.__scribble_font_data           = ds_map_create();  //Stores a data array for each font defined inside Scribble
global.__scribble_effects             = ds_map_create();  //Bidirectional lookup - stores name:index as well as index:name
global.__scribble_effects_slash       = ds_map_create();  //Bidirectional lookup - stores name:index as well as index:name
global.__scribble_default_font        = undefined;
global.__scribble_buffer              = buffer_create(1024, buffer_grow, 1);
global.__scribble_window_array_null   = array_create(2*__SCRIBBLE_WINDOW_COUNT, 1.0);
global.__scribble_character_delay     = false;
global.__scribble_character_delay_map = ds_map_create();
global.__scribble_font_family_map     = ds_map_create();

global.__scribble_model_cache              = ds_map_create();
global.__scribble_model_cache_list         = ds_list_create();
global.__scribble_model_cache_test_index   = 0;
global.__scribble_element_cache            = ds_map_create();
global.__scribble_element_cache_list       = ds_list_create();
global.__scribble_element_cache_test_index = 0;
global.__scribble_callstack_cache          = ds_map_create();

if (!variable_global_exists("__scribble_colours")) global.__scribble_colours = ds_map_create();

if (!variable_global_exists("__scribble_typewriter_events")) global.__scribble_typewriter_events = ds_map_create();
global.__scribble_typewriter_events[? "pause"] = undefined;
global.__scribble_typewriter_events[? "delay"] = undefined;
    
//Add bindings for default effect names
//Effect index 0 is reversed for sprites
global.__scribble_effects[?       "wave"    ] = 1;
global.__scribble_effects[?       "shake"   ] = 2;
global.__scribble_effects[?       "rainbow" ] = 3;
global.__scribble_effects[?       "wobble"  ] = 4;
global.__scribble_effects[?       "pulse"   ] = 5;
global.__scribble_effects[?       "wheel"   ] = 6;
global.__scribble_effects[?       "cycle"   ] = 7;
global.__scribble_effects[?       "jitter"  ] = 8;
global.__scribble_effects_slash[? "/wave"   ] = 1;
global.__scribble_effects_slash[? "/shake"  ] = 2;
global.__scribble_effects_slash[? "/rainbow"] = 3;
global.__scribble_effects_slash[? "/wobble" ] = 4;
global.__scribble_effects_slash[? "/pulse"  ] = 5;
global.__scribble_effects_slash[? "/wheel"  ] = 6;
global.__scribble_effects_slash[? "/cycle"  ] = 7;
global.__scribble_effects_slash[? "/jitter" ] = 8;
    
//Create a vertex format for our text
vertex_format_begin();
vertex_format_add_position_3d(); //12 bytes
vertex_format_add_normal();      //12 bytes       //X = character index, Y = line index, Z = effect flags
vertex_format_add_colour();      // 4 bytes
vertex_format_add_texcoord();    // 8 bytes
global.__scribble_vertex_format = vertex_format_end(); //36 bytes per vertex, 108 bytes per tri, 216 bytes per glyph
    
vertex_format_begin();
vertex_format_add_position(); //12 bytes
vertex_format_add_color();    // 4 bytes
vertex_format_add_texcoord(); // 8 bytes
global.__scribble_passthrough_vertex_format = vertex_format_end();
    
//Cache uniform indexes
global.__scribble_uniform_time            = shader_get_uniform(__shd_scribble, "u_fTime"                 );
global.__scribble_uniform_colour_blend    = shader_get_uniform(__shd_scribble, "u_vColourBlend"          );
global.__scribble_uniform_fog             = shader_get_uniform(__shd_scribble, "u_vFog"                  );
global.__scribble_uniform_tw_method       = shader_get_uniform(__shd_scribble, "u_fTypewriterMethod"     );
global.__scribble_uniform_tw_window_array = shader_get_uniform(__shd_scribble, "u_fTypewriterWindowArray");
global.__scribble_uniform_tw_smoothness   = shader_get_uniform(__shd_scribble, "u_fTypewriterSmoothness" );
global.__scribble_uniform_data_fields     = shader_get_uniform(__shd_scribble, "u_aDataFields"           );
global.__scribble_uniform_bezier_array    = shader_get_uniform(__shd_scribble, "u_aBezier"               );
    
//Hex converter array
var _min = ord("0");
var _max = ord("f");
global.__scribble_hex_min = _min;
global.__scribble_hex_max = _max;
global.__scribble_hex_array = array_create(1 + _max - _min);
global.__scribble_hex_array[@ ord("0") - _min] =  0; //ascii  48 = array  0
global.__scribble_hex_array[@ ord("1") - _min] =  1; //ascii  49 = array  1
global.__scribble_hex_array[@ ord("2") - _min] =  2; //ascii  50 = array  2
global.__scribble_hex_array[@ ord("3") - _min] =  3; //ascii  51 = array  3
global.__scribble_hex_array[@ ord("4") - _min] =  4; //ascii  52 = array  4
global.__scribble_hex_array[@ ord("5") - _min] =  5; //ascii  53 = array  5
global.__scribble_hex_array[@ ord("6") - _min] =  6; //ascii  54 = array  6
global.__scribble_hex_array[@ ord("7") - _min] =  7; //ascii  55 = array  7
global.__scribble_hex_array[@ ord("8") - _min] =  8; //ascii  56 = array  8
global.__scribble_hex_array[@ ord("9") - _min] =  9; //ascii  57 = array  9
global.__scribble_hex_array[@ ord("A") - _min] = 10; //ascii  65 = array 17
global.__scribble_hex_array[@ ord("B") - _min] = 11; //ascii  66 = array 18
global.__scribble_hex_array[@ ord("C") - _min] = 12; //ascii  67 = array 19
global.__scribble_hex_array[@ ord("D") - _min] = 13; //ascii  68 = array 20
global.__scribble_hex_array[@ ord("E") - _min] = 14; //ascii  69 = array 21
global.__scribble_hex_array[@ ord("F") - _min] = 15; //ascii  70 = array 22
global.__scribble_hex_array[@ ord("a") - _min] = 10; //ascii  97 = array 49
global.__scribble_hex_array[@ ord("b") - _min] = 11; //ascii  98 = array 50
global.__scribble_hex_array[@ ord("c") - _min] = 12; //ascii  99 = array 51
global.__scribble_hex_array[@ ord("d") - _min] = 13; //ascii 100 = array 52
global.__scribble_hex_array[@ ord("e") - _min] = 14; //ascii 101 = array 53
global.__scribble_hex_array[@ ord("f") - _min] = 15; //ascii 102 = array 54

function __scribble_trace()
{
    var _string = "Scribble: ";
    
    var _i = 0
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    show_debug_message(_string);
}

/// Convertes an RGB colour code (the industry standard) to GameMaker's native BGR format
/// @param RGB
function scribble_rgb_to_bgr(_rgb)
{
    return make_colour_rgb(colour_get_blue(_rgb), colour_get_green(_rgb), colour_get_red(_rgb));
}

function __scribble_get_font_data(_name)
{
    var _data = global.__scribble_font_data[? _name];
    
    if (_data == undefined)
    {
        show_error("Scribble:\nFont \"" + string(_name) + "\" not recognised\nIf you're using tags, check this font has been tagged with \"Scribble\"\n ", true);
    }
    
    return _data;
}

function __scribble_process_colour(_value)
{
    if (is_string(_value))
    {
        if (!ds_map_exists(global.__scribble_colours, _value))
        {
            show_error("Scribble:\nColour \"" + _value + "\" not recognised. Please add it to scribble_colours()\n ", true);
        }
        
        return global.__scribble_colours[? _value];
    }
    else
    {
        return _value;
    }
}

function __scribble_random()
{
    global.__scribble_lcg = (48271*global.__scribble_lcg) mod 2147483647; //Lehmer
    return global.__scribble_lcg / 2147483648;
}

#region Internal Macro Definitions

// @jujuadams
// With thanks to glitchroy, Mark Turner, DragoniteSpam, sp202, Rob van Saaze, soVes, and @stoozey_
#macro __SCRIBBLE_VERSION  "7.0.0"
#macro __SCRIBBLE_DATE     "2020-10-03"
#macro __SCRIBBLE_DEBUG    false

//You'll usually only want to modify SCRIBBLE_GLYPH.X_OFFSET, SCRIBBLE_GLYPH.Y_OFFSET, and SCRIBBLE_GLYPH.SEPARATION
enum SCRIBBLE_GLYPH
{
    CHARACTER,  // 0
    INDEX,      // 1
    WIDTH,      // 2
    HEIGHT,     // 3
    X_OFFSET,   // 4
    Y_OFFSET,   // 5
    SEPARATION, // 6
    TEXTURE,    // 7
    U0,         // 8
    V0,         // 9
    U1,         //10
    V1,         //11
    __SIZE      //12
}

enum __SCRIBBLE_VERTEX
{
    X              =  0,
    Y              =  4,
    PACKED_INDEXES =  8,
    CENTRE_DXDY    = 12,
    SPRITE_DATA    = 16,
    EFFECT_FLAGS   = 20,
    COLOUR         = 24,
    U              = 28,
    V              = 32,
    __SIZE         = 36
}

enum __SCRIBBLE_ANIM
{
    WAVE_SIZE,        // 0
    WAVE_FREQ,        // 1
    WAVE_SPEED,       // 2
    SHAKE_SIZE,       // 3
    SHAKE_SPEED,      // 4
    RAINBOW_WEIGHT,   // 5
    RAINBOW_SPEED,    // 6
    WOBBLE_ANGLE,     // 7
    WOBBLE_FREQ,      // 8
    PULSE_SCALE,      // 9
    PULSE_SPEED,      //10
    WHEEL_SIZE,       //11
    WHEEL_FREQ,       //12
    WHEEL_SPEED,      //13
    CYCLE_SPEED,      //14
    CYCLE_SATURATION, //15
    CYCLE_VALUE,      //16
    JITTER_MINIMUM,   //17
    JITTER_MAXIMUM,   //18
    JITTER_SPEED,     //19
    __SIZE,           //20
}

#macro __SCRIBBLE_ON_DIRECTX           ((os_type == os_windows) || (os_type == os_xboxone) || (os_type == os_uwp) || (os_type == os_win8native) || (os_type == os_winphone))
#macro __SCRIBBLE_ON_OPENGL            (!__SCRIBBLE_ON_DIRECTX)
#macro __SCRIBBLE_ON_MOBILE            ((os_type == os_ios) || (os_type == os_android) || (os_type == os_tvos))
#macro __SCRIBBLE_ON_WEB               (os_browser != browser_not_a_browser)
#macro __SCRIBBLE_GLYPH_BYTE_SIZE      (6*__SCRIBBLE_VERTEX.__SIZE)
#macro __SCRIBBLE_EXPECTED_GLYPHS      100
#macro __SCRIBBLE_EXPECTED_FRAME_TIME  (0.95*game_get_speed(gamespeed_microseconds)/1000) //Uses to prevent the autotype from advancing if a draw call is made multiple times a frame to the same text element
#macro __SCRIBBLE_PIN_LEFT             3
#macro __SCRIBBLE_PIN_CENTRE           4
#macro __SCRIBBLE_PIN_RIGHT            5
#macro __SCRIBBLE_WINDOW_COUNT         4
#macro SCRIBBLE_DEFAULT_FONT           global.__scribble_default_font

//Normally, Scribble will try to sequentially store glyph data in an array for fast lookup.
//However, some font definitons may have disjointed character indexes (e.g. Chinese). Scribble will detect these fonts and use a ds_map instead for glyph data lookup
#macro __SCRIBBLE_SEQUENTIAL_GLYPH_TRY        true
#macro __SCRIBBLE_SEQUENTIAL_GLYPH_MAX_RANGE  300  //If the glyph range (min index to max index) exceeds this number, a font's glyphs will be indexed using a ds_map
#macro __SCRIBBLE_SEQUENTIAL_GLYPH_MAX_HOLES  0.50 //Fraction (0 -> 1). If the number of holes exceeds this proportion, a font's glyphs will be indexed using a ds_map

#macro __SCRIBBLE_MAX_LINES  1000  //Maximum number of lines in a textbox. Thise constant must match the corresponding values in __shd_scribble

//TODO - Sort this out
#macro SCRIBBLE_NULL_ELEMENT  global.__scribble_null_element
#macro SCRIBBLE_NULL_MODEL  global.__scribble_null_model
global.__scribble_default_element = scribble("");
global.__scribble_null_element = new __scribble_class_null_element();
global.__scribble_null_model = undefined;

#endregion