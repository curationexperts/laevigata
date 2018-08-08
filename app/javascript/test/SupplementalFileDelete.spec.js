/* global describe */
/* global it */
/* global expect */
/* global jest */
/* gloabl createXHRmock */

import SupplementalFileDelete from '../SupplementalFileDelete'
import { formStore } from '../formStore'
const mockXHR = {
  open: jest.fn(),
  send: jest.fn(),
  setRequestHeader: jest.fn()
}

window.XMLHttpRequest = jest.fn(() => mockXHR)

describe('SupplementalFileDelete', () => {
  it('makes an HTTP requst and remove the file from the state', () => {
    var fileDelete = new SupplementalFileDelete({
      deleteUrl: 'http://example.com/delete',
      token: 'token',
      formStore: formStore
    })
    fileDelete.deleteFile()
    expect(mockXHR.open).toBeCalledWith('DELETE', 'http://example.com/delete', true)
  })
})
