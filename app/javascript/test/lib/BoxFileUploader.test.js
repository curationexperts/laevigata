/* global test */
/* global expect */
/* global jest */

import BoxFileUploader from '../../lib/BoxFileUploader'
import { formStore } from '../../formStore'
const mockXhr = {
  open: jest.fn(),
  send: jest.fn(),
  setRequestHeader: jest.fn(),
  readyState: XMLHttpRequest.DONE,
  responseText: JSON.stringify({ 'location': 'http://example.com' })
}
const event = [{
  id: 'testid',
  name: 'something.txt'
}]

window.XMLHttpRequest = jest.fn(() => mockXhr)

test('that you can get the url from box', () => {
  var boxFileUploader = new BoxFileUploader({
    boxAccessToken: 'accesstoken',
    event: event,
    crsfToken: 'longstring',
    formStore: formStore
  })
  boxFileUploader.getUrlFromBox()
  expect(window.XMLHttpRequest).toHaveBeenCalledTimes(1)
})

test('that you can post to uploads', () => {
  var boxFileUploader = new BoxFileUploader({
    boxAccessToken: 'accesstoken',
    event: event,
    crsfToken: 'longstring',
    formStore: formStore
  })
  boxFileUploader.postToUploads({location: 'http://example.com'})
  expect(window.XMLHttpRequest).toHaveBeenCalledTimes(2)
})
