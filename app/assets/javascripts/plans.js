function show_plan(editor_id, show_info) {
    var editor;

    if (editor_id.charAt(0) === '#') {
	editor = ace.edit(editor_id.substr(1));
    } else {
	editor = ace.edit(editor_id);
    }
    var form_field = $(show_info);

    editor.setTheme("ace/theme/eclipse");
    editor.setOption('fontSize', '13pt');
    editor.setOption('vScrollBarAlwaysVisible', true);
    editor.getSession().setUseWrapMode(true);

    if (editor.getSession().getValue().length) {
	editor.setValue(
	    JSON.stringify(
		JSON.parse(editor.getSession().getValue()),
		null,
		2
	    )
	);
	editor.session.setMode("ace/mode/json");
	$(editor_id).show();
	form_field.val(editor.getSession().getValue());
    }
    return editor;
}
