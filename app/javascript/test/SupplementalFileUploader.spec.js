/* global describe */
/* global it */
/* global expect */
/* global jest */

import SupplementalFileUploader from '../SupplementalFileUploader'

const mockXHR = {
  open: jest.fn(),
  send: jest.fn(),
  setRequestHeader: jest.fn()
}

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
})
