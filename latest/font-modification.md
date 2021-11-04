### `scribble_font_set_style_family(regular, bold, italic, boldItalic)`

**Returns:** N/A (`undefined`)

|Name        |Datatype|Purpose                                      |
|------------|--------|---------------------------------------------|
|`regular`   |string  |Name of font to use for the regular style    |
|`bold`      |string  |Name of font to use for the bold style       |
|`italic`    |string  |Name of font to use for the italic style     |
|`boldItalic`|string  |Name of font to use for the bold-italic style|

Associates four fonts together for use with `[r]` `[b]` `[i]` `[bi]` font tags. Use `undefined` for any style you don't want to set a font for.

&nbsp;

&nbsp;


### `scribble_font_combine(destinationFontName, sourceFontName, preferSource)`

**Returns:** N/A (`undefined`)

|Name                 |Datatype|Purpose                                                                                                          |
|---------------------|--------|-----------------------------------------------------------------------------------------------------------------|
|`destinationFontName`|string  |Name of the font to add to, as a string                                                                          |
|`sourceFontName`     |string  |Name of the font to add from, as a string                                                                        |
|`preferSource`       |boolean |Set to `true` to overwrite destination data if the source and destination fonts have data for the same glyph|

The destination font will be converted to a dictionary look-up. This may slightly impact performance when caching text.

&nbsp;

&nbsp;


### `scribble_font_scale(fontName, xscale, yscale)`

**Returns:** N/A (`undefined`)

|Name      |Datatype|Purpose                                |
|----------|--------|---------------------------------------|
|`fontName`|string  |Name of the font to modify, as a string|
|`xscale`  |number  |Scaling factor for the x-axis          |
|`yscale`  |number  |Scaling factor for the y-axis          |

Scales every glyph in a font (including the space character) by the given factors. This directly modifies glyph properties for the font. Existing text elements that use the targetted font will not be immediately updated - you will need to recache those text elements. As a result, this function is intended to be used at the start of the game and not during operation.

&nbsp;

&nbsp;

### `scribble_glyph_set(fontName, character, property, value, [relative])`

**Returns:** N/A (`undefined`)

|Name        |Datatype|Purpose                      |
|------------|--------|-----------------------------|
|`fontName`  |string  |The target font, as a string |
|`character` |string  |Target character, as a string|
|`property`  |integer |Property to return, see below|
|`value`     |integer |The value to set (or add)    |
|`[relative]`|boolean |Whether to add the new value to the existing value, or to overwrite the existing value. Defaults to `false`, overwriting the existing value|

Fonts can often be tricky to render correctly, and this script allows you to change certain properties. Properties can be adjusted at any time, but existing and cached Scribble text elements will not be updated to match new properties.

Three properties are available:

|Macro                      | Property                                   |
|---------------------------|--------------------------------------------|
|`SCRIBBLE_GLYPH.WIDTH`     |Width of the glyph, in pixels. Changing this value will visually stretch the glyph|
|`SCRIBBLE_GLYPH.HEIGHT`    |Height of the glyph, in pixels. Changing this value will visually stretch the glyph|
|`SCRIBBLE_GLYPH.X_OFFSET`  |x-coordinate offset to draw the glyph       |
|`SCRIBBLE_GLYPH.Y_OFFSET`  |y-coordinate offset to draw the glyph       |
|`SCRIBBLE_GLYPH.SEPARATION`|Distance between this glyph's right edge and the left edge of the next glyph<br>**N.B.** This can be a negative value|

&nbsp;

&nbsp;

### `scribble_glyph_get(fontName, character, property)`

**Returns:** Real-value for the specified property

|Name       |Datatype|Purpose                      |
|-----------|--------|-----------------------------|
|`fontName` |string  |The target font, as a string |
|`character`|string  |Target character, as a string|
|`property` |integer |Property to return, see below|

Three properties are available:

|Macro                      | Property                                   |
|---------------------------|--------------------------------------------|
|`SCRIBBLE_GLYPH.WIDTH`     |Width of the glyph, in pixels               |
|`SCRIBBLE_GLYPH.HEIGHT`    |Height of the glyph, in pixels              |
|`SCRIBBLE_GLYPH.X_OFFSET`  |x-coordinate offset to draw the glyph       |
|`SCRIBBLE_GLYPH.Y_OFFSET`  |y-coordinate offset to draw the glyph       |
|`SCRIBBLE_GLYPH.SEPARATION`|Distance between this glyph's right edge and the left edge of the next glyph<br>**N.B.** This can be a negative value|

&nbsp;

&nbsp;

### `scribble_font_bake_outline(sourceFontName, newFontName, thickness, samples, color, smooth)`

**Returns:** N/A (`undefined`)

|Name            |Datatype|Purpose                                                                                                        |
|----------------|--------|---------------------------------------------------------------------------------------------------------------|
|`sourceFontName`|string  |Name of the source font, as a string                                                                           |
|`newFontName`   |string  |Name of the new font to create, as a string                                                                    |
|`thickness`     |integer |Number of layers to use to generate the outline e.g. a value of `2` will give a 2px outline                    |
|`samples`       |integer |Number of samples to use for the outline per layer                                                             |
|`outlineColor`  |integer |Colour of the outline                                                                                          |
|`smooth`        |boolean |Whether or not to interpolate the outline. Set to `false` for pixel fonts, set to `true` for anti-aliased fonts|

`scribble_bake_outline()` creates a new font using a source font. The source font is passed through the `shd_scribble_bake_outline` shader, character by character, using the parameters provided.

&nbsp;

&nbsp;

### `scribble_font_bake_shader(sourceFontName, newFontName, shader, leftPad, topPad, rightPad, bottomPad, separationDelta, smooth, [surfaceSize])`

**Returns:** N/A (`undefined`)

|Name             |Datatype|Purpose                                                                            |
|-----------------|--------|-----------------------------------------------------------------------------------|
|`sourceFontName` |string  |Name, as a string, of the font to use as a basis for the effect                    |
|`newFontName`    |string  |Name of the new font to create, as a string                                        |
|`shader`         |[shader](https://docs2.yoyogames.com/source/_build/2_interface/1_editors/shaders.html)   |Shader to use                                                                      |
|`emptyBorderSize`|integer |Border around the outside of every output glyph, in pixels. A value of 2 is typical|
|`leftPad`        |integer |Left padding around the outside of every glyph. Positive values give more space. e.g. For a shader that adds a border of 2px around the entire glyph, **all** padding arguments should be set to `2`|
|`topPad`         |integer |Top padding                                                                        |
|`rightPad`       |integer |Right padding                                                                      |
|`bottomPad`      |integer |Bottom padding                                                                     |
|`separationDelta`|integer |Change in every glyph's [`SCRIBBLE_GLYPH.SEPARATION`](scribble_set_glyph_property) value. For a shader that adds a border of 2px around the entire glyph, this value should be 4px|
|`smooth`         |boolean |Whether or not to interpolate the output texture. Set to `false` for pixel fonts, set to `true` for anti-aliased fonts|
|`[surfaceSize]`  |integer |Size of the surface to use. Defaults to 2048x2048                                  |

`scribble_bake_shader()` creates a new font using a source font. The source font is passed through the given shader, character by character, using the parameters provided.

&nbsp;

&nbsp;

### `scribble_font_has_character(fontName, character)`

**Returns:** Boolean, indicating whether the given character is found in the font

|Name       |Datatype|Purpose                           |
|-----------|--------|----------------------------------|
|`fontName` |string  |Name of the font to target        |
|`character`|string  |Character to test for, as a string|