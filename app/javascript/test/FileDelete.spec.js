/* global describe */
/* global it */
/* global expect */
/* global jest */

import FileDelete from '../FileDelete'
import { formStore } from '../formStore'
const mockXHR = {
  open: jest.fn(),
  send: jest.fn(),
  setRequestHeader: jest.fn()
}

window.XMLHttpRequest = jest.fn(() => mockXHR)
window.localStorage = jest.fn()
window.localStorage.getItem = jest.fn()
window.localStorage.setItem = jest.fn()
window.localStorage.removeItem = jest.fn()

describe('FileDelete', () => {
  it('makes an HTTP requst and remove the file from the state', () => {
    var fileDelete = new FileDelete({
      deleteUrl: 'http://example.com/delete',
      token: 'token',
      formStore: formStore
    })
    fileDelete.deleteFile()
    expect(mockXHR.open).toBeCalledWith('DELETE', 'http://example.com/delete', true)
  })
})
