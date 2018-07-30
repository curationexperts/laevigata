/* global test */
/* global expect */

import Member from '../../lib/Member'
import MemberList from '../../lib/MemberList'

test('that you can add a committee member to the list', () => {
  var member = new Member({ name: 'test', 'affiliation': 'affiliation', affiliationType: 'Emory University' })
  var memberList = new MemberList()
  memberList.add(member)

  expect(memberList.members()[0].name).toEqual('test')
})

test('that you can remove a Member', () => {
  var member = new Member({ name: 'test', 'affiliation': 'affiliation', affiliationType: 'Emory University' })
  var memberList = new MemberList()
  memberList.add(member)

  memberList.remove(member)
  expect(memberList.members().length).toEqual(0)
})

test('that you can load data from attributes in savedData', () => {
  var attributes = { "0": { "affiliation_type": "Emory University", "name": ["Jamie"] }, "1": { "affiliation_type": "Emory University", "name": ["not-jamie"] } }
  var memberList = new MemberList()
  memberList.load(attributes)
  expect(memberList.members()[0].name).toEqual(['Jamie'])
  expect(memberList.members()[0].affiliationType).toEqual('Emory University')
})

test('that you can add an empty member', () => {
  var memberList = new MemberList()
  memberList.addEmpty()
  expect(memberList.members().length).toEqual(1)
})
