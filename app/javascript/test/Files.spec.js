/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import { mount } from '@vue/test-utils'
import Files from 'Files'
import { formStore } from 'formStore'

window.localStorage = jest.fn()
window.localStorage.getItem = jest.fn((value) => { return undefined })

describe('Files.vue', () => {
  global.Box = { FilePicker: function() {}}
  global.boxClientId = function() {}
  it('has 2 buttons when rendered', () => {
    const wrapper = shallowMount(Files, {
    })
    expect(wrapper.findAll('button')).toHaveLength(1)
  })

  it('has two labels ', () => {
    const wrapper = shallowMount(Files, {
    })

    expect(wrapper.findAll('label')).toHaveLength(2)
  })

  it('checks for some JSON in localStorage files', () => {
    expect(window.localStorage.getItem).toBeCalledWith('files')
  })

  it('when primary file is present, it returns primary file', () => {
    const wrapper = shallowMount(Files, { })
    const fakeFileData = { id: 'fake file object' }
    formStore.files = [[fakeFileData]]

    expect(wrapper.vm.getPrimaryFile()).toEqual(fakeFileData)
  })

  it('when no primary file exists, it returns undefined', () => {
    const wrapper = shallowMount(Files, { })
    formStore.files = []

    expect(wrapper.vm.getPrimaryFile()).toEqual(undefined)
  })

  it('displays an error when saved with no primary file exists', () => {
    const wrapper = shallowMount(Files, { })
    formStore.files = []
    formStore.errors = [{"files" : ["A thesis or dissertation file is required"]}]

    expect(wrapper.find('section.errorMessage').text()).toBe('A thesis or dissertation file is required')
  })

  it('when the file is a Hyrax::UploadedFile, isUploadedFile() returns true', () => {
    const wrapper = shallowMount(Files, { })
    const fakeFileData = { deleteUrl: '/uploads/123' }

    expect(wrapper.vm.isUploadedFile(fakeFileData)).toEqual(true)
  })

  it('when the file is a ::FileSet, isUploadedFile() returns false', () => {
    const wrapper = shallowMount(Files, { })
    const fakeFileData = { deleteUrl: '/concern/file_sets/456' }

    expect(wrapper.vm.isUploadedFile(fakeFileData)).toEqual(false)
  })

  it('when the file is undefined, isUploadedFile() returns false', () => {
    const wrapper = shallowMount(Files, { })

    expect(wrapper.vm.isUploadedFile(undefined)).toEqual(false)
  })

  it('when the file is a Hyrax::UploadedFile, the uploaded_files input contains the record ID', () => {
    const wrapper = mount(Files, { })
    const fakeFileData = { deleteUrl: '/uploads/123', id: '123_my_super_unique_id' }
    formStore.files = [[fakeFileData]]
    expect(wrapper.find('input[name=uploaded_files\\[\\]]').attributes().value).toBe('123_my_super_unique_id')
  })

  it('when the file is a ::FileSet, the uploaded_files doesn\'t contain the record ID', () => {
    const wrapper = mount(Files, { })
    const fakeFileData = { deleteUrl: '/concern/file_sets/123', id: '123_my_super_unique_id' }
    formStore.files = [[fakeFileData]]

    expect(wrapper.html()).not.toContain('123_my_super_unique_id')
  })

  it('student can edit metadata fields for newly uploaded files', () => {
    const wrapper = mount(Files, { })
    const fakeFileData = { deleteUrl: '/uploads/123', id: '123_my_super_unique_id' }
    formStore.supplementalFiles = [fakeFileData]

    expect(wrapper.find('input[name=etd\\[supplemental_file_metadata\\]\\[0\\]title]').attributes().disabled).toBe(undefined)
    expect(wrapper.find('input[name=etd\\[supplemental_file_metadata\\]\\[0\\]description]').attributes().disabled).toBe(undefined)
    expect(wrapper.find('select[name=etd\\[supplemental_file_metadata\\]\\[0\\]file_type]').attributes().disabled).toBe(undefined)
  })

  it('student cannot edit metadata fields for previously uploaded files', () => {
    const wrapper = mount(Files, { })
    const fakeFileData = { deleteUrl: '/concern/file_sets/123', id: '123_my_super_unique_id' }
    formStore.supplementalFiles = [fakeFileData]

    expect(wrapper.find('input[name=etd\\[supplemental_file_metadata\\]\\[0\\]title]').attributes().disabled).toBe('disabled')
    expect(wrapper.find('input[name=etd\\[supplemental_file_metadata\\]\\[0\\]description]').attributes().disabled).toBe('disabled')
    expect(wrapper.find('select[name=etd\\[supplemental_file_metadata\\]\\[0\\]file_type]').attributes().disabled).toBe('disabled')
  })

  it('stores supplemental metadata for each file', () => {
    const wrapper = mount(Files, { })
    const fakeFileData = { deleteUrl: '/concern/file_sets/abc', id: 'abc_my_super_unique_id' }
    const moreFakeFileData = { deleteUrl: '/concern/file_sets/def', id: 'def_my_super_unique_id' }
    formStore.supplementalFiles = [fakeFileData, moreFakeFileData]

    const title = wrapper.find('input[name=etd\\[supplemental_file_metadata\\]\\[0\\]title]')

    title.value = "Great Title"
    title.trigger('input')
    title.trigger('keyup.enter')

    wrapper.find('#add-supplemental-file').trigger('click')

    expect(title.value).toBe("Great Title")
  })

  it('removes supplemental metadata when student removes supplemental file', () => {
    const mockXHR = {
      open: jest.fn(),
      send: jest.fn(),
      setRequestHeader: jest.fn()
    }
    window.XMLHttpRequest = jest.fn(() => mockXHR)

    const wrapper = mount(Files, { })
    const fakeFileData = { deleteUrl: '/concern/file_sets/abc', id: 'abc_my_super_unique_id' }
    const moreFakeFileData = { deleteUrl: '/concern/file_sets/def', id: 'def_my_super_unique_id' }

    const supplementalData = {'title': 'One'}
    const moreSupplementalData = {'title': 'Two'}

    formStore.supplementalFiles = [fakeFileData, moreFakeFileData]
    formStore.supplementalFilesMetadata = [supplementalData, moreSupplementalData]

    wrapper.vm.deleteSupplementalFile(fakeFileData.deleteUrl, 0)
    
    const remainingFiles = formStore.supplementalFiles.length
    const remainingMetadata = formStore.supplementalFilesMetadata.length
    expect(remainingFiles).toEqual(1)
    expect(remainingMetadata).toEqual(1)
  })
})
