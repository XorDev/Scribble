# `scribble()` Methods

&nbsp;

`scribble()` is the heart of Scribble and is responsible for managing the underlying systems.

When you call `scribble()`, the function searches Scribble's internal cache and will return the text element that matches the string you gave the function (and also matches the unique ID too, if you specified one). If the cache doesn't contain a matching string then a new text element is created and returned instead.

**Even small changes in a string may cause a new text element to be generated automatically.** Scribble is pretty fast, but you don't want to use it for text that changes rapidly (e.g. health points, money, or score) as this will cause Scribble to do a lot of work, potentially slowing down your game.

Each text element can be altered by calling methods, a new feature in [GMS2.3.0](https://www.yoyogames.com/blog/549/gamemaker-studio-2-3-new-gml-features). Most methods return the text element itself. This allows you to chain methods together, achieving a [fluent interface](https://en.wikipedia.org/wiki/Fluent_interface). Some methods are marked as "regenerator methods". Setting new, different values for a piece of text using a regenerator method will cause Scribble to regenerate the underlying vertex buffers. For the sake of performance, avoid frequently changing values for regenerator methods as this will cause performance problems.

Don't worry about clearing up after yourself when you draw text - Scribble automatically manages memory for you. If you *do* want to manually control how memory is used, please use the [`.flush()`](scribble-methods?id=flush) method and [`scribble_flush_everything()`](misc-functions?id=scribble_flush_everything). Please be aware that it is not possible to serialise/deserialise Scribble text elements for e.g. a save system.

&nbsp;

## `scribble([string], [uniqueID])`

**Returns:** A text element that contains the string (a struct, an instance of `__scribble_class_element`)

|Name        |Datatype      |Purpose               |
|------------|--------------|----------------------|
|`[string]`  |string        |String to draw        |
|`[uniqueID]`|string or real|ID to reference a specific unique occurrence of a text element. Defaults to [`SCRIBBLE_DEFAULT_UNIQUE_ID`](configuration)|

If no string is specified (i.e. the function used with arguments), this function will return a **unique** text element that contains no text data (even if no unique ID is given). The text in any text element, including empty ones, can be overwritten using the [`.overwrite()`](scribble-methods?id=overwritestring-regenerator) method.

Scribble allows for many kinds of inline formatting tags. Please read the [Text Formatting](text-formatting) article for more information.

?> Scribble text elements have **no publicly accessible variables**. Do not directly read or write variables, use the setter and getter methods provided instead.

&nbsp;

&nbsp;

&nbsp;

# The Methods

Text element methods are broken down into several categories. There's a lot here; feel free to swing by the [Discord server](https://discord.gg/8krYCqr) if you'd like some pointers on what to use and when. As noted above, **be careful when adjusting regenerator methods** as it's easy to cause to performance problems.

## Basics

### `.draw(x, y)`

**Returns**: N/A (`undefined`)

|Name|Datatype|Purpose                          |
|----|--------|---------------------------------|
|`x` |real    |x position in the room to draw at|
|`y` |real    |y position in the room to draw at|

Draws your text! This function will automatically build the required text model if required. For very large amounts of text this may cause a slight hiccup in your framerate - to avoid this, split your text into smaller pieces or manually call the [`.build()`](scribble-methods?id=buildfreeze) method during a loading screen etc.

&nbsp;

### `.starting_format(fontName, colour)` *regenerator*

**Returns**: The text element

|Name      |Datatype|Purpose                                                                                                                                 |
|----------|--------|----------------------------------------------------------------------------------------------------------------------------------------|
|`fontName`|string  |Name of the starting font, as a string. This is the font that is set when `[/]` or `[/font]` is used in a string                        |
|`colour`  |integer |Starting colour in the standard GameMaker 24-bit BGR format. This is the colour that is set when `[/]` or `[/color]` is used in a string|

Sets the starting font and text colour for your text. The values that are set with `.starting_format()` are applied if you use the [`[/] or [/f] or [/c]` command tags](text-formatting) to reset your text format.

&nbsp;

### `.align(halign, valign)` *regenerator*

**Returns**: The text element

|Name    |Datatype                                                                                                                  |Purpose                                                                                               |
|--------|--------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------|
|`halign`|[halign constant](https://manual.yoyogames.com/GameMaker_Language/GML_Reference/Drawing/Text/draw_set_halign.htm)|Starting horizontal alignment of **each line** of text. Accepts `fa_left`, `fa_right`, and `fa_center`|
|`valign`|[valign constant](https://manual.yoyogames.com/GameMaker_Language/GML_Reference/Drawing/Text/draw_set_valign.htm)|Starting vertical alignment of the **entire textbox**. Accepts `fa_top`, `fa_bottom`, and `fa_middle` |

Sets the starting horizontal and vertical alignment for your text. You can change alignment using in-line [command tags](Text-Formatting) as well, though do note there are some limitations when doing so.

&nbsp;

### `.blend(colour, alpha)`

**Returns**: The text element

|Name    |Datatype|Purpose                                                                         |
|--------|--------|--------------------------------------------------------------------------------|
|`colour`|integer |Blend colour used when drawing text, applied multiplicatively                   |
|`alpha` |real    |Alpha used when drawing text, 0 being fully transparent and 1 being fully opaque|

Sets the blend colour/alpha, which is applied at the end of the drawing pipeline. This is a little different to the interaction between [`draw_set_color()`](https://manual.yoyogames.com/GameMaker_Language/GML_Reference/Drawing/Colour_And_Alpha/draw_set_colour.htm) and [`draw_text()` functions](https://manual.yoyogames.com/GameMaker_Language/GML_Reference/Drawing/Text/Text.htm). Scribble's blend colour is instead similar to [`draw_sprite_ext()`](https://manual.yoyogames.com/GameMaker_Language/GML_Reference/Drawing/Sprites_And_Tiles/draw_sprite_ext.htm)'s behaviour: The blend colour/alpha is applied multiplicatively with the source colour, in this case the source colour is whatever colour has been set using formatting tags in the input text string.

&nbsp;

&nbsp;

&nbsp;

## Shape, Wrapping, and Positioning

### `.origin(x, y)`

**Returns**: The text element

|Name|Datatype|Purpose                                   |
|----|--------|------------------------------------------|
|`x` |real    |x-coordinate of the origin, in model space|
|`y` |real    |y-coordinate of the origin, in model space|

Sets the origin relative to the top-left corner of the text element. You can think of this similarly to a standard sprite's origin as set in the GameMaker IDE. Using this function with [`.get_width()`](scribble-methods?id=get_width) and [`.get_height()`](scribble-methods?id=get_height) will allow you to align the entire textbox as you see fit. Please note that this function may interact in unexpected ways with in-line alignment commands so some trial and error is necessary to get the effect you're looking for.

&nbsp;

### `.transform(xscale, yscale, angle)`

**Returns**: The text element

|Name    |Datatype|Purpose                           |
|--------|--------|----------------------------------|
|`xscale`|real    |x scale of the text element       |
|`yscale`|real    |y scale of the text element       |
|`angle` |real    |rotation angle of the text element|

Rotates and scales a text element relative to the origin (set by [`.origin()`](scribble-methods?id=originx-y)).

&nbsp;

### `.wrap(maxWidth, [maxHeight], [characterWrap])` *regenerator*

**Returns**: The text element

|Name             |Datatype|Purpose                                                                                                                                         |
|-----------------|--------|------------------------------------------------------------------------------------------------------------------------------------------------|
|`maxWidth`       |integer |Maximum width for the whole textbox. Use a negative number (the default) for no limit                                                           |
|`[maxHeight]`    |integer |Maximum height for the whole textbox. Use a negative number (the default) for no limit                                                          |
|`[characterWrap]`|boolean |Whether to wrap text per character (rather than per word). Defaults to `false`. This is useful for tight textboxes and some East Asian languages|

Instructs Scribble to fit text inside a box by automatically inserting line breaks and page breaks where necessary. Scribble's text wrapping operates in a very similar way to GameMaker's native [`draw_text_ext()`](https://manual.yoyogames.com/GameMaker_Language/GML_Reference/Drawing/Text/draw_text_ext.htm). If text exceeds the horizontal maximum width then text will be pushed onto the next line. If text exceeds the maximum height of the textbox then a new page will be created (see [`.page()`](scribble-methods?id=pagepage) and [`.get_page()`](scribble-methods?id=get_page)). Very long sequences of glyphs without spaces will be split across multiple lines.

&nbsp;

### `.fit_to_box(maxWidth, maxHeight, [characterWrap])` *regenerator*

**Returns**: The text element

|Name             |Datatype|Purpose                                                                                                                                              |
|-----------------|--------|-----------------------------------------------------------------------------------------------------------------------------------------------------|
|`maxWidth`       |integer |Maximum width for the whole textbox                                                                                                                  |
|`maxHeight`      |integer |Maximum height for the whole textbox                                                                                                                 |
|`[characterWrap]`|boolean |Whether to wrap text per character (rather than per word). Defaults to `false`. This is useful for very tight textboxes and some East Asian languages|

Fits text to a box by inserting line breaks and scaling text but **will not** insert any page breaks. Text will take up as much space as possible without starting a new page. The macro `SCRIBBLE_FIT_TO_BOX_ITERATIONS` controls how many iterations to perform (higher is slower but more accurate).

!> N.B. This function is very slow and should be used sparingly. It is recommended you manually cache text elements when using `.fit_to_box()`.

&nbsp;

### `.line_height(min, max)` *regenerator*

**Returns**: The text element

|Name |Datatype|Purpose                                                                                                                               |
|-----|--------|--------------------------------------------------------------------------------------------------------------------------------------|
|`min`|integer |Minimum line height for each line of text. Use a negative number (the default) for the height of a space character of the default font|
|`max`|integer |Maximum line height for each line of text. Use a negative number (the default) for no limit                                           |

Sets limits on the height of each line for the text element. This is useful when mixing and matching fonts that aren't necessarily perfectly sized to each other.

&nbsp;

### `.bezier(x1, y1, x2, y2, x3, y3, x4, y4)` *regenerator*

**Returns**: The text element

|Name|Datatype|Purpose                             |
|----|--------|------------------------------------|
|`x1`|real    |Parameter for the cubic Bézier curve|
|`y1`|real    |"                                   |
|`x2`|real    |"                                   |
|`y2`|real    |"                                   |
|`x3`|real    |"                                   |
|`y3`|real    |"                                   |
|`x4`|real    |"                                   |
|`y4`|real    |"                                   |

This function defines a [cubic Bézier curve](https://en.wikipedia.org/wiki/B%C3%A9zier_curve) to shape text to. The four x/y coordinate pairs provide a smooth curve that Scribble uses as a guide to position and rotate glyphs.

**The curve is positioned relative to the coordinate specified when calling** [`.draw()`](scribble-methods?id=drawx-y) **so that the first Bézier coordinate is at the draw coordinate**. This enables you to move a curve without re-adjusting the values set in `.bezier()` (which would regenerate the text element, likely causing performance problems).

If used in conjunction with [`.wrap()`](scribble-methods?id=wrapmaxwidth-maxheight-characterwrap-regenerator), the total length of the curve is used to wrap text horizontally and overrides the value specified in [`.wrap()`](scribble-methods?id=wrapmaxwidth-maxheight-characterwrap-regenerator). `.bezier()` will not work with `[fa_right]` or `[fa_center]` alignment. Instead, you should use `[pin_right]` and `[pin_center]`.

This function can also be executed with zero arguments (e.g. `scribble("text").bezier()`) to turn off the Bézier curve for this text element.

&nbsp;

&nbsp;

&nbsp;

## Pages

### `.page(page)`

**Returns**: The text element

|Name  |Datatype|Purpose                                          |
|------|--------|-------------------------------------------------|
|`page`|integer |Page to display, starting at 0 for the first page|

Changes which page Scribble is display for the text element. Pages are created when using the [`.wrap()` method](scribble-methods?id=wrapmaxwidth-maxheight-characterwrap-regenerator) or when inserting [`[/page] command tags`](text-formatting) into your input string. Pages are 0-indexed.

Please note that changing the page will reset any typewriter animations i.e. those started by [`.typewriter_in()`](scribble-methods?id=typewriter_inspeed-smoothness) and [`typewriter_out()`](scribble-methods?id=typewriter_outspeed-smoothness-backwards).

&nbsp;

### `.get_page()`

**Returns:** Integer, page that the text element is currently on, starting at `0` for the first page

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Returns which page Scribble is showing, as set by [`.page()`](scribble-methods?id=pagepage). Pages are 0-indexed; this function will return `0` for the first page.

&nbsp;

### `.get_pages()`

**Returns:** Integer, total number of pages for the text element

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Returns the total number of pages that this text element contains. In rare cases, this function can return 0.

&nbsp;

### `.on_last_page()`

**Returns:** Boolean, whether the current page is the last page for the text element

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Convenience function.

&nbsp;

&nbsp;

&nbsp;

## Typewriter

### `.typewriter_off()`

**Returns**: The text element

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Turns off the typewriter effect and displays all text. [Typewriter events](misc-functions?id=scribble_typewriter_add_eventname-function) will **not** be executed.

&nbsp;

### `.typewriter_reset()`

**Returns**: The text element

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Resets the position of the typewriter animation for the current page.

&nbsp;

### `.typewriter_in(speed, smoothness)`

**Returns**: The text element

|Name        |Datatype|Purpose                                                                                                                        |
|------------|--------|-------------------------------------------------------------------------------------------------------------------------------|
|`speed`     |real    |Amount of text to reveal per tick (1 tick is usually 1 frame). This is character or lines depending on the method defined above|
|`smoothness`|real    |How much text is visible during the fade. Higher numbers will allow more text to be visible as it fades in                     |

The `smoothness` argument offers some customisation for how text fades in. A high value will cause text to be smoothly faded in whereas a smoothness of `0` will cause text to instantly pop onto the screen. For advanced users, custom shader code can be easily combined with the `smoothness` value to animate text in unique ways as it fades in.

[Events](misc-functions?id=scribble_typewriter_add_eventname-function) (in-line functions) will be executed as text fades in. This is a powerful tool and can be used to achieve many things, including triggering sound effects, changing character portraits, starting movement of instances, starting weather effects, giving the player items, and so on.

&nbsp;

### `.typewriter_out(speed, smoothness, [backwards])`

**Returns**: The text element

|Name         |Datatype|Purpose                                                                                                                        |
|-------------|--------|-------------------------------------------------------------------------------------------------------------------------------|
|`speed`      |real    |Amount of text to reveal per tick (1 tick is usually 1 frame). This is character or lines depending on the method defined above|
|`smoothness` |real    |How much text is visible during the fade. Higher numbers will allow more text to be visible as it fades out                    |
|`[backwards]`|boolean |Whether to animate the typewriter backwards. Defaults to `false`                                                               |

The `smoothness` argument offers some customisation for how text fades out. A high value will cause text to be smoothly faded out whereas a smoothness of `0` will cause text to instantly pop onto the screen. For advanced users, custom shader code can be easily combined with the `smoothness` value to animate text in unique ways as it fades out.

[Events](misc-functions?id=scribble_typewriter_add_eventname-function) will **not** be executed as text fades out.

&nbsp;

### `.typewriter_skip()`

**Returns**: The text element

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

&nbsp;

### `.get_typewriter_pos()`

**Returns**: Real, the position of the typewriter "head", corresponding to the most recent revealed glyph

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

This method will return a decimal value if the speed is a decimal value too.

&nbsp;

### `.typewriter_ease(easeMethod, dx, dy, xscale, yscale, rotation, alphaDuration)`

**Returns**: The text element

|Name           |Datatype|Purpose                                                           |
|---------------|--------|------------------------------------------------------------------|
|`easeMethod`   |integer |A member of the `SCRIBBLE_EASE` enum. See below                   |
|`dx`           |real    |Starting x-coordinate of the glyph, relative to its final position|
|`dy`           |real    |Starting y-coordinate of the glyph, relative to its final position|
|`xscale`       |real    |Starting x-scale of the glyph, relative to its final scale        |
|`yscale`       |real    |Starting y-scale of the glyph, relative to its final scale        |
|`rotation`     |real    |Starting rotation of the glyph, relative to its final rotation    |
|`alphaDuration`|real    |Value from `0` to `1` (inclusive). See below                      |

The `alphaDuration` argument controls how glyphs fade in using alpha blending. A value of `0` will cause the glyph to "pop" into view with no fading, a value of `1` will cause the glyph to fade into view smoothly such that it reaches 100% alpha at the very end of the typewriter animation for the glyph.

**N.B.** Alpha fading is always linear and is not affected by the easing method chosen.

Scribble offers the following easing functions for typewriter behaviour. These are implemented using methods found in the widely used [easings.net](https://easings.net/) library.

|`SCRIBBLE_EASE` members|
|-----------------------|
|`.NONE`                |
|`.LINEAR`              |
|`.QUAD`                |
|`.CUBIC`               |
|`.QUART`               |
|`.QUINT`               |
|`.SINE`                |
|`.EXPO`                |
|`.CIRC`                |
|`.BACK`                |
|`.ELASTIC`             |
|`.BOUNCE`              |

&nbsp;

### `.get_typewriter_state()`

**Returns:** Real value from 0 to 2 (inclusive) that represents what proportion of text on the current page is visible

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

The value returned by this function is as follows:

|Value         |Visibility                                                                                                      |
|--------------|----------------------------------------------------------------------------------------------------------------|
|`= 0`         |No text is visible                                                                                              |
|`> 0`<br>`< 1`|Text is fading in. This value is the proportion of text that is visible<br>e.g. `0.4` is 40% visibility         |
|`= 1`         |Text is fully visible and the fade in animation has finished                                                    |
|`> 1`<br>`< 2`|Text is fading out. 2 minus this value is the proportion of text that is visible<br>e.g. `1.6` is 40% visibility|
|`= 2`         |No text is visible and the fade out animation has finished                                                      |

If no typewriter animation has been started, this function will return `1`.

&nbsp;

### `.typewriter_pause()`

**Returns**: The text element

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Pauses the typewriter effect.

&nbsp;

### `.typewriter_unpause()`

**Returns**: The text element

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Unpauses the typewriter effect. This is helpful when combined with the [`[pause]` command tag](text-formatting) and [`.get_typewriter_paused()`](scribble-methods?id=get_typewriter_paused).

&nbsp;

### `.get_typewriter_paused()`

**Returns:** Boolean, whether the text element is currently paused due to encountering `[pause]` tag when typing out text

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

&nbsp;

### `.typewriter_sound(soundArray, overlap, pitchMin, pitchMax)`

**Returns**: The text element

|Name        |Datatype                                                                                      |Purpose                                                                                                             |
|------------|----------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------|
|`soundArray`|array of [sounds](https://manual.yoyogames.com/The_Asset_Editors/Sounds.htm)|Array of audio assets that can be used for playback                                                                 |
|`overlap`   |real                                                                                          |Amount of overlap between sound effect playback, in milliseconds                                                    |
|`pitchMin`  |real                                                                                          |Minimum pitch to play a sound at. A value of `1.0` gives no change in pitch, a value of `0.5` halves the pitch etc. |
|`pitchMax`  |real                                                                                          |Maximum pitch to play a sound at. A value of `1.0` gives no change in pitch, a value of `2.0` doubles the pitch etc.|

It's quite common in games with typewriter-style text animations to have a "mumble" or "gibberish" sound effect that plays whilst text is being revealed. This function allows you to define an array of sound effects that will be randomly played as text is revealed. The pitch of these sounds can be randomly modulated as well by selecting `pitchMin` and `pitchMax` values.

Setting the `overlap` value to `0` will ensure that sound effects never overlap at all, which is generally what's desirable, but it can sound a bit stilted and unnatural. By setting the `overlap` argument to a number above `0`, sound effects will be played with a little bit of overlap which improves the effect considerably. A value around 30ms usually sounds ok. The `overlap` argument can be set to a value less than 0 if you'd like more space between sound effects.

&nbsp;

### `.typewriter_sound_per_char(soundArray, pitchMin, pitchMax)`

**Returns**: The text element

|Name        |Datatype                                                                                      |Purpose                                                                                                             |
|------------|----------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------|
|`soundArray`|array of [sounds](https://manual.yoyogames.com/The_Asset_Editors/Sounds.htm)|Array of audio assets that can be used for playback                                                                 |
|`pitchMin`  |real                                                                                          |Minimum pitch to play a sound at. A value of `1.0` gives no change in pitch, a value of `0.5` halves the pitch etc. |
|`pitchMax`  |real                                                                                          |Maximum pitch to play a sound at. A value of `1.0` gives no change in pitch, a value of `2.0` doubles the pitch etc.|

It's quite common in games with typewriter-style text animations to have a sound effect that plays as text shows up. This function allows you to define an array of sound effects that will be randomly played as **each character** is revealed. The pitch of these sounds can be randomly modulated as well by selecting `pitchMin` and `pitchMax` values.

&nbsp;

### `.typewriter_function(function)`

**Returns**: The text element

|Name      |Datatype|Purpose|
|----------|--------|-------|
|`function`|function|       |

`.typewriter_function()` allows you to define a function that will be executed once per character as that character is revealed. The function is given two arguments: the text element that triggered the callback, and the position of the character that was just revealed.

&nbsp;

&nbsp;

&nbsp;

## Getters

### `.get_bbox([x], [y], [leftPad], [topPad], [rightPad], [bottomPad])`

**Returns:** Struct containing the positions of the bounding box for a text element

|Name         |Datatype|Purpose                                                                                            |
|-------------|--------|---------------------------------------------------------------------------------------------------|
|`[x]`        |real    |x position in the room. Defaults to 0                                                              |
|`[y]`        |real    |y position in the room. Defaults to 0                                                              |
|`[leftPad]`  |real    |Extra space on the left-hand side of the textbox. Positive values create more space. Defaults to 0 |
|`[topPad]`   |real    |Extra space on the top of the textbox. Positive values create more space. Defaults to 0            |
|`[rightPad]` |real    |Extra space on the right-hand side of the textbox. Positive values create more space. Defaults to 0|
|`[bottomPad]`|real    |Extra space on the bottom of the textbox. Positive values create more space. Defaults to 0         |

The struct returned by `.get_bbox()` contains the following member variables:

|Variable        |Purpose                                |
|----------------|---------------------------------------|
|**Axis-aligned**|                                       |
|`left`          |Axis-aligned lefthand boundary         |
|`top`           |Axis-aligned top boundary              |
|`right`         |Axis-aligned righthand boundary        |
|`bottom`        |Axis-aligned bottom boundary           |
|`width`         |Axis-aligned width of the bounding box |
|`height`        |Axis-aligned height of the bounding box|
|**Oriented**    |                                       |
|`x0`            |x position of the top-left corner      |
|`y0`            |y position of the top-left corner      |
|`x1`            |x position of the top-right corner     |
|`y1`            |y position of the top-right corner     |
|`x2`            |x position of the bottom-left corner   |
|`y2`            |y position of the bottom-left corner   |
|`x3`            |x position of the bottom-right corner  |
|`y3`            |y position of the bottom-right corner  |

&nbsp;

### `.get_width()`

**Returns:** Real, width of the text element in pixels (ignoring rotation and scaling)

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Returns the raw width of the text element. This will **not** take into account rotation or scaling - this function returns the width value that Scribble uses internally.

&nbsp;

### `.get_height()`

**Returns:** Real, height of the text element in pixels (ignoring rotation and scaling)

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Returns the raw height of the text element. This will **not** take into account rotation or scaling - this function returns the height value that Scribble uses internally.

&nbsp;

### `.get_wrapped()`

**Returns:** Boolean, whether the text has wrapped onto a new line using the [`.wrap()` feature](scribble-methods?id=wrapmaxwidth-maxheight-characterwrap-regenerator)

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Will return `true` only if the [`.wrap()` feature](scribble-methods?id=wrapmaxwidth-maxheight-characterwrap-regenerator) is used. Manual newlines (`\n`) included in the input string will **not** cause this function to return `true`.

&nbsp;

### `.get_line_count([page])`

**Returns:** Integer, how many lines of text are on the given page

|Name    |Datatype|Purpose                                                                                  |
|--------|--------|-----------------------------------------------------------------------------------------|
|`[page]`|Integer |Page to retrieve the number of lines for. Defaults to the current page that's being shown|

&nbsp;

&nbsp;

&nbsp;

## Animation

### `.animation_tick_speed(tickSpeed)`

**Returns**: The text element

|Name       |Datatype|Purpose                                                                                                       |
|-----------|--------|--------------------------------------------------------------------------------------------------------------|
|`tickSpeed`|real    |"Scaling factor" for animation ticks. A value of `2` doubles the speed, a value of `0.5` halves the speed etc.|

This function controls the animation speed of all animation effects. It, however, does **not** alter the speed of the typewriter.

&nbsp;

### `.animation_sync(sourceElement)`

**Returns**: The text element

|Name           |Datatype    |Purpose                                             |
|---------------|------------|----------------------------------------------------|
|`sourceElement`|text element|Source text element to copy animation state **from**|

Syncing a text element to another will overwrite the current values. Be careful how you sync your text elements! Animation state is updated when a text element is drawn so make sure to sync your text element once every frame/step before the source text element is drawn.

When copying the animation state, the animation time and the animation tick speed ([`.animation_tick_speed()`](scribble-methods?id=animation_tick_speedtickspeed)) will be copied. Animation appearance properties themselves won't be copied. To share animation behaviours between elements, please use templates ([`.template()`](scribble()-Methods?id=templatefunction-executeonlyonchange)).

&nbsp;

### `.animation_wave(size, frequency, speed)`

**Returns**: The text element

|Name       |Datatype|Purpose                                                                                             |
|-----------|--------|----------------------------------------------------------------------------------------------------|
|`size`     |real    |Maximum pixel offset of the animation                                                               |
|`frequency`|real    |Frequency of the animation. Larger values will create more horizontally frequent "humps" in the text|
|`speed`    |real    |Speed of the animation                                                                              |

This function controls behaviour of the `[wave]` effect across all uses in the text element.

&nbsp;

### `.animation_shake(size, speed)`

**Returns**: The text element

|Name       |Datatype|Purpose                                                          |
|-----------|--------|-----------------------------------------------------------------|
|`size`     |real    |Maximum pixel offset of the animation                            |
|`speed`    |real    |Speed of the animation. Larger numbers cause text to shake faster|

This function controls behaviour of the `[shake]` effect across all uses in the text element.

&nbsp;

### `.animation_rainbow(weight, speed)`

**Returns**: The text element

|Name    |Datatype|Purpose                                                                                                                   |
|--------|--------|--------------------------------------------------------------------------------------------------------------------------|
|`weight`|real    |Blend weight of the rainbow colouring. A value of 0 will not apply the effect, a value of 1 will blend with 100% weighting|
|`speed` |real    |Cycling speed of the animation. Larger numbers scroll faster                                                              |

This function controls behaviour of the `[rainbow]` effect across all uses in the text element.

&nbsp;

### `.animation_wobble(angle, frequency)`

**Returns**: The text element

|Name       |Datatype|Purpose                                                              |
|-----------|--------|---------------------------------------------------------------------|
|`angle`    |real    |Maximum angular offset of the animation                              |
|`frequency`|real    |Speed of the animation. Larger numbers cause text to oscillate faster|

This function controls behaviour of the `[wobble]` effect across all uses in the text element.

&nbsp;

### `.animation_pulse(scale, speed)`

**Returns**: The text element

|Name   |Datatype|Purpose                                                                        |
|-------|--------|-------------------------------------------------------------------------------|
|`scale`|real    |Maximum scale of the animation                                                 |
|`speed`|real    |Speed of the animation. Larger values will cause text to shrink and grow faster|

This function controls behaviour of the `[pulse]` effect across all uses in the text element.

&nbsp;

### `.animation_wheel(size, frequency, speed)`

**Returns**: The text element

|Name       |Datatype|Purpose                                                                  |
|-----------|--------|-------------------------------------------------------------------------|
|`size`     |real    |Maximum pixel offset of the animation                                    |
|`frequency`|real    |Frequency of the animation. Larger values will create more chaotic motion|
|`speed`    |real    |Speed of the animation                                                   |

This function controls behaviour of the `[wheel]` effect across all uses in the text element.

&nbsp;

### `.animation_cycle(speed, saturation, value)`

**Returns**: The text element

|Name        |Datatype|Purpose                                                                                                                                                                                                                                                             |
|------------|--------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|`speed`     |real    |Speed of the animation. Larger values will cause the colour to cycle faster                                                                                                                                                                                         |
|`saturation`|integer |Saturation of colours generated by the animation. Values from 0 to 255 (inclusive) are accepted, much like GM's [`make_color_hsv()`](https://manual.yoyogames.com/#t=GameMaker_Language%2FGML_Reference%2FDrawing%2FColour_And_Alpha%2Fmake_colour_hsv.htm)         |
|`value`     |integer |Value ("lightness") of colours generated by the animation. Values from 0 to 255 (inclusive) are accepted, much like GM's [`make_color_hsv()`](https://manual.yoyogames.com/#t=GameMaker_Language%2FGML_Reference%2FDrawing%2FColour_And_Alpha%2Fmake_colour_hsv.htm)|

This function controls behaviour of the `[cycle]` effect across all uses in the text element.

&nbsp;

### `.animation_jitter(minScale, maxScale, speed)`

**Returns**: The text element

|Name      |Datatype|Purpose                                                          |
|----------|--------|-----------------------------------------------------------------|
|`minScale`|real    |Minimum scale offset of the animation                            |
|`maxScale`|real    |Maximum scale offset of the animation                            |
|`speed`   |real    |Speed of the animation. Larger numbers cause text to shake faster|

This function controls behaviour of the `[jitter]` effect across all uses in the text element.

&nbsp;

### `.animation_blink(onDuration, offDuration, timeOffset)`

**Returns**: The text element

|Name         |Datatype|Purpose                                         |
|-------------|--------|------------------------------------------------|
|`onDuration` |real    |Number of ticks that blinking text is shown for |
|`offDuration`|real    |Number of ticks that blinking text is hidden for|
|`timeOffset` |real    |Time offset for calculating the blink state     |

This function controls behaviour of the `[blink]` effect across all uses in the text element.

&nbsp;

&nbsp;

&nbsp;

## MSDF

!> MSDF fonts require special considerations. Please read [the MSDF article](msdf-fonts) for more information.

### `.msdf_shadow(colour, alpha, xoffset, yoffset)`

**Returns**: The text element

|Name     |Datatype|Purpose                                                                    |
|---------|--------|---------------------------------------------------------------------------|
|`colour` |integer |The colour of the shadow, as a standard GameMaker 24-bit BGR format        |
|`alpha`  |real    |Opacity of the shadow, `0.0` being transparent and `1.0` being fully opaque|
|`xoffset`|real    |x-coordinate of the shadow, relative to the parent glyph                   |
|`yoffset`|real    |y-coordinate of the shadow, relative to the parent glyph                   |

Sets the colour, alpha, and offset for a procedural MSDF shadow. Setting the alpha to `0` will prevent the shadow from being drawn at all. If you find that your shadow(s) are being clipped or cut off when using large offset values, [regenerate your MSDF fonts](msdf-fonts) using a larger `pxrange`.

&nbsp;

### `.msdf_border(colour, thickness)`

**Returns**: The text element

|Name       |Datatype|Purpose                                                                |
|-----------|--------|-----------------------------------------------------------------------|
|`colour`   |integer |Colour of the glyph's border, as a standard GameMaker 24-bit BGR format|
|`thickness`|real    |Thickness of the border, in pixels                                     |

Sets the colour and thickness for a procedural MSDF border. Setting the thickness to `0` will prevent the border from being drawn at all. If you find that your glyphs have filled (or partially filled) backgrounds, [regenerate your MSDF fonts](msdf-fonts) using a larger `pxrange`.

&nbsp;

### `.msdf_feather(thickness)`

**Returns**: The text element

|Name       |Datatype|Purpose                             |
|-----------|--------|------------------------------------|
|`thickness`|real    |Feather thickness, in pixels        |

Changes the softness/hardness of the MSDF font outline. You may find you have to fiddle with this number to correct for screen scaling but, normally, this feature will not be needed. The feather thickness defaults to `1.0`.

&nbsp;

&nbsp;

&nbsp;

## Cache Management

### `.build(freeze)`

**Returns**: N/A (`undefined`)

|Name    |Datatype|Purpose                                   |
|--------|--------|------------------------------------------|
|`freeze`|boolean |Whether to freeze generated vertex buffers|

Forces Scribble to build the text model for this text element. You should call this function if you're pre-caching text elements e.g. during a loading screen. Freezing vertex buffers will speed up rendering considerably but has a large up-front cost (Scribble generally defaults to **not** freezing vertex buffers to prevent hiccups when rendering text).

As this function returns `undefined`, the intended use of this function is:

```
///Create
element = scribble("Example test").wrap(200); //Create a new text element, and wrap it to maximum 200px wide
element.build(true); //Now build the text element

///Draw
element.draw(x, y);
```

&nbsp;

### `.flush()`

**Returns**: N/A (`undefined`)

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Forces Scribble to remove this text element from the internal cache, invalidating the text element. If you have manually cached a reference to a flushed text element, that text element will no longer be able to be drawn. Given that Scribble actively garbage collects used memory it is uncommon that you'd want to ever use this function, but if you want to tightly manage your memory, this function is available.

&nbsp;

&nbsp;

&nbsp;

## Miscellaneous

### `.events_get(position, [page])`

**Returns**: An array containing structs that describe typewrite events for the given character

|Name      |Datatype|Purpose                                                                    |
|----------|--------|---------------------------------------------------------------------------|
|`position`|integer |Character to get events for. See below for more details                    |
|`[page]`  |integer |The page to get events for. If not specified, the current page will be used|

To match GameMaker's native string behaviour for functions such as `string_copy()`, character positions are 1-indexed such that the character at position 1 in the string `"abc"` is `a`. Events are indexed such that an event placed immediately before a character has an index one less than the character. Events placed immediately after a character have an index equal to the character e.g. `"[event index 0]X[event index 1]"`.

The returned array contains structs that themselves contain the following member variables:
|Member Variable|Datatype        |Purpose                                                                                                  |
|---------------|----------------|---------------------------------------------------------------------------------------------------------|
|`.position`    |integer         |The character position for this event. This should (!) be the same as the index provided to get the event|
|`.name`        |string          |Name of the event e.g. `[ping, Hello!]` will set `.name` to `"ping"`                                     |
|`.data`        |array of strings|Contains the arguments provided for the event. Arguments will always be returned as strings e.g. `[move to, 20, -5]` will set `.data` to `["20", "-5"]`|

&nbsp;

### `.template(function, [executeOnlyOnChange])`

**Returns**: The text element

|Name                   |Datatype                       |Purpose                                                                             |
|-----------------------|-------------------------------|------------------------------------------------------------------------------------|
|`function`             |function, or array of functions|Function to execute to set Scribble behaviour for this text element                 |
|`[executeOnlyOnChange]`|boolean                        |Whether to only execute the template function if it has changed. Defaults to `false`|

Executes a function in the scope of this text element. If that function contains method calls then the methods will be applied to this text element. For example:

```
function example_template()
{
    wrap(150);
    blend(c_red, 1);
}

scribble("This text is red and will be wrapped inside a box that's 150px wide.").template(example_template).draw(10, 10);
```

&nbsp;

### `.overwrite(string)` *regenerator*

**Returns**: The text element

|Name    |Datatype|Purpose                                     |
|--------|--------|--------------------------------------------|
|`string`|string  |New string to display using the text element|

Replaces the string in an existing text element whilst maintaining the animation, typewriter, and page state. This function may cause a recaching of the underlying text model so should be used sparingly.

&nbsp;

### `.fog(colour, alpha)`

**Returns**: The text element

|Name    |Datatype|Purpose                                                |
|--------|--------|-------------------------------------------------------|
|`colour`|integer |Fog colour, in the standard GameMaker 24-bit BGR format|
|`alpha` |real    |Blending factor for the fog, from 0 to 1               |

Forces the colour of all text (and sprites) to change to the given specified colour.

&nbsp;

### `.ignore_command_tags(state)` *regenerator*

**Returns**: The text element

|Name   |Datatype|Purpose|
|-------|--------|-------|
|`state`|boolean |       |

Directs Scribble to ignore all [command tags](text-formatting) in the string.