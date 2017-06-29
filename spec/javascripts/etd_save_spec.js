//= require tinymce
//= require tinymce-jquery

describe("EtdSaveWorkControl", function() {
  var EtdSaveWorkControl = require('etd_save_work_control');
  var AdminSetWidget = require('hyrax/editor/admin_set_widget');
  var ETDRequiredFields = require('required_fields')

  describe("validateAboutMeAndProgram", function() {
    var mockCheckbox = {
      check: function() { },
      uncheck: function() { },
    };

    beforeEach(function() {
      loadFixtures('work_form.html');
      var fixture = setFixtures('<form id="edit_generic_work">' +
        '<select><option></option></select>' +
        '<aside id="form-progress"><ul><li id="required-about-me"></ul>' +
        '<input type="checkbox" name="agreement" id="agreement" value="1" required="required" checked="checked" />' +
        '<input type="submit"></aside></form>');
      admin_set = new AdminSetWidget(fixture.find('select'))
      target = new EtdSaveWorkControl($('#form-progress'), admin_set);

      target.requiredMeAndMyProgram = mockCheckbox;
      spyOn(mockCheckbox, 'check').and.stub();
      spyOn(mockCheckbox, 'uncheck').and.stub();
    });

    describe("activate", function() {
      var target;
      beforeEach(function() {
        target = new EtdSaveWorkControl($('#form-progress'));
        target.activate()
      });

      it("is complete", function() {
        expect(target.requiredAboutMeFields).toBeDefined();
        // expect(target.uploads).toBeDefined();
        // expect(target.depositAgreement).toBeDefined();
        expect(target.requiredMeAndMyProgram).toBeDefined();
        // expect(target.requiredFiles).toBeDefined();
        // expect(target.saveButton).toBeDisabled();
      });
    });

    describe("when the about-me form changes", function(){
      var mockAboutMeFields = null;

      beforeEach(function() {
        mockAboutMeFields = {
          reload: function() { },
          areComplete: true
        };
        target.requiredAboutMeFields = mockAboutMeFields;
        spyOn(mockAboutMeFields,'reload');
        spyOn(target, 'formStateChanged').and.callThrough();
        spyOn(target, 'isValid').and.callThrough();
        spyOn(target, 'validateMeAndMyProgram');
        target.aboutMeFormChanged();
      });

      it('it reloads the dom elements and re-validates the form', function(){
        expect(mockAboutMeFields.reload).toHaveBeenCalled();
        expect(target.formStateChanged).toHaveBeenCalledWith('.about-me');
        expect(target.isValid).toHaveBeenCalled();
        expect(target.validateMeAndMyProgram).toHaveBeenCalled();
      });
    });

  describe("when required About Me data is present", function() {
    beforeEach(function() {
      target.requiredAboutMeFields = {
        areComplete: true
      };
    });
    it("is complete", function() {
      target.validateMeAndMyProgram();
      expect(mockCheckbox.uncheck.calls.count()).toEqual(0);
      expect(mockCheckbox.check.calls.count()).toEqual(1);
    });
  });

  describe("when required About Me data is missing", function() {
    beforeEach(function() {
      target.requiredAboutMeFields = {
        areComplete: false
      };
    });
    it("is incomplete", function() {
      target.validateMeAndMyProgram();
      expect(mockCheckbox.uncheck.calls.count()).toEqual(1);
      expect(mockCheckbox.check.calls.count()).toEqual(0);
    });
  });

});

describe("Validate My ETD", function(){
  var target;
  var mockCheckbox = {
    check: function() { },
    uncheck: function() { },
  };
  beforeEach(function() {
    loadFixtures('work_form.html');
    target = new EtdSaveWorkControl($('#form-progress'));

    target.activate()
    target.requiredMyETD = mockCheckbox;
    spyOn(mockCheckbox, 'check').and.stub();
    spyOn(mockCheckbox, 'uncheck').and.stub();
  });

  describe("when required My ETD data is present", function() {
    beforeEach(function() {
      target.requiredAboutMyETDFields = {
        areComplete: true
      };
    });
    it("is complete", function() {
      target.validateMyETD();
      expect(mockCheckbox.uncheck.calls.count()).toEqual(0);
      expect(mockCheckbox.check.calls.count()).toEqual(1);
    });
  });
  describe('when all required fields have data', function(){
    beforeEach(function() {
      Blacklight.activate();
      var SaveEtd = require('etd_save_work_control')
      var etd_save_work_control = new SaveEtd($("#form-progress"), this.adminSetWidget)
      tinyEditor = {
        getContent: function(){}
      }
      mockMCE = {
        get: function(value) {}
      };

      tinyMCE = mockMCE;

      spyOn(tinyMCE, 'get').and.callFake(function(id) {
        return tinyEditor;
       });
      spyOn(tinyEditor, 'getContent').and.returnValue("dhsjkfds");
    });

    it("areComplete is true", function(){
      $('#etd_title').val("something");
      $('#etd_language').val("something");
      $('#etd_abstract').val("something");
      $('#etd_table_of_contents').val("something");
      $('#etd_research_field').val("Aeronomy");
      $("#etd_keyword").val("something");

      target.validateMyETD();

      expect(mockMCE.get).toHaveBeenCalledWith('etd_abstract');
      expect(tinyEditor.getContent).toHaveBeenCalled();
      expect(mockMCE.get).toHaveBeenCalledWith('etd_table_of_contents');
      expect(mockCheckbox.uncheck.calls.count()).toEqual(0);
      expect(mockCheckbox.check.calls.count()).toEqual(1);
      });
  });
});


  // describe("validateAgreement", function() {
  //   var target;
  //   beforeEach(function() {
  //     var fixture = setFixtures('<form id="edit_generic_work">' +
  //       '<aside id="form-progress"><ul><li id="required-metadata"><li id="required-files"></ul>' +
  //       '<input type="checkbox" name="agreement" id="agreement" value="1" required="required" checked="checked" />' +
  //       '<input type="submit"></aside></form>');
  //     target = new SaveWorkControl(fixture.find('#form-progress'));
  //     target.activate()
  //   });
  //   it("forces user to agree if new files are added", function() {
  //     // Agreement starts as accepted...
  //     target.uploads = { hasNewFiles: false };
  //     expect(target.validateAgreement(true)).toEqual(true);
  //
  //     // ...and becomes not accepted as soon as the user adds new files...
  //     target.uploads = { hasNewFiles: true };
  //     expect(target.validateAgreement(true)).toEqual(false);
  //
  //     // ...but allows the user to manually agree again.
  //     target.depositAgreement.setAccepted();
  //     expect(target.validateAgreement(true)).toEqual(true);
  //   });
  // });
  //
  // describe("validateFiles", function() {
  //   var mockCheckbox = {
  //     check: function() { },
  //     uncheck: function() { },
  //   };
  //   var form_id = 'new_generic_work';
  //
  //   var buildTarget = function(form_id) {
  //     var buildFixture = function(id) {
  //       return setFixtures('<form id="' + id + '">' +
  //       '<aside id="form-progress"><ul><li id="required-metadata"><li id="required-files"></ul>' +
  //       '<input type="checkbox" name="agreement" id="agreement" value="1" required="required" checked="checked" />' +
  //       '<input type="submit"></aside></form>')
  //     }
  //     target = new SaveWorkControl(buildFixture(form_id).find('#form-progress'));
  //     target.requiredFiles = mockCheckbox;
  //     return target
  //   }
  //
  //   beforeEach(function() {
  //     spyOn(mockCheckbox, 'check').and.stub();
  //     spyOn(mockCheckbox, 'uncheck').and.stub();
  //   });
  //
  //   // describe("when required files are present", function() {
  //   //   beforeEach(function() {
  //   //     target = buildTarget(form_id)
  //   //     target.uploads = {
  //   //       hasFiles: true,
  //   //       hasFileRequirement: true
  //   //     };
  //   //   });
  //   //   it("is complete", function() {
  //   //     target.validateFiles();
  //   //     expect(mockCheckbox.uncheck.calls.count()).toEqual(0);
  //   //     expect(mockCheckbox.check.calls.count()).toEqual(1);
  //   //   });
  //   // });
  //
  //   // describe("when a required files are missing", function() {
  //   //   beforeEach(function() {
  //   //     target = buildTarget(form_id)
  //   //     target.uploads = {
  //   //       hasFiles: false,
  //   //       hasFileRequirement: true
  //   //     };
  //   //   });
  //   //
  //   //   it("is incomplete", function() {
  //   //     target.validateFiles();
  //   //     expect(mockCheckbox.uncheck.calls.count()).toEqual(1);
  //   //     expect(mockCheckbox.check.calls.count()).toEqual(0);
  //   //   });
  //   // });
  //
  //   // describe("when a required files are missing and it's an edit form", function() {
  //   //   beforeEach(function() {
  //   //     form_id = 'edit_generic_work'
  //   //     target = buildTarget(form_id)
  //   //   });
  //   //   it("is complete", function() {
  //   //     target.validateFiles();
  //   //     expect(mockCheckbox.uncheck.calls.count()).toEqual(0);
  //   //     expect(mockCheckbox.check.calls.count()).toEqual(1);
  //   //   });
  //   // });
  // });

  // describe("on submit", function() {
  //   var target;
  //   beforeEach(function() {
  //     var fixture = setFixtures('<form id="new_generic_work"><aside id="form-progress"><ul><li id="required-metadata"><li id="required-files"></ul><input type="submit"></aside></form>');
  //     target = new SaveWorkControl(fixture.find('#form-progress'));
  //     target.activate()
  //   });
  //
  //   describe("when the form is invalid", function() {
  //     it("prevents submission", function() {
  //       var spyEvent = spyOnEvent('#new_generic_work', 'submit');
  //       $('#new_generic_work').submit();
  //       expect(spyEvent).toHaveBeenPrevented();
  //     });
  //   });
  // });
});
