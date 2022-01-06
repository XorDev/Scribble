# FAQ

---

### What platforms does Scribble support?

Everything! ...apart from HTML5 due to [bugs in GameMaker's JavaScript runner](https://github.com/JujuAdams/scribble/issues/18). You might run into edge cases on platforms that I don't regularly test; please [report any bugs](https://github.com/JujuAdams/Scribble/issues) if and when you find them.

&nbsp;

### What kinds of fonts can Scribble draw?

Anything that GameMaker natively supports as a font resource, including spritefonts. Scribble additionally supports [MSDF fonts](msdf-fonts) which are very useful for mobile games or any game which might have a wide variety of text sizes. Scribble unfortunately doesn't (yet) support fonts added via `font_add()`.

&nbsp;

### Does Scribble work with GMLive?

Scribble was confirmed to work with [GMLive](https://yellowafterlife.itch.io/gamemaker-live) using version 7.1.2. It's highly likely that future and past versions work with [GMLive](https://yellowafterlife.itch.io/gamemaker-live) as well.

&nbsp;

### How is Scribble licensed? Can I use it for commercial projects?

[Scribble is released under the MIT license](https://github.com/JujuAdams/Scribble/blob/master/LICENSE). This means you can use it for whatever purpose you want, including commercial projects. It'd mean a lot to me if you'd drop my name in your credits (Juju Adams) and/or say thanks, but you're under no obligation to do so.

&nbsp;

### What games are using Scribble?

Scribble is being used in [Shovel Knight Pocket Dungeon](https://www.yachtclubgames.com/games/shovel-knight-pocket-dungeon), [Wally and the Fantastic Predators](https://store.steampowered.com/app/1077450/Wally_and_the_FANTASTIC_PREDATORS/), [Stargrove](https://twitter.com/FauxOperative), [Wizarducks](https://twitter.com/wizarducks1) and [many others](https://www.youtube.com/watch?v=KvakyfLhvfU). Scribble gets a lot of real world testing!

&nbsp;

### I think you're missing a useful feature and I'd like you to implement it!

Great! Please make a [feature request](https://github.com/JujuAdams/scribble/issues). Feature requests make Scribble a more fun tool to use and gives me something to think about when I'm bored on public transport.

&nbsp;

### I found a bug, and it both scares and mildly annoys me. What is the best way to get the problem solved?

Please make a [bug report](https://github.com/JujuAdams/scribble/issues). Juju checks GitHub every day and bug fixes usually go out a couple days after that. You can also grab me on the [Discord server](https://discord.gg/8krYCqr), but that's not a replacement for a nice clear bug report.

&nbsp;

### Why does Scribble glitch my fonts sometimes and how do I fix it?

GameMaker pre-renders fonts, creating a .yy metadata file and a .png texture (sort of like a mini texture page just for font glyphs). Scribble needs both files to render fonts. GameMaker automatically gives us access to the font texture but it doesn't easily allow us to read the contents of the .yy files. This is why [you need to add the .yy file to your project's Included Files](setting-up) before using Scribble.

Whenever you change the font's size or typeface etc., GameMaker will re-render the font creating a new .yy file and a new .png file. **The new .yy file will not match the old .yy file that we manually added to our Included Files.** As a result, our metadata doesn't match the new font texture and we get garbled, messy text instead.

The fix is simple: *Update your .yy file whenever you see glitched text!*

&nbsp;

### I'm using colour blending with an outlined font and the blend colour is affecting the outline too. What's going on?

[`scribble_font_bake_outline()`](font-modification?id=scribble_font_bake_outlinesourcefontname-newfontname-thickness-samples-color-smooth) works by pre-rendering the font to a surface using a simple outline shader. The outline and the font itself are inseparably combined. When these outlined glyphs are drawn with some sort of blending applied, Scribble has no way to separate out what's an outline and what's the main body of the glyph. This means the blend necessarily has to apply to both the outline and the glyph itself.

&nbsp;

### How do I fix weird spacing on the left hand side when my font wraps to the next line?

I've not yet found a really good solution for this bug, but I did make a workaround. Set the `SCRIBBLE_SPRITEFONT_ALIGN_GLYPHS_LEFT` macro to `true` and this should solve your problems. If it doesn't, please file a [bug report](https://github.com/JujuAdams/scribble/issues) and/or yell at me on the [Discord server](https://discord.gg/8krYCqr).

&nbsp;

### Scribble creates little hangs in my game when I draw lots and lots of text and it's making me sad :(

Efficient text parsing is hard work in any language, but GML makes it even more strenuous. Scribble is about as fast as I can make it. The best thing to do to work around the text caching speed is to pre-cache large amount of text by using the [`.build()`](scribble-methods?id=buildfreeze) method. I recommend pre-caching text during a loading screen or other such pause in gameplay.

&nbsp;

### How do I adjust the height of a line break?

All line breaks in Scribble - either forced line breaks using `\n` or natural line breaks caused by [wrapping text](scribble-methods?id=wrapmaxwidth-maxheight-characterwrap-regenerator) - derive their height from the "height" of the space character in the font currently being used. You can adjust the height of a line break by using [`scribble_glyph_set()`](font-modification?id=scribble_glyph_setfontname-character-property-value-relative) and targeting the space character (`" "`).

If you'd only like to adjust the line spacing for a single text element, use the [`.line_height()`](scribble-methods?id=line_heightmin-max-regenerator) method instead.

&nbsp; 

### I'm coming from version 6 and `scribble_init()` is gone. Where do I set my font directory now?

You can set your font directory (relative to Included Files) by modifying the `SCRIBBLE_INCLUDED_FILES_SUBDIRECTORY` macro.

&nbsp; 

### Can I send you donations? Are you going to start a Patreon?

Thank you for wanting to show your appreciation - it really does mean a lot to me personally - but I'm fortunate enough to have a stable income from gamedev. I'm not looking to join Patreon as a creator at this moment in time. If you'd like to support my work then drop me a credit in your game and/or gimme a shout-out on the social media platform of your choice.