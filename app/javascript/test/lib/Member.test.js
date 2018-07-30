/* global test */
/* global expect */

import Member from '../../lib/Member'

test('that a committee member object has an ID, name, and affiliation', () => {
  var member = new Member({ name: 'test', 'affiliation': 'affiliation', affiliationType: 'Emory University' })
  expect(member.name).toEqual('test')
  expect(member.affiliation).toEqual('affiliation')
  expect(member.affiliationType).toEqual('Emory University')
})
