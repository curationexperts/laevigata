/* global describe */
/* global it */
/* global expect */

import { formStore } from '../formStore'

window.localStorage = jest.fn()
window.localStorage.getItem = jest.fn()
window.localStorage.setItem = jest.fn()

formStore.getSavedOrSelectedSchool = jest.fn(() => {return 'Emory College'})
describe('formStore', () => {

  // If you change a tab's label, make sure to find
  // all the places in the code (both front-end and
  // back-end) that use that label.  If you just want
  // to change the text on a tab, don't change the
  // label, use displayName instead.
  it('has correct labels', () => {
    expect(formStore.tabs.about_me.label).toEqual('About Me')
    expect(formStore.tabs.my_program.label).toEqual('My Program')
    expect(formStore.tabs.my_advisor.label).toEqual('My Advisor')
    expect(formStore.tabs.my_etd.label).toEqual('My Etd')
    expect(formStore.tabs.keywords.label).toEqual('Keywords')
    expect(formStore.tabs.my_files.label).toEqual('My Files')
    expect(formStore.tabs.embargo.label).toEqual('Embargo')
    expect(formStore.tabs.submit.label).toEqual('Submit')
  })

  it('loads the saved department as the first choice', () => {

    formStore.allowTabSave = jest.fn(() => { return false })
    formStore.getSavedDepartment = jest.fn(() => { return ['African Studies'] })
    formStore.getDepartments()
    expect(formStore.getDepartments()).toEqual({'active': true, 'label': 'African Studies', 'selected': 'selected', 'value': 'African Studies'})
  })

  it('returns the correct embargo length based on the selected school', () => {
    formStore.setSelectedSchool('Emory College')
    expect(formStore.getEmbargoLengths()).toEqual([{ value: 'None - open access immediately', selected: 'selected' },
    { value: '6 months' }, { value: '1 year' }, { value: '2 years' }])
  })

  it('returns the correct embargo contents', () => {
    expect(formStore.getEmbargoContents()).toEqual([{
      text: 'Files',
      value: 'files_embargoed',
      disabled: false
    },
    {
      text: 'Files and Table of Contents',
      value: 'files_embargoed, toc_embargoed',
      disabled: false
    },
    {
      text: 'Files and Table of Contents and Abstract',
      value: 'files_embargoed, toc_embargoed, abstract_embargoed',
      disabled: false
    }
    ])
  })

  it('returns a previously saved subfield the list', () => {
    formStore.subfieldsEdit = true
    formStore.allowTabSave = jest.fn(() => { return false })
    expect(formStore.getSubfields()).toEqual(true)
  })

  it('returns true for user agreement when on the edit form', () => {
    formStore.allowTabSave = jest.fn(() => { return false })
    expect(formStore.getUserAgreement()).toEqual(true)
  })

  it('returns the correct label for a subfield when given the id', () => {
    formStore.subfields = [{ 'id': 'Biostatistics', 'label': 'Biostatistics - MPH & MSPH', 'active': true }, { 'id': 'Public Health Informatics', 'label': 'Public Health Informatics - MSPH', 'active': true }]
    expect(formStore.getSubfieldLabelFromId('Public Health Informatics')).toEqual('Public Health Informatics - MSPH')
  })
})
