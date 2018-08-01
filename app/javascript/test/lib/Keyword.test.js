/* global test */
/* global expect */

import Keyword from '../../lib/Keyword'

test('that a committee keyword object has an ID, name, and affiliation', () => {
  var keyword = new Keyword({ value: 'keyword' })
  expect(keyword.value).toEqual('keyword')
})
