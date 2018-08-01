/* global test */
/* global expect */

import Keyword from '../../lib/Keyword'
import KeywordList from '../../lib/KeywordList'

test('that you can add a committee keyword to the list', () => {
  var keyword = new Keyword({ value: 'test' })
  var keywordList = new KeywordList()
  keywordList.add(keyword)

  expect(keywordList.keywords()[0].value).toEqual('test')
})

test('that you can remove a Keyword', () => {
  var keyword = new Keyword({ value: 'test' })
  var keywordList = new KeywordList()
  keywordList.add(keyword)
  keywordList.remove(keyword)
  expect(keywordList.keywords().length).toEqual(0)
})

test('that you can load data from attributes in savedData', () => {
  var attributes =  {'keyword': ['test']} 
  var keywordList = new KeywordList()
  keywordList.load(attributes)
  expect(keywordList.keywords()[0].value[0]).toEqual('test')
})

test('that you can add an empty keyword', () => {
  var keywordList = new KeywordList()
  keywordList.addEmpty()
  expect(keywordList.keywords().length).toEqual(1)
})
