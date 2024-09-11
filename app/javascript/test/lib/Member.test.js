/* global test */
/* global expect */

import Member from '../../lib/Member'

test('affilitation and affiliationType default to Emory', () => {
  var member = new Member({ name: 'test' })
  expect(member.name).toEqual('test')
  expect(member.affiliation).toEqual(['Emory University'])
  expect(member.affiliationType).toEqual('Emory University')
})

test('affilitationType gets set to Emory for Emory affiliates', () => {
  var member = new Member({ name: 'test', affiliation: ['Emory University'] })
  expect(member.name).toEqual('test')
  expect(member.affiliation).toEqual(['Emory University'])
  expect(member.affiliationType).toEqual('Emory University')
})

test('affilitationType gets set to Non-Emory for other affiliations', () => {
  var member = new Member({ name: 'test', affiliation: ['Another Fine Institution'] })
  expect(member.name).toEqual('test')
  expect(member.affiliation).toEqual(['Another Fine Institution'])
  expect(member.affiliationType).toEqual('Non-Emory')
})
