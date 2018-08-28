/* global describe */
/* global it */
/* global expect */
/* global jest */
import { shallowMount } from '@vue/test-utils'
import SupplementalFileUploader from '../SupplementalFileUploader'
import Files from 'Files'
import { formStore } from 'formStore'

const mockXHR = {
  open: jest.fn(),
  send: jest.fn(),
  setRequestHeader: jest.fn()
}

window.localStorage = jest.fn()
window.localStorage.getItem = jest.fn((value) => { return undefined })
window.XMLHttpRequest = jest.fn(() => mockXHR)

describe('SupplementalFileUploader', () => {

  it('makes an HTTP requst and remove the file from the state', () => {
    var fileUploader = new SupplementalFileUploader({
      token: 'token',
      formStore: { files: [] },
      event: {target: { files: ['test.pdf'] }}
    })
    fileUploader.uploadFile()
    expect(mockXHR.open).toBeCalledWith('POST', '/uploads/', true)
  })

  it('prevents the user from uploading from Box until they save their supplemental file data', () => {
    const wrapper = shallowMount(Files, {
    })
    var fileUploader = new SupplementalFileUploader({
      token: 'token',
      formStore: formStore,
      event: {target: { files: ['test.pdf'] }}
    })
    fileUploader.uploadFile()
    fileUploader.formStore.disableBoxForSupplementalFiles()

    expect(wrapper.html()).toContain('Save and Continue before uploading any (more) files from Box.')
  })
})
