/* global test */
/* global expect */

import Chair from '../../lib/Chair'
import ChairList from '../../lib/ChairList'

test('that you can add a committee chair to the list', () => {
  var chair = new Chair({ name: 'test', 'affiliation': 'affiliation', affiliationType: 'Emory University' })
  var chairList = new ChairList()
  chairList.add(chair)

  expect(chairList.chairs()[0].name).toEqual('test')
})

test('that you can remove a Chair', () => {
  var chair = new Chair({ name: 'test', 'affiliation': 'affiliation', affiliationType: 'Emory University' })
  var chairList = new ChairList()
  chairList.add(chair)

  chairList.remove(chair)
  expect(chairList.chairs().length).toEqual(0)
})

test('that you can load data from attributes in savedData', () => {
  var attributes = { "0": { "affiliation_type": "Emory University", "name": ["Jamie"] }, "1": { "affiliation_type": "Emory University", "name": ["not-jamie"] } }
  var chairList = new ChairList()
  chairList.load(attributes)
  expect(chairList.chairs()[0].name).toEqual(['Jamie'])
  expect(chairList.chairs()[0].affiliationType).toEqual('Emory University')
})

test('that you can add an empty chair', () => {
  var chairList = new ChairList()
  chairList.addEmpty()
  expect(chairList.chairs().length).toEqual(1)
})
