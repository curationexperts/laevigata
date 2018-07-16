/* global describe */
/* global it */
/* global expect */
/* global jest */

import FileUploader from '../FileUploader'

const mockXHR = {
  open: jest.fn(),
  send: jest.fn(),
  setRequestHeader: jest.fn()
}

window.XMLHttpRequest = jest.fn(() => mockXHR)

describe('FileUploader', () => {

  it('makes an HTTP requst and remove the file from the state', () => {
    var fileUploader = new FileUploader({
      token: 'token',
      formStore: { files: [] },
      event: {target: { files: ['test.pdf'] }}
    })
    fileUploader.uploadFile()
    expect(mockXHR.open).toBeCalledWith('POST', '/uploads/', true)
  })
})
