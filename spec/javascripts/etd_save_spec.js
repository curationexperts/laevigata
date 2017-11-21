//= require tinymce
//= require tinymce-jquery

describe("EtdSaveWorkControl", function() {
  var EtdSaveWorkControl = require('etd_save_work_control');
  var AdminSetWidget = require('hyrax/editor/admin_set_widget');
  var ETDRequiredFields = require('required_fields')

  describe("AboutMeAndProgramManagesAdditionalFields", function() {
    //test the committee member affiliation and adding and removing in here
  });

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
        expect(target.requiredMeAndMyProgram).toBeDefined();
        expect(target.primary_pdf_upload).toBeDefined();
        expect(target.supplemental_files_upload).toBeDefined();
        expect(target.requiredEmbargoes).toBeDefined();
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
        spyOn(target, 'isValid').and.callThrough();
        spyOn(target, 'validateMeAndMyProgram');
      });

      it('it re-validates the form', function(){
        target.formStateChanged('.about-me');

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

      target.activate();
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
      loadFixtures('work_form.html');
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

  describe("validateFiles", function() {
    var mockCheckbox = {
      check: function() { },
      uncheck: function() { },
    };

    beforeEach(function() {
      loadFixtures('work_form.html');
      var fixture = setFixtures(
        '<select><option></option></select>');
      admin_set = new AdminSetWidget(fixture.find('select'))
      target = new EtdSaveWorkControl($('#form-progress'), admin_set);
    });

    describe("when the required PDF is present", function() {
      beforeEach(function() {
        target.requiredPDF = mockCheckbox;
        spyOn(mockCheckbox, 'check').and.stub();
        spyOn(mockCheckbox, 'uncheck').and.stub();

        target.primary_pdf_upload = {
          hasFiles: true
        };

        spyOn(target, 'isAPdf').and.returnValue(true);
      });
      it("is complete", function() {
        target.validatePDF();
        expect(mockCheckbox.uncheck.calls.count()).toEqual(0);
        expect(mockCheckbox.check.calls.count()).toEqual(1);
      });
    });

    describe("when the required PDF is missing", function() {
      beforeEach(function() {
        target.requiredPDF = mockCheckbox;
        spyOn(mockCheckbox, 'check').and.stub();
        spyOn(mockCheckbox, 'uncheck').and.stub();

        target.primary_pdf_upload = {
          hasFiles: false
        };
      });
      it("is not valid", function() {
        target.validatePDF();
        expect(mockCheckbox.uncheck.calls.count()).toEqual(1);
        expect(mockCheckbox.check.calls.count()).toEqual(0);
      });
    });
    //triggered by both local and cloud uploads
    describe("when someone tries to upload two PDFs", function() {
      beforeEach(function() {
        loadFixtures('work_form.html');
        target.requiredPDF = mockCheckbox;
        target.primary_pdf_upload = {
          hasFiles: true
        };
        spyOn(mockCheckbox, 'check').and.stub();
        spyOn(mockCheckbox, 'uncheck').and.stub();
        spyOn(target, 'validatePDF').and.callThrough();
        spyOn(target, 'onlyOnePdfAllowed').and.callThrough();

        $('#fileupload tbody.files').append('<tr><td></td></tr>');
        $('#fileupload tbody.files').append('<tr><td></td></tr>');

      });
      it("is prevented and the user is informed why", function() {
        target.validatePDF();
        expect(target.onlyOnePdfAllowed).toHaveBeenCalled();

        expect($('#pdf-max-error')).toBeVisible();
        expect($('#fileupload tbody.files tr')).not.toExist();
        expect(mockCheckbox.uncheck.calls.count()).toEqual(1);
        expect(mockCheckbox.check.calls.count()).toEqual(0);
      });
    });

    describe("when a supplemental file is present", function() {
      beforeEach(function() {
        target.supplementalFiles = mockCheckbox;
        spyOn(mockCheckbox, 'check').and.stub();
        spyOn(mockCheckbox, 'uncheck').and.stub();

        target.supplemental_files_upload = {
          hasFiles: true
        };
      });
      it("is not valid without metadata", function() {
        target.validateSupplementalFiles();
        expect(mockCheckbox.uncheck.calls.count()).toEqual(1);
        expect(mockCheckbox.check.calls.count()).toEqual(0);
      });
    });

    describe("when No Supplemental Files is checked", function() {
      beforeEach(function() {
        loadFixtures('work_form.html');
        target.supplementalFiles = mockCheckbox;
        spyOn(mockCheckbox, 'check').and.stub();
        spyOn(mockCheckbox, 'uncheck').and.stub();
      });
      it("is valid", function() {
        $('#etd_no_supplemental_files').prop('checked', true)
        target.validateSupplementalFiles();
        expect(mockCheckbox.uncheck.calls.count()).toEqual(0);
        expect(mockCheckbox.check.calls.count()).toEqual(1);
      });
    });

    describe("when No Supplemental Files is not checked", function() {
      beforeEach(function() {
        loadFixtures('work_form.html');
        target.supplemental_files_upload = {
          hasFiles: false
        };
        target.supplementalFiles = mockCheckbox;
        spyOn(mockCheckbox, 'check').and.stub();
        spyOn(mockCheckbox, 'uncheck').and.stub();
      });
      it("requires at least one supplemental file", function() {
        $('#etd_no_supplemental_files').prop('checked', false)
        target.validateSupplementalFiles();
        expect(mockCheckbox.uncheck.calls.count()).toEqual(1);
        expect(mockCheckbox.check.calls.count()).toEqual(0);
      });
    });
  });

describe("Add Metadata to Supplemental Files", function(){
  //load the page, activate the form, require the supple js (might not be necessary), spyon the show and hide metadata events and make sure they occur

});
describe("Validate My Embargoes", function(){
  var mockCheckbox = {
    check: function() { },
    uncheck: function() { },
  };

  beforeEach(function() {
    loadFixtures('work_form.html');
    var fixture = setFixtures(
      '<select><option></option></select>');
    admin_set = new AdminSetWidget(fixture.find('select'))
    target = new EtdSaveWorkControl($('#form-progress'), admin_set);
  });

  describe("when the required fields have content", function() {
    beforeEach(function() {
      loadFixtures('work_form.html');
      target.requiredEmbargoes = mockCheckbox;
      spyOn(mockCheckbox, 'check').and.stub();
      spyOn(mockCheckbox, 'uncheck').and.stub();

      target.requiredEmbargoFields = {
        areComplete: true
      };
    });
    it("is valid", function() {
      target.validateMyEmbargo();
      expect(mockCheckbox.uncheck.calls.count()).toEqual(0);
      expect(mockCheckbox.check.calls.count()).toEqual(1);
    });
  });
});

describe("Review My Etd", function(){
  var mockCheckbox = {
    check: function() { },
    uncheck: function() { },
  };

  beforeEach(function() {
    loadFixtures('work_form.html');
    var fixture = setFixtures(
      '<select><option></option></select>');
    admin_set = new AdminSetWidget(fixture.find('select'))
    target = new EtdSaveWorkControl($('#form-progress'), admin_set);
  });

  it("the preview button is disabled unless all of the forms are complete", function() {
    var reviewMyETD = require('./review_my_etd')
    var review = new reviewMyETD("#review_my_etd", "#preview_my_etd")

    spyOn(review, 'attach_validity_listener')
    target.requiredAboutMeFields = {
      areComplete: true
    };
    target.requiredAboutMyETDFields = {
      areComplete: true
    };
    target.primary_pdf_upload = {
      hasFiles: true
    };
    target.supplemental_files_upload = {
      hasFiles: true
    };
    target.requiredEmbargoFields = {
      areComplete: true
    };
    //maybe better would be to just call the method and spy on its effects
    review.attach_validity_listener()
    expect($("span#preview_my_etd")).not.toExist();

  });
});

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
