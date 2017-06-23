import EtdSaveWorkControl from 'etd_save_work_control'
import Editor from 'hyrax/editor'
export default class EtdEditor extends Editor {
    constructor(element) {
        super(element)
    }
    saveWorkControl() {
        new EtdSaveWorkControl(this.element.find("#form-progress"), this.adminSetWidget)
    }
}
