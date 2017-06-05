import { Editor } from 'hyrax/editor';
import EtdSaveWorkControl from 'etd_save_work_control'


export default class extends Editor {
  constructor(element) {
    super(element);
    this.element = element
    this.adminSetWidget = new AdminSetWidget(element.find('select[id$="_admin_set_id"]'))
    this.sharingTabElement = $('#tab-share')

    this.sharingTab()
    this.relationshipsControl()
    this.saveWorkControl()
    this.saveWorkFixed()
  }

  // Display the sharing tab if they select an admin set that permits sharing
  sharingTab() {
    if(this.adminSetWidget && !this.adminSetWidget.isEmpty()) {
      this.adminSetWidget.on('change', () => this.sharingTabVisiblity(this.adminSetWidget.isSharing()))
      this.sharingTabVisiblity(this.adminSetWidget.isSharing())
    }
  }

  sharingTabVisiblity(visible) {
      if (visible)
         this.sharingTabElement.removeClass('hidden')
      else
         this.sharingTabElement.addClass('hidden')
  }

  relationshipsControl() {
      new RelationshipsControl(this.element.find('[data-behavior="child-relationships"]'),
                               'work_members_attributes',
                               'tmpl-child-work')
  }

  saveWorkControl() {
      new EtdSaveWorkControl(this.element.find("#form-progress"), this.adminSetWidget)
  }

  saveWorkFixed() {
      // Setting test to false to skip native and go right to polyfill
      FixedSticky.tests.sticky = false
      this.element.find('#savewidget').fixedsticky()
  }
}
