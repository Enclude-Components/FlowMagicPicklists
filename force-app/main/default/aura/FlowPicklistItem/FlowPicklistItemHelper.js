({
    PARENT_ID : null,
    selectOption : function(component) {
        const selected    = component.get('v.selected');
        const variant     = component.get('v.variant');
        const objectName  = component.get('v.objectName');
        const fieldName   = component.get('v.fieldName');
        const optionValue = component.get('v.optionValue');

        //const elem = document.getElementById(objectName + '_' + fieldName + '_' + optionValue);
        const elem = document.getElementById(optionValue);

        // TODO: refactor
        if (selected && variant !== 'Link') {
            if (elem && !elem.checked) {
                elem.checked = true;
            }
        } 

        if (!selected) {
            if (variant === 'Link') {
                if (elem) {
                    elem.blur();
                }
            } else {
                if (elem && elem.checked) {
                    elem.checked = false;
                }
            }
        } 
    }
})