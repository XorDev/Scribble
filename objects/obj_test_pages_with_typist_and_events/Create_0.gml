scribble_font_set_default("fnt_test_0");
scribble_font_add_all();

typist = scribble_typist();
typist.in(0.1, 0);

scribble_typewriter_add_event("sdm", function(_element, _parameters)
{
    show_debug_message(_parameters);
});