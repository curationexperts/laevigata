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

    expect(wrapper.html()).toContain('123_my_super_unique_id')
  })

  it('when the file is a ::FileSet, the uploaded_files doesn\'t contain the record ID', () => {
    const wrapper = mount(Files, { })
    const fakeFileData = { deleteUrl: '/concern/file_sets/123', id: '123_my_super_unique_id' }
    formStore.files = [[fakeFileData]]

    expect(wrapper.html()).not.toContain('123_my_super_unique_id')
  })
})

