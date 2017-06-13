import EtdSaveWorkControl from 'etd_save_work_control'
import Editor from 'hyrax/editor'
export default class EtdEditor extends Editor {
    constructor(element) {
        super(element)
    }
    saveWorkControl() {
        console.log("Override the save work control?")
        new EtdSaveWorkControl(this.element.find("#form-progress"), this.adminSetWidget)
    }
}
